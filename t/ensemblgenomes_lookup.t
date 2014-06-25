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

sub count {
  my ($json) = @_;
  my $cnts = { nGenes        => 0,
			   nTranscripts  => 0,
			   nTranslations => 0,
			   nFeatures     => 0,
			   nXrefs        => 0 };
  for my $gene ( @{$json} ) {
	$cnts->{nGenes}++;
	if ( defined $gene->{xrefs} ) {
	  $cnts->{nXrefs} += scalar( @{ $gene->{xrefs} } );
	}
	for my $transcript ( @{ $gene->{transcripts} } ) {
	  $cnts->{nTranscripts}++;
	  if ( defined $transcript->{xrefs} ) {
		$cnts->{nXrefs} += scalar( @{ $transcript->{xrefs} } );
	  }
	  for my $translation ( @{ $transcript->{translations} } ) {
		$cnts->{nTranslations}++;
		if ( defined $translation->{xrefs} ) {
		  $cnts->{nXrefs} += scalar( @{ $translation->{xrefs} } );
		}
		for
		  my $protein_feature ( @{ $translation->{protein_features} } )
		{
		  $cnts->{nFeatures}++;
		}
	  }
	}
  }
  return $cnts;
} ## end sub count

my $species = 'escherichia_coli';
my $dba     = Bio::EnsEMBL::Test::MultiTestDB->new($species);
Catalyst::Test->import('EnsEMBL::REST');

{
  for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
	print '->' . $dba->species() . "\n";
  }
  my $json = json_GET( "/lookup/genome/$species", 'Genome dump' );
  my $cnt = count($json);
  is( 12, $cnt->{nGenes},        'Gene count' );
  is( 0,  $cnt->{nTranscripts},  'Transcript count' );
  is( 0,  $cnt->{nTranslations}, 'Translation count' );
  is( 0,  $cnt->{nFeatures},     'Feature count' );
  is( 0,  $cnt->{nXrefs},        'Xref count' );
}

{
  for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
	print '->' . $dba->species() . "\n";
  }
  my $json = json_GET( "/lookup/genome/$species?level=transcript",
					   'Genome dump' );
  my $cnt = count($json);
  is( 12, $cnt->{nGenes},        'Gene count' );
  is( 12, $cnt->{nTranscripts},  'Transcript count' );
  is( 0,  $cnt->{nTranslations}, 'Translation count' );
  is( 0,  $cnt->{nFeatures},     'Feature count' );
  is( 0,  $cnt->{nXrefs},        'Xref count' );
}

{
  for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
	print '->' . $dba->species() . "\n";
  }
  my $json = json_GET( "/lookup/genome/$species?level=translation",
					   'Genome dump' );
  my $cnt = count($json);
  is( 12, $cnt->{nGenes},        'Gene count' );
  is( 12, $cnt->{nTranscripts},  'Transcript count' );
  is( 11, $cnt->{nTranslations}, 'Translation count' );
  is( 0,  $cnt->{nFeatures},     'Feature count' );
  is( 0,  $cnt->{nXrefs},        'Xref count' );
}

{
  for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
	print '->' . $dba->species() . "\n";
  }
  my $json = json_GET( "/lookup/genome/$species?level=protein_feature",
					   'Genome dump' );
  my $cnt = count($json);
  is( 12, $cnt->{nGenes},        'Gene count' );
  is( 12, $cnt->{nTranscripts},  'Transcript count' );
  is( 11, $cnt->{nTranslations}, 'Translation count' );
  is( 63, $cnt->{nFeatures},     'Feature count' );
  is( 0,  $cnt->{nXrefs},        'Xref count' );
}

{
  for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
	print '->' . $dba->species() . "\n";
  }
  my $json =
	json_GET( "/lookup/genome/$species?level=protein_feature&xrefs=1",
			  'Genome dump' );
  my $cnt = count($json);
  is( 12,  $cnt->{nGenes},        'Gene count' );
  is( 12,  $cnt->{nTranscripts},  'Transcript count' );
  is( 11,  $cnt->{nTranslations}, 'Translation count' );
  is( 63,  $cnt->{nFeatures},     'Feature count' );
  is( 264, $cnt->{nXrefs},        'Xref count' );
}

done_testing();
