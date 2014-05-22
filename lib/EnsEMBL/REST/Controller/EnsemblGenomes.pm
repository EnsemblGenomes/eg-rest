
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

package EnsEMBL::REST::Controller::EnsemblGenomes;

use Moose;
use namespace::autoclean;
use Bio::EnsEMBL::GenomeExporter;
use Bio::EnsEMBL::EGVersion;
use Try::Tiny;
require EnsEMBL::REST;
EnsEMBL::REST->turn_on_config_serialisers(__PACKAGE__);
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config( default => 'application/json',
					 map     => { 'text/plain' => ['YAML'], } );

has default_compara => ( is => 'ro', isa => 'Str', default => 'multi' );

sub genome : Chained('/') PathPart('lookup/genome') :
  ActionClass('REST') : Args(1) { }

sub genome_GET {
  my ( $self, $c, $genome ) = @_;
  $c->log()->info("Getting DBA for $genome");
  my $dba = $c->model('Registry')->get_DBAdaptor( $genome, 'core', 1 );
  $c->go( 'ReturnError', 'custom',
		  ["Could not fetch adaptor for $genome"] )
	unless $dba;
  $c->log()->info("Exporting genes for $genome");
  my $genes = Bio::EnsEMBL::GenomeExporter->export_genes($dba);
  $c->log()
	->info(
	   "Finished exporting " . scalar(@$genes) . " genes for $genome" );
  $self->status_ok( $c, entity => $genes );
  return;
}

sub ensgen_version : Chained('/') PathPart('info/eg_version') :
  ActionClass('REST') : Args(0) { }

sub ensgen_version_GET {
  my ( $self, $c ) = @_;
  $c->log()->info("Retrieving EG version from registry");
  # lazy load the registry
  $c->model('Registry')->_registry();
  $self->status_ok( $c, entity => { version => eg_version() } );
  return;
}

sub genomes_all : Chained('/') PathPart('info/genomes') :
  ActionClass('REST') : Args(0) { }

sub genomes_all_GET {
  my ( $self, $c ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  my $expand = $c->request->param('expand');
  my @infos =
	map { $_->to_hash($expand) } @{ $lookup->_adaptor()->fetch_all() };
  $self->status_ok( $c, entity => \@infos );
  return;
}

sub genomes_name : Chained('/') PathPart('info/genomes') :
  ActionClass('REST') : Args(1) { }

sub genomes_name_GET {
  my ( $self, $c, $name ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  my $expand = $c->request->param('expand');
  $c->log()->info("Retrieving information about all genomes");
  my $info = $lookup->_adaptor()->fetch_by_any_name($name);
  $c->go( 'ReturnError', 'custom', ["Genome $name not found"] )
	unless defined $info;
  $self->status_ok( $c, entity => $info->to_hash($expand) );
  return;
}

sub divisions : Chained('/') PathPart('info/divisions') :
  ActionClass('REST') : Args(0) { }

sub divisions_GET {
  my ( $self, $c, $division ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  $c->log()->info("Retrieving list of divisions");
  my $divs = $lookup->_adaptor()->list_divisions();
  $self->status_ok( $c, entity => $divs );
  return;
}

sub genomes_division : Chained('/') PathPart('info/genomes/division') :
  ActionClass('REST') : Args(1) { }

sub genomes_division_GET {
  my ( $self, $c, $division ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  my $expand = $c->request->param('expand');
  $c->log()
	->info(
		"Retrieving information about genomes from division $division");
  my @infos = map { $_->to_hash($expand) }
	@{ $lookup->_adaptor()->fetch_all_by_division($division) };
  $self->status_ok( $c, entity => \@infos );
  return;
}

sub genomes_assembly : Chained('/') PathPart('info/genomes/assembly') :
  ActionClass('REST') : Args(1) { }

sub genomes_assembly_GET {
  my ( $self, $c, $acc ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  my $expand = $c->request->param('expand');
  my $info   = $lookup->_adaptor()->fetch_by_assembly_id($acc);
  $c->go( 'ReturnError', 'custom',
		  ["Genome with assembly accession $acc not found"] )
	unless defined $info;
  $self->status_ok( $c, entity => $info->to_hash($expand) );
  return;
}

sub genomes_accession : Chained('/') PathPart('info/genomes/accession')
  : ActionClass('REST') : Args(1) { }

sub genomes_accession_GET {
  my ( $self, $c, $acc ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  my $expand = $c->request->param('expand');
  my @infos  = map { $_->to_hash($expand) }
	@{ $lookup->_adaptor()->fetch_all_by_sequence_accession($acc) };
  $self->status_ok( $c, entity => \@infos );
  return;
}

sub genomes_taxonomy : Chained('/') PathPart('info/genomes/taxonomy') :
  ActionClass('REST') : Args(1) { }

sub genomes_taxonomy_GET {
  my ( $self, $c, $taxon ) = @_;
  # lazy load the registry
  $c->model('Registry')->_registry();
  my $lookup = $c->model('Registry')->_lookup();
  my $expand = $c->request->param('expand');
  $c->log()
	->info("Retrieving information about genomes from taxon $taxon");
  my @infos = map { $_->to_hash($expand) }
	@{ $lookup->_adaptor()->fetch_all_by_taxonomy_branch($taxon) };
  $self->status_ok( $c, entity => \@infos );
  return;
}

sub get_adaptors : Private {
  my ( $self, $c ) = @_;
  my $species = $c->stash()->{species};
  my $compara_dba =
	$c->model('Registry')->get_best_compara_DBAdaptor( $species,
										$c->request()->param('compara'),
										$self->default_compara() );
  my $fa  = $compara_dba->get_FamilyAdaptor();
  my $gma = $compara_dba->get_GeneMemberAdaptor();
  $c->stash( family_adaptor => $fa, gene_member_adaptor => $gma );
}

sub family : Chained('/') PathPart('family/id') : ActionClass('REST') :
  Args(1) { }

sub family_GET {
  my ( $self, $c, $id ) = @_;

  $c->log()->info("Retrieving family with identifier $id");

  #Get the compara DBAdaptor
  $c->forward('get_adaptors');

  my $s      = $c->stash();
  my $fa     = $s->{family_adaptor};
  my $family = $fa->fetch_by_stable_id($id);
  $self->status_ok( $c, entity => _family_to_hash($family) );

  return;
}

sub family_member : Chained('/') PathPart('family/member/id') :
  ActionClass('REST') : Args(1) { }

sub family_member_GET {
  my ( $self, $c, $id ) = @_;

  $c->log()->info("Retrieving family for member with identifier $id");

  #Get the compara DBAdaptor
  $c->forward('get_adaptors');

  my $s  = $c->stash();
  my $fa = $s->{family_adaptor};
  my $ma = $s->{gene_member_adaptor};

  $self->status_ok( $c,
					entity => _member_to_families( $ma, $fa, $id ) );

  return;
}

sub family_member_symbol : Chained('/')
  PathPart('family/member/symbol') : ActionClass('REST') : Args(2) { }

sub family_member_symbol_GET {
  my ( $self, $c, $species, $gene_symbol ) = @_;
  my $genes;
  try {
	$c->stash( species => $species );
	$c->request->param( 'object', 'gene' );
	my $local_genes =
	  $c->model('Lookup')->find_objects_by_symbol($gene_symbol);
	$genes = [ grep { $_->slice->is_reference() } @{$local_genes} ];
  }
  catch {
	$c->log->fatal(qq{No genes found for external id: $gene_symbol});
	$c->go( 'ReturnError', 'from_ensembl', [$_] );
  };
  unless ( defined $genes ) {
	$c->log->fatal(qq{Nothing found in DB for : [$gene_symbol]});
	$c->go( 'ReturnError', 'custom',
			[qq{No content for [$gene_symbol]}] );
  }
  my @gene_stable_ids = map { $_->stable_id } @$genes;
  if ( !@gene_stable_ids ) {
	$c->go(
	  'ReturnError',
	  'custom',
"Cannot find a suitable gene for the symbol '${gene_symbol}' and species '${species}"
	);
  }
  my $families = [];
  $c->forward('get_adaptors');
  my $s  = $c->stash();
  my $fa = $s->{family_adaptor};
  my $ma = $s->{gene_member_adaptor};
  for my $id (@gene_stable_ids) {
	for my $family ( @{ _member_to_families( $ma, $fa, $id ) } ) {
	  push @$families, $family;
	}
  }
  $self->status_ok( $c, entity => $families );

  return;
} ## end sub family_member_symbol_GET

sub _family_to_hash {
  my ($family) = @_;
  my $hash = { stable_id   => $family->stable_id(),
			   description => $family->description() };
  for my $member ( @{ $family->get_all_Members() } ) {
	push @{ $hash->{members} },
	  { stable_id     => $member->stable_id(),
		display_label => $member->display_label(),
		description   => $member->description() };
  }
  return $hash;
}

sub _member_to_families {
  my ( $ma, $fa, $id ) = @_;
  my $member = $ma->fetch_by_source_stable_id( undef, $id );

  my $families = [];
  for my $family ( @{ $fa->fetch_all_by_Member($member) } ) {
	push @$families, _family_to_hash($family);
  }
  return $families;
}

__PACKAGE__->meta->make_immutable;

1;
