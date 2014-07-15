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
use Data::Dumper;

Catalyst::Test->import('EnsEMBL::REST');

{
  my $json = json_GET( "/mart/genomes?query=gene:lacZ", 'Genomes' );
}

{
  my $json =
	json_GET( "/mart/genomedetails?genome_id=11&query=gene:lacZ",
			  'Genome details' );
}

{
  my $json =
	json_GET( "/mart/reactions?query=gene:lacZ", 'Reaction details' );
}

{
  my $json = json_GET( "/mart/reactiondetails?id=28659&query=gene:lacZ",
					   'Reaction details' );
}

done_testing();
