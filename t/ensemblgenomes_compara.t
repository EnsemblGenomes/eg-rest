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

my $dba      = Bio::EnsEMBL::Test::MultiTestDB->new('multi');
my $core_dba = Bio::EnsEMBL::Test::MultiTestDB->new('escherichia_coli');
Catalyst::Test->import('EnsEMBL::REST');

{
  my $id = 'MF_01687';
  my $json = json_GET( '/family/id/' . $id, 'Single family' );
  isa_ok( $json, 'HASH' );
  is( $json->{stable_id}, $id, 'Expected family ID' );
  is( scalar( @{ $json->{members} } ),
	  2290, 'Expected number of members' );
}

{
  my $id  = 'b0344';
  my $fid = 'MF_01687';
  my $genome = 'escherichia_coli_str_k_12_substr_mg1655';
  my $json =
	json_GET( '/family/member/id/' . $id, 'Families for member' );
  isa_ok( $json, 'ARRAY' );
  is( scalar( @{$json} ),      1,    'Expected number of families' );
  is( $json->[0]->{stable_id}, $fid, 'Expected family' );
  ok( scalar( grep { $_->{stable_id} eq $id } @{ $json->[0]->{members} }
	  ),
	  'Expected member' );
  ok( scalar( grep { $_->{genome} eq $genome } @{ $json->[0]->{members} }
	  ),
	  'Expected member genome db' );
}

{
  my $id   = 'STRIC_2164';
  my $json = json_GET( '/family/member/id/' . $id,
					   'Families for multi-family member' );
  isa_ok( $json, 'ARRAY' );
  is( scalar( @{$json} ), 2, 'Expected number of families' );
  ok( scalar( grep { $_->{stable_id} eq $id } @{ $json->[0]->{members} }
	  ),
	  'Expected member' );
}

{
  my $id      = 'lacZ';
  my $species = 'escherichia_coli';
  my $fid     = 'MF_01687';
  my $json = json_GET( '/family/member/symbol/' . $species . '/' . $id,
					   'Families for member by symbol' );
  isa_ok( $json, 'ARRAY' );
  is( scalar( @{$json} ),      1,    'Expected number of families' );
  is( $json->[0]->{stable_id}, $fid, 'Expected family' );
  ok(
	scalar(
	  grep {
		defined $_->{display_label} &&
		  $_->{display_label} eq $id
	  } @{ $json->[0]->{members} } ),
	'Expected member' );
}

done_testing();
