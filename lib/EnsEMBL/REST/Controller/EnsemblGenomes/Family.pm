
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

package EnsEMBL::REST::Controller::EnsemblGenomes::Family;

use Moose;
use namespace::autoclean;
use Bio::EnsEMBL::EGVersion;
use Try::Tiny;
require EnsEMBL::REST;
EnsEMBL::REST->turn_on_config_serialisers(__PACKAGE__);
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config( default => 'application/json',
					 map     => { 'text/plain' => ['YAML'], } );

has default_compara => ( is => 'ro', isa => 'Str', default => 'multi' );

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
					entity => _member_to_families( $c, $ma, $fa, $id ) );

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
	for my $family ( @{ _member_to_families( $c, $ma, $fa, $id ) } ) {
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
  for my $member ( @{ $family->get_all_GeneMembers() } ) {
	push @{ $hash->{members} },
	  { stable_id     => $member->stable_id(),
		display_label => $member->display_label(),
		description   => $member->description() };
  }
  return $hash;
}

sub _member_to_families {
  my ( $c, $ma, $fa, $id ) = @_;
  my $member = $ma->fetch_by_source_stable_id( undef, $id );
  unless ( defined $member ) {
	$c->log->fatal(qq{Nothing found in DB for : [$id]});
	$c->go( 'ReturnError', 'custom',
			[qq{No content for [$id]}] );
  }
  if(ref $member eq 'Bio::EnsEMBL::Compara::GeneMember') {
  	$member = $member->get_canonical_SeqMember();
  }
  my $families = [];
  for my $family ( @{ $fa->fetch_all_by_Member($member) } ) {
	push @$families, _family_to_hash($family);
  }
  return $families;
}

__PACKAGE__->meta->make_immutable;

1;
