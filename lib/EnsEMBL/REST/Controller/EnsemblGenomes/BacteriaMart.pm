
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

package EnsEMBL::REST::Controller::EnsemblGenomes::BacteriaMart;

use Moose;
use namespace::autoclean;
use Try::Tiny;
require EnsEMBL::REST;
EnsEMBL::REST->turn_on_config_serialisers(__PACKAGE__);
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config( default => 'application/json',
					 map     => { 'text/plain' => ['YAML'], } );

sub genomes : Chained('/') PathPart('mart/genomes') :
  ActionClass('REST') : Args(0) { }

sub genomes_GET {
  my ( $self, $c ) = @_;
  my $query    = $c->request->param('query')||'';
  my @filters  = split( ',', $query );
  my $pageNum  = $c->request->param('pageNum');
  my $perPage  = $c->request->param('perPage');
  my $isDetail = $c->request->param('isDetail');
  $c->log()->debug("Getting mart engine");
  my $engine = $c->model('BacteriaMart')->genomes();
  $c->log()->info( "Querying for genomes: " . $query );
  my $genomes = $engine->query(
								{ filters  => \@filters,
								  pageNum  => $pageNum,
								  perPage  => $perPage,
								  isDetail => $isDetail } );
  $c->log()->info("Finished querying for genomes");
  $self->status_ok( $c, entity => $genomes );
  return;
}

sub genomedetails : Chained('/') PathPart('mart/genomedetails') :
  ActionClass('REST') : Args(0) { }

sub genomedetails_GET {
  my ( $self, $c ) = @_;
  my $query   = $c->request->param('query')||'';
  my @filters = split( ',', $query );
  my $id      = $c->request->param('genome_id');
  $c->log()->debug("Getting mart engine");
  my $engine = $c->model('BacteriaMart')->genomedetails();
  $c->log()
	->info(
	  "Querying for genome details for genome " . $id . ": " . $query );
  my $genomes = $engine->query( { filters => \@filters, id => $id } );
  $c->log()->info("Finished querying for genome details");
  $self->status_ok( $c, entity => $genomes );
  return;
}

sub reactions : Chained('/') PathPart('mart/reactions') :
  ActionClass('REST') : Args(0) { }

sub reactions_GET {
   my ( $self, $c ) = @_;
  my $query    = $c->request->param('query')||'';
  my @filters  = split( ',', $query );
  my $pageNum  = $c->request->param('pageNum');
  my $perPage  = $c->request->param('perPage');
  $c->log()->debug("Getting mart engine");
  my $engine = $c->model('BacteriaMart')->reactions();
  $c->log()->info( "Querying for reactions: " . $query );
  my $reactions = $engine->query(
								{ filters  => \@filters,
								  pageNum  => $pageNum,
								  perPage  => $perPage } );
  $c->log()->info("Finished querying for reactions");
  $self->status_ok( $c, entity => $reactions );
  return; 
}

sub reactiondetails : Chained('/') PathPart('mart/reactiondetails') :
  ActionClass('REST') : Args(0) { }

sub reactiondetails_GET {
   my ( $self, $c ) = @_;
  my $id    = $c->request->param('id');
  my $query    = $c->request->param('query')||'';
  my @filters  = split( ',', $query );
  $c->log()->debug("Getting mart engine");
  my $engine = $c->model('BacteriaMart')->reactiondetails();
  $c->log()->info( "Querying for reactions: " . $query );
  my $reactions = $engine->query(
								{ id=> $id,
								  filters  => \@filters } );
  $c->log()->info("Finished querying for reactions");
  $self->status_ok( $c, entity => $reactions );
  return; 
}


__PACKAGE__->meta->make_immutable;

1;
