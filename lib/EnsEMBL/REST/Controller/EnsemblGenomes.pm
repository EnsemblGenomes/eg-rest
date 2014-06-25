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
use Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk;
use Bio::EnsEMBL::EGVersion;
require EnsEMBL::REST;
EnsEMBL::REST->turn_on_config_serialisers(__PACKAGE__);

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
  default => 'application/json',
  map     => {
		  'text/plain'       => ['YAML'],});

sub genome : Chained('/') PathPart('lookup/genome') :
  ActionClass('REST') : Args(1) { }

sub genome_GET {
  my ($self, $c, $genome) = @_;
  $c->log()->info("Getting DBA for $genome");
  my $dba = $c->model('Registry')->get_DBAdaptor($genome, 'core', 1);
  $c->go('ReturnError', 'custom',
		 ["Could not fetch adaptor for $genome"])
	unless $dba;
  $c->log()->info("Exporting genes for $genome");
  my $genes = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->export_genes($dba);
  $c->log()->info("Finished exporting ".scalar(@$genes)." genes for $genome");
  $self->status_ok($c, entity => $genes);
  return;
}

sub ensgen_version : Chained('/') PathPart('info/eg_version') :
  ActionClass('REST') : Args(0) { }

sub ensgen_version_GET {
  my ($self, $c) = @_;
  $c->log()->info("Retrieving EG version from registry");
  # lazy load the registry
  $c->model('Registry')->_registry();
  $self->status_ok($c, entity => {version => eg_version()});
  return;
}

__PACKAGE__->meta->make_immutable;

1;
