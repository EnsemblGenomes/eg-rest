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

sub export_genes {
  my ( $self, $dba, $biotypes, $level, $load_xrefs ) = @_;
  if ( !defined $level ) {
	$level = 'gene';
  }
  if ( !defined $load_xrefs ) {
	$load_xrefs = 0;
  }
  # query for all genes, hash by ID
  my $genes = $self->get_genes( $dba, $biotypes, $level, $load_xrefs );
  return [ values %$genes ];
}

sub get_genes {
  my ( $self, $dba, $biotypes, $level, $load_xrefs ) = @_;
  my $biotype_sql = '';
  if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
	$biotype_sql = ' and g.biotype in (' .
	  join( ',', map { "'$_'" } @$biotypes ) . ')';
  }
  my @genes = @{
	$dba->dbc()->sql_helper()->execute(
	  -SQL => qq/
	select g.stable_id as id, x.display_label as name, g.description,
	g.seq_region_start as start, g.seq_region_end as end, g.seq_region_strand as strand,
	s.name as seq_region_name
	from gene g
	left join xref x on (g.display_xref_id=x.xref_id)
	join seq_region s using (seq_region_id)
	join coord_system c using (coord_system_id)
	where c.species_id=? $biotype_sql
	/,
	  -PARAMS       => [ $dba->species_id() ],
	  -USE_HASHREFS => 1, ) };

  my $genes = { map { $_->{id} => $_ } @genes };
  # query for all synonyms, hash by gene ID
  my $synonyms = $self->get_synonyms( $dba, $biotypes );
  while ( my ( $gene_id, $synonym ) = each %$synonyms ) {
	$genes->{$gene_id}->{synonyms} = $synonym;
  }
  if ( $load_xrefs == 1 ) {
	# query for all xrefs, hash by gene ID
	my $xrefs = $self->get_xrefs( $dba, 'gene', $biotypes );
	while ( my ( $gene_id, $xref ) = each %$xrefs ) {
	  $genes->{$gene_id}->{xrefs} = $xref;
	}
  }
  if ( $level eq 'transcript' ||
	   $level eq 'translation' ||
	   $level eq 'protein_feature' )
  {
	# query for transcripts, hash by gene ID
	my $transcripts =
	  $self->get_transcripts( $dba, $biotypes, $level, $load_xrefs );
	while ( my ( $gene_id, $transcript ) = each %$transcripts ) {
	  $genes->{$gene_id}->{transcripts} = $transcript;
	}
  }
  return $genes;
} ## end sub get_genes

sub get_synonyms {
  my ( $self, $dba, $biotypes ) = @_;
  my $biotype_sql = '';
  if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
	$biotype_sql = ' and g.biotype in (' .
	  join( ',', map { "'$_'" } @$biotypes ) . ')';
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
	} );
  return $synonyms;

} ## end sub get_synonyms

sub get_transcripts {
  my ( $self, $dba, $biotypes, $level, $load_xrefs ) = @_;

  my $biotype_sql = '';
  if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
	$biotype_sql = ' and t.biotype in (' .
	  join( ',', map { "'$_'" } @$biotypes ) . ')';
  }

  my $xrefs = {};
  if ( $load_xrefs == 1 ) {
	$self->get_xrefs( $dba, 'transcript', $biotypes );
  }

  my $translations = {};
  if ( $level eq 'translation' || $level eq 'protein_feature' ) {
	$translations =
	  $self->get_translations( $dba, $biotypes, $level, $load_xrefs );
  }

  my @transcripts = @{
	$dba->dbc()->sql_helper()->execute(
	  -SQL => qq/
  	select g.stable_id as gene_id,
  	t.stable_id as id,
  	x.display_label as name,
  	t.description, 
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
		return $row;
	  } ) };

  my $transcripts = {};
  for my $transcript (@transcripts) {
	push @{ $transcripts->{ $transcript->{gene_id} } }, $transcript;
  }

  return $transcripts;

} ## end sub get_transcripts

sub get_translations {
  my ( $self, $dba, $biotypes, $level, $load_xrefs ) = @_;

  my $biotype_sql = '';
  if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
	$biotype_sql = ' and t.biotype in (' .
	  join( ',', map { "'$_'" } @$biotypes ) . ')';
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

  my @translations = @{
	$dba->dbc()->sql_helper()->execute(
	  -SQL => qq/
  	select t.stable_id as transcript_id,
  	tl.stable_id as id
  	from transcript t
  	join translation tl using (transcript_id)
  	join seq_region s using (seq_region_id)
  	join coord_system c using (coord_system_id)
  	where c.species_id=? $biotype_sql
  	/,
	  -PARAMS       => [ $dba->species_id() ],
	  -USE_HASHREFS => 1,
	  -CALLBACK     => sub {
		my ($row) = @_;
		$row->{xrefs}            = $xrefs->{ $row->{id} };
		$row->{protein_features} = $protein_features->{ $row->{id} };
		return $row;
	  } ) };

  my $translations = {};
  for my $translation (@translations) {
	push @{ $translations->{ $translation->{transcript_id} } },
	  $translation;
  }

  return $translations;

} ## end sub get_translations

sub get_protein_features {
  my ( $self, $dba, $biotypes ) = @_;

  my $biotype_sql = '';
  if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
	$biotype_sql = ' and t.biotype in (' .
	  join( ',', map { "'$_'" } @$biotypes ) . ')';
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
	  -USE_HASHREFS => 1 ) };

  my $protein_features = {};
  for my $protein_feature (@protein_features) {
	push @{ $protein_features->{ $protein_feature->{translation_id} } },
	  $protein_feature;
  }

  return $protein_features;

} ## end sub get_protein_features

sub get_xrefs {
  my ( $self, $dba, $type, $biotypes ) = @_;

  my $biotype_sql = '';
  if ( defined $biotypes && scalar(@$biotypes) > 0 ) {
	$biotype_sql = ' and g.biotype in (' .
	  join( ',', map { "'$_'" } @$biotypes ) . ')';
  }

  my $sql;
  my $oox_sql;
  if ( $type eq 'gene' ) {
	$sql = qq/
	select g.stable_id as id, ox.object_xref_id, x.dbprimary_acc, x.display_label, e.db_name
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
	select ox.object_xref_id, g.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, oox.linkage_type, sx.dbprimary_acc,sx.display_label,se.db_name
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
  } ## end if ( $type eq 'gene' )
  elsif ( $type eq 'transcript' ) {
	$sql = qq/
	select g.stable_id as id, ox.object_xref_id, x.dbprimary_acc, x.display_label, e.db_name
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
	select ox.object_xref_id, g.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, oox.linkage_type, sx.dbprimary_acc,sx.display_label,se.db_name
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
  } ## end elsif ( $type eq 'transcript') [ if ( $type eq 'gene' )]
  elsif ( $type eq 'translation' ) {
	$sql = qq/
	select tl.stable_id as id, ox.object_xref_id, x.dbprimary_acc, x.display_label, e.db_name
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
	select ox.object_xref_id, tl.stable_id as id, x.dbprimary_acc, x.display_label, e.db_name, oox.linkage_type, sx.dbprimary_acc,sx.display_label,se.db_name
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
  } ## end elsif ( $type eq 'translation') [ if ( $type eq 'gene' )]
  my $xrefs = {};
  $dba->dbc()->sql_helper()->execute_no_return(
	-SQL      => $sql,
	-PARAMS   => [ $dba->species_id() ],
	-CALLBACK => sub {
	  my ($row) = @_;
	  push @{ $xrefs->{ $row->[0] } },
		{ primary_id => $row->[1],
		  display_id => $row->[2],
		  dbname     => $row->[3] };
	  return;
	} );
  # now handle oox
  my $oox_xrefs = {};
  $dba->dbc()->sql_helper()->execute_no_return(
	-SQL      => $oox_sql,
	-PARAMS   => [ $dba->species_id() ],
	-CALLBACK => sub {
	  my ($row) = @_;
	  my $xref = $oox_xrefs->{ $row->[0] };
	  if ( !defined $xref ) {
		$xref = { obj_id     => $row->[1],
				  primary_id => $row->[2],
				  display_id => $row->[3],
				  dbname     => $row->[4] };
		$oox_xrefs->{ $row->[0] } = $xref;
	  }
	  # add linkage type to $xref
	  push @{ $xref->{linkage_types} },
		{ evidence => $row->[5],
		  source   => {
					  primary_id => $row->[6],
					  display_id => $row->[7],
					  dbname     => $row->[8] } };
	  return;
	} );
  for my $xref ( values %{$oox_xrefs} ) {
	push @{ $xrefs->{ $xref->{obj_id} } }, $xref;
	delete $xref->{obj_id};
  }

  return $xrefs;

} ## end sub get_xrefs

1;
