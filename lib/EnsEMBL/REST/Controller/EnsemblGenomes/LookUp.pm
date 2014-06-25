
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

package EnsEMBL::REST::Controller::EnsemblGenomes::LookUp;

use Moose;
use namespace::autoclean;
use Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk;
use Bio::EnsEMBL::EGVersion;
use Try::Tiny;
require EnsEMBL::REST;
EnsEMBL::REST->turn_on_config_serialisers(__PACKAGE__);
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config( default => 'application/json',
					 map     => { 'text/plain' => ['YAML'], } );

sub genome : Chained('/') PathPart('lookup/genome') :
  ActionClass('REST') : Args(1) { }

sub genome_GET {
  my ( $self, $c, $genome ) = @_;
  
  my $level = $c->request->param( 'level' )||'gene';
  my @biotypes = split(',',$c->request->param( 'biotypes' )||'');
  my $xrefs = $c->request->param( 'xrefs')||'0';
  $c->log()->info("Getting DBA for $genome (level=$level,xrefs=$xrefs,biotypes=".join(',',@biotypes).")");
  my $dba = $c->model('Registry')->get_DBAdaptor( $genome, 'core', 1 );
  $c->go( 'ReturnError', 'custom',
		  ["Could not fetch adaptor for $genome"] )
	unless $dba;
  $c->log()->info("Exporting genes for $genome");
  my $genes = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->export_genes($dba,\@biotypes,$level,$xrefs);
  $c->log()
	->info(
	   "Finished exporting " . scalar(@$genes) . " genes for $genome" );
  $self->status_ok( $c, entity => $genes );
  return;
}

__PACKAGE__->meta->make_immutable;

1;
