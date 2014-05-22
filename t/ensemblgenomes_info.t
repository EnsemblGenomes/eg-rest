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

BEGIN {
  use FindBin qw/$Bin/;
  use lib "$Bin/lib";
  use RestHelper;
  $ENV{CATALYST_CONFIG}   = "$Bin/../ensembl_rest_testing.conf";
  $ENV{ENS_REST_LOG4PERL} = "$Bin/../log4perl_testing.conf";
}

use Test::More;
use Test::Differences;
use Catalyst::Test ();
use Bio::EnsEMBL::Test::MultiTestDB;
use Bio::EnsEMBL::Test::TestUtils;
use Bio::EnsEMBL::EGVersion;
use Data::Dumper;

Catalyst::Test->import('EnsEMBL::REST');

{
  my $json = json_GET( '/info/eg_version', 'EG version' );
  is( eg_version(), $json->{version} );
}

# setup lookup and insert into the context
my ( $res, $c ) = ctx_request('index.html');
my $multi = Bio::EnsEMBL::Test::MultiTestDB->new('eg');
my $gdba  = $multi->get_DBAdaptor('info');
my $tax   = $multi->get_DBAdaptor('tax');
$gdba->taxonomy_adaptor( $tax->get_TaxonomyNodeAdaptor() );

isa_ok( $gdba,
		'Bio::EnsEMBL::Utils::MetaData::DBSQL::GenomeInfoAdaptor' );

my $lookup =
  Bio::EnsEMBL::LookUp::RemoteLookUp->new(-USER => $gdba->{dbc}->user(),
										  -PASS => $gdba->{dbc}->pass(),
										  -PORT => $gdba->{dbc}->port(),
										  -HOST => $gdba->{dbc}->host(),
										  -ADAPTOR => $gdba );
isa_ok( $lookup, 'Bio::EnsEMBL::LookUp::RemoteLookUp' );
$c->model('Registry')->_lookup($lookup);
isa_ok( $c->model('Registry')->_lookup(),
		'Bio::EnsEMBL::LookUp::RemoteLookUp' );

{
  my $json = json_GET( '/info/genomes', 'Genomes info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar( @{$json} ), 1625, 'Expected number of genomes' );
}

{
  my $species = 'schizosaccharomyces_pombe';
  my $json = json_GET( '/info/genomes/' . $species, 'Genome info' );
  isa_ok( $json, 'HASH' );
  is( $json->{species}, $species, 'Testing species name' );
  ok( !defined $json->{sequences}, 'Absence of sequence' );
}

{
  my $species = 'schizosaccharomyces_pombe';
  my $json    = json_GET( '/info/genomes/' . $species . '?expand=1',
					   'Genomes info' );
  isa_ok( $json, 'HASH' );
  is( $json->{species}, $species, 'Testing species name' );
  ok(
	  ( defined $json->{sequences} &&
		  scalar( @{ $json->{sequences} } ) > 1 ),
	  'Presence of sequence' );
}

{
	my $json =
	json_GET( '/info/divisions', 'Division list' );
	isa_ok( $json, 'ARRAY' );
	is( scalar( @{$json} ), 3, 'Expected number of divisions' );
}

{
  my $division = 'EnsemblFungi';
  my $json =
	json_GET( '/info/genomes/division/' . $division, 'Division info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar( @{$json} ), 45, 'Expected number of fungal genomes' );
}

{
  my $ass = 'GCA_000005845.2';
  my $json =
	json_GET( '/info/genomes/assembly/' . $ass, 'Assembly info' );
  isa_ok( $json, 'HASH' );
  is( $json->{assembly_id}, $ass, 'Expected assembly' );
  my $ass2 = 'GCA_000005845';
  $json =
	json_GET( '/info/genomes/assembly/' . $ass2, 'Assembly info' );
  isa_ok( $json, 'HASH' );
  is( $json->{assembly_id}, $ass, 'Expected assembly' );
}

{
  my $ass = 'U00096.3';
  my $json =
	json_GET( '/info/genomes/accession/' . $ass, 'Accession info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar(@$json), 1, 'Single genome found' );
  my $ass2 = 'U00096';
  $json =
	json_GET( '/info/genomes/accession/' . $ass2, 'Accession info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar(@$json), 1, 'Single genome found' );
}

{
  my $taxon = '562';
  my $json =
	json_GET( '/info/genomes/taxonomy/' . $taxon, 'Taxonomy info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar(@$json), 1, 'Single genome found' );
  my $taxon2 = 'Escherichia coli';
  $json =
	json_GET( '/info/genomes/taxonomy/' . $taxon2, 'Taxonomy info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar(@$json), 1, 'Single genome found' );
  my $taxon3 = '511145';
  $json =
	json_GET( '/info/genomes/taxonomy/' . $taxon3, 'Taxonomy info' );
  isa_ok( $json, 'ARRAY' );
  is( scalar(@$json), 1, 'Single genome found' );
}

done_testing();
