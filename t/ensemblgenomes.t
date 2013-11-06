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

my $species = 'escherichia_coli';
my $dba     = Bio::EnsEMBL::Test::MultiTestDB->new($species);
Catalyst::Test->import('EnsEMBL::REST');

{
  my $json = json_GET("/info/eg_version", "EG version");
  is(eg_version(), $json->{version});
}
{
  for my $dba (@{Bio::EnsEMBL::Registry->get_all_DBAdaptors()}) {
	print "->" . $dba->species() . "\n";
  }
  my $json         = json_GET("/lookup/genome/$species", "Genome dump");
  my $nGenes       = 0;
  my $nTranscripts = 0;
  my $nTranslations = 0;
  my $nFeatures     = 0;
  for my $gene (@{$json}) {
	$nGenes++;
	for my $transcript (@{$gene->{transcripts}}) {
	  $nTranscripts++;
	  for my $translation (@{$transcript->{translations}}) {
		$nTranslations++;
		for my $protein_feature (@{$translation->{protein_features}}) {
		  $nFeatures++;
		}
	  }
	}
  }
  is(11, $nGenes,        "Gene count");
  is(11, $nTranscripts,  "Transcript count");
  is(11, $nTranslations, "Translation count");
  is(63, $nFeatures,     "Feature count");
}

done_testing();
