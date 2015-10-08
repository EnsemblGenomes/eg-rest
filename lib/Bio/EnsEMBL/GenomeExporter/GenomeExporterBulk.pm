#!/usr/bin/env perl

=head1 LICENSE

Copyright [2009-2014] EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

use warnings;
use strict;

package Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk;

use Bio::EnsEMBL::Utils::Argument qw(rearrange);

sub new {
	my ( $class, @args ) = @_;
	my $self = bless( {}, ref($class) || $class );
	(
		$self->{biotypes},   $self->{level},
		$self->{load_xrefs}, $self->{load_exons}
	  )
	  = rearrange( [ 'BIOTYPES', 'LEVEL', 'LOAD_XREFS', 'LOAD_EXONS' ], @args );
	$self->{load_xrefs} ||= 0;
	$self->{load_exons} ||= 0;
	$self->{level}      ||= 'gene';
	return $self;
}

sub add_compara {
	my ( $self, $species, $genes, $compara_dba ) = @_;
	my $homologues = {};
	$compara_dba->dbc()->sql_helper()->execute_no_return(
		-SQL => q/select hg.stable_id,gm.stable_id,g.name,h.description 
	from (select homology_id,stable_id from homology_member 
	join member using (member_id) 
	join genome_db using (genome_db_id) where name=? and source_name='ENSEMBLGENE') hg 
	join homology h on (h.homology_id=hg.homology_id) 
	join homology_member hm on (hm.homology_id=h.homology_id) 
	join member gm using (member_id) 
	join genome_db g using (genome_db_id) 
	where gm.stable_id<>hg.stable_id and source_name='ENSEMBLGENE'/,
		-CALLBACK => sub {
			my ($row) = @_;
			push @{ $homologues->{ $row->[0] } },
			  {
				stable_id   => $row->[1],
				genome      => $row->[2],
				description => $row->[3]
			  };
			return;
		},
		-PARAMS => [$species]
	);
	for my $gene ( @{$genes} ) {
		if ( !defined $gene->{id} ) {
			print "No ID!\n";
			die;
		}
		my $homo = $homologues->{ $gene->{id} };
		if ( defined $homo ) {
			$gene->{homologues} = $homo;
		}
	}
	return;
} ## end sub add_compara

sub export_genes {
	my ( $self, $dba, $biotypes, $level, $load_xrefs, $load_exons ) = @_;

	if ( !defined $biotypes ) {
		$biotypes = $self->{biotypes};
	}

	if ( !defined $level ) {
		$level = $self->{level};
	}

	if ( !defined $load_xrefs ) {
		$load_xrefs = $self->{load_xrefs};
	}

	if ( !defined $load_exons ) {
		$load_exons = $self->{load_exons};
	}

	# query for all genes, hash by ID
	my $genes =
	  $self->get_genes( $dba, $biotypes, $level, $load_xrefs, $load_exons );
	return [ values %$genes ];
}

sub get_genes {
	my ( $self, $dba, $biotypes, $level, $load_xrefs, $load_exons ) = @_;
	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and g.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}
	my @genes = @{
		$dba->dbc()->sql_helper()->execute(
			-SQL => qq/
	select g.stable_id as id, x.display_label as name, g.description, g.biotype,
	g.seq_region_start as start, g.seq_region_end as end, g.seq_region_strand as strand,
	s.name as seq_region_name
	from gene g
	left join xref x on (g.display_xref_id=x.xref_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql
	/,
			-PARAMS       => [ $dba->species_id() ],
			-USE_HASHREFS => 1,
		)
	  };

	my $genes = { map { $_->{id} => $_ } @genes };

	# query for all synonyms, hash by gene ID
	my $synonyms = $self->get_synonyms( $dba, $biotypes );
	while ( my ( $gene_id, $synonym ) = each %$synonyms ) {
		$genes->{$gene_id}->{synonyms} = $synonym;
	}

	# add seq_region synonyms
	my $seq_region_synonyms =
	  $self->get_seq_region_synonyms( $dba, 'gene', $biotypes );
	while ( my ( $gene_id, $synonym ) = each %$seq_region_synonyms ) {
		$genes->{$gene_id}->{seq_region_synonyms} = $synonym;
	}

	# add coord_system info
	my $coord_systems = $self->get_coord_systems( $dba, 'gene', $biotypes );
	while ( my ( $gene_id, $coord_system ) = each %$coord_systems ) {
		$genes->{$gene_id}->{coord_system} = $coord_system;
	}

	if ( $load_xrefs == 1 ) {

		# query for all xrefs, hash by gene ID
		my $xrefs = $self->get_xrefs( $dba, 'gene', $biotypes );
		while ( my ( $gene_id, $xref ) = each %$xrefs ) {
			$genes->{$gene_id}->{xrefs} = $xref;
		}
	}
	if (   $level eq 'transcript'
		|| $level eq 'translation'
		|| $level eq 'protein_feature' )
	{

		# query for transcripts, hash by gene ID
		my $transcripts =
		  $self->get_transcripts( $dba, $biotypes, $level, $load_xrefs,
			$load_exons );
		while ( my ( $gene_id, $transcript ) = each %$transcripts ) {
			$genes->{$gene_id}->{transcripts} = $transcript;
		}
	}
	return $genes;
} ## end sub get_genes

sub get_coord_systems {
	my ( $self, $dba, $type, $biotypes ) = @_;
	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and g.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}
	my $coord_systems = {};
	$dba->dbc()->sql_helper()->execute_no_return(
		-SQL => qq/
	select g.stable_id as id, c.name, c.version
	from $type g
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql
	/,
		-PARAMS   => [ $dba->species_id() ],
		-CALLBACK => sub {
			my ($row) = @_;
			$coord_systems->{ $row->[0] } =
			  { name => $row->[1], version => $row->[2] };
			return;
		}
	);
	return $coord_systems;

} ## end sub get_synonyms

sub get_synonyms {
	my ( $self, $dba, $biotypes ) = @_;
	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and g.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}
	my $synonyms = {};
	$dba->dbc()->sql_helper()->execute_no_return(
		-SQL => qq/
	select g.stable_id as id, e.synonym
	from gene g
	join external_synonym e on (g.display_xref_id=e.xref_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql
	/,
		-PARAMS   => [ $dba->species_id() ],
		-CALLBACK => sub {
			my ($row) = @_;
			push @{ $synonyms->{ $row->[0] } }, $row->[1];
			return;
		}
	);
	return $synonyms;

} ## end sub get_synonyms

sub get_seq_region_synonyms {
	my ( $self, $dba, $type, $biotypes ) = @_;
	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and g.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}
	my $synonyms = {};
	$dba->dbc()->sql_helper()->execute_no_return(
		-SQL => qq/
	select g.stable_id as id, sr.synonym as synonym, e.db_name as db 
	from $type g
	join seq_region_synonym sr using (seq_region_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
        left join external_db e using (external_db_id)
	where c.species_id=? $biotype_sql
	/,
		-PARAMS   => [ $dba->species_id() ],
		-CALLBACK => sub {
			my ($row) = @_;
			push @{ $synonyms->{ $row->[0] } },
			  { id => $row->[1], db => $row->[2] };
			return;
		}
	);
	return $synonyms;

} ## end sub get_synonyms

sub get_transcripts {
	my ( $self, $dba, $biotypes, $level, $load_xrefs, $load_exons ) = @_;

	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and t.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}

	my $xrefs = {};
	if ( $load_xrefs == 1 ) {
		$xrefs = $self->get_xrefs( $dba, 'transcript', $biotypes );
	}

	my $translations = {};
	if ( $level eq 'translation' || $level eq 'protein_feature' ) {
		$translations =
		  $self->get_translations( $dba, $biotypes, $level, $load_xrefs,
			$load_exons );
	}

	my $exons = {};
	if ( $load_exons == 1 ) {
		$exons = $self->get_exons($dba);
	}

	my $seq_region_synonyms =
	  $self->get_seq_region_synonyms( $dba, 'transcript', $biotypes );

	my $coord_systems =
	  $self->get_coord_systems( $dba, 'transcript', $biotypes );

	my @transcripts = @{
		$dba->dbc()->sql_helper()->execute(
			-SQL => qq/
  	select g.stable_id as gene_id,
  	t.stable_id as id,
  	x.display_label as name,
  	t.description, 
  	t.biotype,
	t.seq_region_start as start, t.seq_region_end as end, t.seq_region_strand as strand,
	s.name as seq_region_name
  	from 
  	gene g
  	join transcript t using (gene_id)
  	left join xref x on (t.display_xref_id=x.xref_id)
  	join seq_region s on (s.seq_region_id=g.seq_region_id)
  	join coord_system c using (coord_system_id)
  	where c.species_id=? $biotype_sql
  	/,
			-PARAMS       => [ $dba->species_id() ],
			-USE_HASHREFS => 1,
			-CALLBACK     => sub {
				my ($row) = @_;
				$row->{xrefs}        = $xrefs->{ $row->{id} };
				$row->{translations} = $translations->{ $row->{id} };
				$row->{exons}        = $exons->{ $row->{id} };
				$row->{seq_region_synonyms} =
				  $seq_region_synonyms->{ $row->{id} };
				$row->{coord_system} = $coord_systems->{ $row->{id} };
				return $row;
			}
		)
	  };

	my $transcripts = {};
	for my $transcript (@transcripts) {
		push @{ $transcripts->{ $transcript->{gene_id} } }, $transcript;
		delete $transcript->{gene_id};
	}

	return $transcripts;

} ## end sub get_transcripts

sub get_translations {
	my ( $self, $dba, $biotypes, $level, $load_xrefs, $load_exons ) = @_;

	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and t.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}
	my $xrefs = {};
	if ( $load_xrefs == 1 ) {
		$xrefs = $self->get_xrefs( $dba, 'translation', $biotypes );
	}

	# add protein features
	my $protein_features = {};
	if ( $level eq 'protein_feature' ) {
		$protein_features = $self->get_protein_features( $dba, $biotypes );
	}

	my $sql;
	if ( $load_exons == 1 ) {
		$sql = qq/
  	select t.stable_id as transcript_id,
  	tl.stable_id as id,
  	se.seq_region_strand as exon_strand,
  	se.seq_region_start as start_exon_start,
  	ee.seq_region_start as end_exon_start,
  	se.seq_region_end as start_exon_end,
  	ee.seq_region_end as end_exon_end,
	tl.seq_start as coding_start,
	tl.seq_end as coding_end
  	from transcript t
  	join translation tl using (transcript_id)
  	join exon ee on (tl.end_exon_id=ee.exon_id)
  	join exon se on (tl.start_exon_id=se.exon_id)
  	join seq_region s on (t.seq_region_id=s.seq_region_id)
  	join coord_system c using (coord_system_id)
  	where c.species_id=? $biotype_sql
  	/;
	}
	else {
		$sql = qq/
  	select t.stable_id as transcript_id,
  	tl.stable_id as id
  	from transcript t
  	join translation tl using (transcript_id)
  	join seq_region s using (seq_region_id)
  	join coord_system c using (coord_system_id)
  	where c.species_id=? $biotype_sql
  	/;
	}

	my @translations = @{
		$dba->dbc()->sql_helper()->execute(
			-SQL          => $sql,
			-PARAMS       => [ $dba->species_id() ],
			-USE_HASHREFS => 1,
			-CALLBACK     => sub {
				my ($row) = @_;
				$row->{xrefs}            = $xrefs->{ $row->{id} };
				$row->{protein_features} = $protein_features->{ $row->{id} };
				if ( $load_exons == 1 ) {
					if ( $row->{exon_strand} == 1 ) {
						$row->{coding_start} =
						  $row->{start_exon_start} + $row->{coding_start} - 1;
						$row->{coding_end} =
						  $row->{end_exon_start} + $row->{coding_end} - 1;
					}
					else {
						$row->{coding_start} =
						  $row->{end_exon_end} - $row->{coding_start} + 1;
						$row->{coding_end} =
						  $row->{start_exon_end} - $row->{coding_end} + 1;
					}
				}
				delete $row->{exon_strand};
				delete $row->{start_exon_start};
				delete $row->{start_exon_end};
				delete $row->{end_exon_start};
				delete $row->{end_exon_end};
				return $row;
			}
		)
	  };

	my $translations = {};
	for my $translation (@translations) {
		push @{ $translations->{ $translation->{transcript_id} } },
		  $translation;
		delete $translation->{transcript_id};
	}

	return $translations;

} ## end sub get_translations

sub get_protein_features {
	my ( $self, $dba, $biotypes ) = @_;

	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and t.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}

	my @protein_features = @{
		$dba->dbc()->sql_helper()->execute(
			-SQL => qq/
  	select
  	tl.stable_id as translation_id,
  	pf.hit_name as name,
  	pf.hit_description as description,
  	pf.seq_start as start,
  	pf.seq_end as end,
  	a.db as dbname,
  	i.interpro_ac
  	from transcript t
  	join translation tl using (transcript_id)
  	join protein_feature pf using (translation_id)
  	join analysis a on (a.analysis_id=pf.analysis_id)
  	left join interpro i on (pf.hit_name=i.id)
  	join seq_region s using (seq_region_id)
  	join coord_system c using (coord_system_id)
  	where c.species_id=? $biotype_sql
  	/,
			-PARAMS       => [ $dba->species_id() ],
			-USE_HASHREFS => 1
		)
	  };

	my $protein_features = {};
	for my $protein_feature (@protein_features) {
		push @{ $protein_features->{ $protein_feature->{translation_id} } },
		  $protein_feature;
		delete $protein_feature->{translation_id};
	}

	return $protein_features;

} ## end sub get_protein_features

sub get_exons {
	my ( $self, $dba, $biotypes ) = @_;
	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and t.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}
	my @exons = @{
		$dba->dbc()->sql_helper()->execute(
			-SQL => qq/
	    	select
  	t.stable_id as transcript_id,
  	et.rank as rank,
  	e.stable_id as id,
	e.seq_region_start as start, e.seq_region_end as end, e.seq_region_strand as strand,
	s.name as seq_region_name
  	from transcript t
  	join exon_transcript et using (transcript_id)
  	join exon e using (exon_id)
  	join seq_region s on (e.seq_region_id=s.seq_region_id)
  	join coord_system c using (coord_system_id)
  	where c.species_id=? $biotype_sql
	/,
			-PARAMS       => [ $dba->species_id() ],
			-USE_HASHREFS => 1
		)
	  };
	my $exons = {};
	for my $exon (@exons) {
		push @{ $exons->{ $exon->{transcript_id} } }, $exon;
	}

	return $exons;

} ## end sub get_exons

sub get_xrefs {
	my ( $self, $dba, $type, $biotypes ) = @_;

	my $biotype_sql = '';
	if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
		$biotype_sql =
		  ' and g.biotype in (' . join( ',', map { "'$_'" } @$biotypes ) . ')';
	}

	my $sql;
	my $oox_sql;
	my $ax_sql;
	if ( $type eq 'gene' ) {
		$sql = qq/
	select g.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name,x.description
	from gene g
	join object_xref ox on (g.gene_id=ox.ensembl_id and ox.ensembl_object_type='Gene')
	join xref x using (xref_id)
	join external_db e using (external_db_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	left join ontology_xref oox using (object_xref_id)
	where c.species_id=? and oox.object_xref_id is null $biotype_sql
	/;
		$oox_sql = qq/
	select ox.object_xref_id, g.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, x.description,oox.linkage_type, sx.dbprimary_acc,sx.display_label,sx.description,se.db_name
	from gene g
	join object_xref ox on (g.gene_id=ox.ensembl_id and ox.ensembl_object_type='Gene')
	join xref x using (xref_id)
	join external_db e using (external_db_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	join ontology_xref oox using (object_xref_id)
	left join xref sx on (oox.source_xref_id=sx.xref_id)
	left join external_db se on (se.external_db_id=sx.external_db_id)
	where c.species_id=? $biotype_sql
	/;
		$ax_sql = qq/
	select ax.object_xref_id,ax.rank,ax.condition_type,x.dbprimary_acc,x.display_label,xe.db_name,x.description,sx.dbprimary_acc,sx.display_label,se.db_name, sx.description, ax.associated_group_id 
	from gene g
	join object_xref ox on (g.gene_id=ox.ensembl_id and ox.ensembl_object_type='Gene')
	join associated_xref ax using (object_xref_id) 
	join xref x on (x.xref_id=ax.xref_id) 
	join external_db xe on (x.external_db_id=xe.external_db_id) 
	join xref sx on (sx.xref_id=ax.source_xref_id) 
	join external_db se on (se.external_db_id=sx.external_db_id) 
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql;
	/;
	} ## end if ( $type eq 'gene' )
	elsif ( $type eq 'transcript' ) {
		$sql = qq/
	select g.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, x.description
	from transcript g
	join object_xref ox on (g.transcript_id=ox.ensembl_id and ox.ensembl_object_type='Transcript')
	join xref x using (xref_id)
	join external_db e using (external_db_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	left join ontology_xref oox using (object_xref_id)
	where c.species_id=? and oox.object_xref_id is null $biotype_sql
	/;
		$oox_sql = qq/
	select ox.object_xref_id, g.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, x.description, oox.linkage_type, sx.dbprimary_acc,sx.display_label,se.db_name,sx.description
	from transcript g
	join object_xref ox on (g.transcript_id=ox.ensembl_id and ox.ensembl_object_type='Transcript')
	join xref x using (xref_id)
	join external_db e using (external_db_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	join ontology_xref oox using (object_xref_id)
	left join xref sx on (oox.source_xref_id=sx.xref_id)
	left join external_db se on (se.external_db_id=sx.external_db_id)
	where c.species_id=? $biotype_sql
	/;
		$ax_sql = qq/
	select ax.object_xref_id,ax.rank,ax.condition_type,x.dbprimary_acc,x.display_label,xe.db_name,x.description,sx.dbprimary_acc,sx.display_label,se.db_name,sx.description, ax.associated_group_id 
	from transcript g
	join object_xref ox on (g.gene_id=ox.ensembl_id and ox.ensembl_object_type='Transcript')
	join associated_xref ax using (object_xref_id) 
	join xref x on (x.xref_id=ax.xref_id) 
	join external_db xe on (x.external_db_id=xe.external_db_id) 
	join xref sx on (sx.xref_id=ax.source_xref_id) 
	join external_db se on (se.external_db_id=sx.external_db_id) 
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql;
	/;
	} ## end elsif ( $type eq 'transcript') [ if ( $type eq 'gene' )]
	elsif ( $type eq 'translation' ) {
		$sql = qq/
	select tl.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, x.description
	from transcript g
	join translation tl using (transcript_id)
	join object_xref ox on (tl.translation_id=ox.ensembl_id and ox.ensembl_object_type='Translation')
	join xref x using (xref_id)
	join external_db e using (external_db_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	left join ontology_xref oox using (object_xref_id)
	where c.species_id=? and oox.object_xref_id is null $biotype_sql
	/;
		$oox_sql = qq/
	select ox.object_xref_id, tl.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, x.description, oox.linkage_type, sx.dbprimary_acc,sx.display_label,se.db_name,sx.description
	from transcript g
	join translation tl using (transcript_id)
	join object_xref ox on (tl.translation_id=ox.ensembl_id and ox.ensembl_object_type='Translation')
	join xref x using (xref_id)
	join external_db e using (external_db_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	join ontology_xref oox using (object_xref_id)
	left join xref sx on (oox.source_xref_id=sx.xref_id)
	left join external_db se on (se.external_db_id=sx.external_db_id)
	where c.species_id=? $biotype_sql
	/;
		$ax_sql = qq/
	select ax.object_xref_id,ax.rank,ax.condition_type,x.dbprimary_acc,x.display_label,xe.db_name,x.description,sx.dbprimary_acc,sx.display_label,se.db_name, sx.description,ax.associated_group_id
	from transcript g
	join translation tl using (transcript_id)
	join object_xref ox on (tl.translation_id=ox.ensembl_id and ox.ensembl_object_type='Translation')
	join associated_xref ax using (object_xref_id) 
	join xref x on (x.xref_id=ax.xref_id) 
	join external_db xe on (x.external_db_id=xe.external_db_id) 
	join xref sx on (sx.xref_id=ax.source_xref_id) 
	join external_db se on (se.external_db_id=sx.external_db_id) 
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql;
	/;
	} ## end elsif ( $type eq 'translation') [ if ( $type eq 'gene' )]
	my $xrefs = {};
	$dba->dbc()->sql_helper()->execute_no_return(
		-SQL      => $sql,
		-PARAMS   => [ $dba->species_id() ],
		-CALLBACK => sub {
			my ($row) = @_;
			push @{ $xrefs->{ $row->[0] } },
			  {
				primary_id  => $row->[1],
				display_id  => $row->[2],
				dbname      => $row->[3],
				description => $row->[4]
			  };
			return;
		}
	);

	# now handle oox
	my $oox_xrefs = {};
	$dba->dbc()->sql_helper()->execute_no_return(
		-SQL      => $oox_sql,
		-PARAMS   => [ $dba->species_id() ],
		-CALLBACK => sub {
			my ($row) = @_;
			my $xref = $oox_xrefs->{ $row->[0] };
			if ( !defined $xref ) {
				$xref = {
					obj_id      => $row->[1],
					primary_id  => $row->[2],
					display_id  => $row->[3],
					dbname      => $row->[4],
					description => $row->[5],
				};
				$oox_xrefs->{ $row->[0] } = $xref;
			}

			# add linkage type to $xref
			push @{ $xref->{linkage_types} },
			  {
				evidence => $row->[6],
				source   => {
					primary_id  => $row->[7],
					display_id  => $row->[8],
					dbname      => $row->[9],
					description => $row->[10],
				}
			  };
			return;
		}
	);

	# add associated_xrefs to $oox_xrefs
	$dba->dbc()->sql_helper()->execute_no_return(
		-SQL      => $ax_sql,
		-PARAMS   => [ $dba->species_id() ],
		-CALLBACK => sub {
			my ($row) = @_;

			# 0 ax.object_xref_id
			# 1 ax.rank
			# 2 ax.condition_type
			# 3 x.dbprimary_acc
			# 4 x.display_label
			# 5 xe.db_name
			# 6 sx.dbprimary_acc
			# 7 sx.display_label
			# 8 se.db_name
			# 9 ax.associated_xref_group_id
			my $xref = $oox_xrefs->{ $row->[0] };

			# add linkage type to $xref
			$xref->{associated_xrefs}->{ $row->[11] }->{ $row->[2] } = {
				rank        => $row->[1],
				primary_id  => $row->[3],
				display_id  => $row->[4],
				dbname      => $row->[5],
				description => $row->[6],
				source      => {
					primary_id  => $row->[7],
					display_id  => $row->[8],
					dbname      => $row->[9],
					description => $row->[10],
				}
			};

			return;
		}
	);

	# collate everything
	for my $xref ( values %{$oox_xrefs} ) {
		$xref->{associated_xrefs} = [ values %{ $xref->{associated_xrefs} } ];
		push @{ $xrefs->{ $xref->{obj_id} } }, $xref;
		delete $xref->{obj_id};
	}

	return $xrefs;

} ## end sub get_xrefs

1;
