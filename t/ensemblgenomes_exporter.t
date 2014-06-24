# Copyright [2009-2014] EMBL-European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;

use Test::More;
use Test::Differences;
use Bio::EnsEMBL::Test::MultiTestDB;
use Bio::EnsEMBL::Test::TestUtils;
use Bio::EnsEMBL::GenomeExporterBulk;
use Bio::EnsEMBL::DBSQL::DBAdaptor;

my $species = 'escherichia_coli';
my $dba     = Bio::EnsEMBL::Test::MultiTestDB->new($species);

#my $dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new(-DBNAME=>'dstaines_test_db_escherichia_coli_core_20140624_174203',-SPECIES=>'ecoli',-HOST=>'127.0.0.1',-PORT=>3306,-USER=>'ensrw', -PASS=>'writ3r');
#my $dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new(-DBNAME=>'bacteria_22_collection_core_22_75_1',-SPECIES=>'ecoli',-HOST=>'127.0.0.1',-PORT=>4275,-USER=>'ensro', -MULTISPECIES_DB=>1, -SPECIES_ID=>131);
for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
  diag( "Exporting genes for " . $dba->species() );
  my $genes =
	Bio::EnsEMBL::GenomeExporterBulk->export_genes($dba);
  print scalar(@$genes);
  diag( "Done exporting genes for " . $dba->species() );
}

done_testing();
