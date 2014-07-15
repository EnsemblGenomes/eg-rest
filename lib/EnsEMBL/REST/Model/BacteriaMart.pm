
=head1 LICENSE

Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

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

package EnsEMBL::REST::Model::BacteriaMart;

use Moose;
use namespace::autoclean;
require EnsEMBL::REST;

use feature 'switch';

extends 'Catalyst::Model';

has 'log' => (
  is      => 'ro',
  isa     => 'Log::Log4perl::Logger',
  lazy    => 1,
  default => sub {
	return Log::Log4perl->get_logger(__PACKAGE__);
  } );

has 'host'   => ( is => 'ro', isa => 'Str' );
has 'port'   => ( is => 'ro', isa => 'Int' );
has 'user'   => ( is => 'ro', isa => 'Str' );
has 'pass'   => ( is => 'ro', isa => 'Str' );
has 'dbname' => ( is => 'ro', isa => 'Str' );

has '_dbc' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
	my ($self) = @_;
	my $log = $self->log();
	$log->info('Loading the bacterial mart database connection');
	my $class = 'Bio::EnsEMBL::DBSQL::DBConnection';
	Catalyst::Utils::ensure_class_loaded($class);
	my $dbc = $class->new( -USER   => $self->user(),
						   -PASS   => $self->pass(),
						   -HOST   => $self->host(),
						   -PORT   => $self->port(),
						   -DBNAME => $self->dbname() );
	return $dbc;
  } );

has 'download' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
	my ($self) = @_;
	return $self->build_engine('download');
  } );

has 'genomedetails' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
	my ($self) = @_;
	return $self->build_engine('genomedetails');
  } );

has 'genomes' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
	my ($self) = @_;
	return $self->build_engine('genomes');
  } );

has 'reactiondetails' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
	my ($self) = @_;
	return $self->build_engine('reactiondetails');
  } );

has 'reactions' => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
	my ($self) = @_;
	return $self->build_engine('reactions');
  } );

sub build_engine {
  my ( $self, $target ) = @_;
  my $log = $self->log();
  $log->info("Creating a $target query engine");
  Catalyst::Utils::ensure_class_loaded(
							"Bio::EnsEMBL::BacteriaMart::QueryEngine");
  return
	Bio::EnsEMBL::BacteriaMart::QueryEngine::build( $target,
												 -DBC => $self->_dbc() );
}

__PACKAGE__->meta->make_immutable;

1;
