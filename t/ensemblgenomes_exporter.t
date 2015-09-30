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
use Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk;
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Data::Dumper;

sub count {
	my ($json) = @_;
	my $cnts = {
		nGenes        => 0,
		nTranscripts  => 0,
		nTranslations => 0,
		nFeatures     => 0,
		nXrefs        => 0,
		nExons        => 0
	};
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
			for my $exon ( @{ $transcript->{exons} } ) {
				$cnts->{nExons}++;
			}
		}
	}
	return $cnts;
} ## end sub count

my $species = 'escherichia_coli';
my $dba     = Bio::EnsEMBL::Test::MultiTestDB->new($species);

for my $dba ( @{ Bio::EnsEMBL::Registry->get_all_DBAdaptors() } ) {
	{
		diag( "Exporting genes for " . $dba->species() );
		my $exporter = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->new();
		my $genes    = $exporter->export_genes($dba);
		my $cnt      = count($genes);
		is( 12, $cnt->{nGenes},        'Gene count' );
		is( 0,  $cnt->{nTranscripts},  'Transcript count' );
		is( 0,  $cnt->{nTranslations}, 'Translation count' );
		is( 0,  $cnt->{nFeatures},     'Feature count' );
		is( 0,  $cnt->{nXrefs},        'Xref count' );
		is( 0,  $cnt->{nExons},        'Exon count' );
		diag( "Done exporting genes for " . $dba->species() );
	}

	{
		diag( "Exporting transcripts for " . $dba->species() );
		my $exporter = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->new();
		my $genes    = $exporter->export_genes( $dba, [], 'transcript' );
		my $cnt      = count($genes);
		is( 12, $cnt->{nGenes},        'Gene count' );
		is( 12, $cnt->{nTranscripts},  'Transcript count' );
		is( 0,  $cnt->{nTranslations}, 'Translation count' );
		is( 0,  $cnt->{nFeatures},     'Feature count' );
		is( 0,  $cnt->{nXrefs},        'Xref count' );
		is( 0,  $cnt->{nExons},        'Exon count' );
		diag( "Done exporting genes for " . $dba->species() );
	}

	{
		diag( "Exporting translations for " . $dba->species() );
		my $exporter = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->new();
		my $genes    = $exporter->export_genes( $dba, [], 'translation' );
		my $cnt      = count($genes);
		is( 12, $cnt->{nGenes},        'Gene count' );
		is( 12, $cnt->{nTranscripts},  'Transcript count' );
		is( 11, $cnt->{nTranslations}, 'Translation count' );
		is( 0,  $cnt->{nFeatures},     'Feature count' );
		is( 0,  $cnt->{nXrefs},        'Xref count' );
		is( 0,  $cnt->{nExons},        'Exon count' );
		diag( "Done exporting genes for " . $dba->species() );
	}

	{
		diag( "Exporting protein_features for " . $dba->species() );
		my $exporter = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->new();
		my $genes    = $exporter->export_genes( $dba, [], 'protein_feature' );
		my $cnt      = count($genes);
		is( 12, $cnt->{nGenes},        'Gene count' );
		is( 12, $cnt->{nTranscripts},  'Transcript count' );
		is( 11, $cnt->{nTranslations}, 'Translation count' );
		is( 63, $cnt->{nFeatures},     'Feature count' );
		is( 0,  $cnt->{nXrefs},        'Xref count' );
		is( 0,  $cnt->{nExons},        'Exon count' );
		diag( "Done exporting genes for " . $dba->species() );
	}

	{
		diag( "Exporting everything for " . $dba->species() );
		my $exporter = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->new();
		my $genes = $exporter->export_genes( $dba, [], 'protein_feature', 1 );
		my $cnt   = count($genes);
		is( 12,  $cnt->{nGenes},        'Gene count' );
		is( 12,  $cnt->{nTranscripts},  'Transcript count' );
		is( 11,  $cnt->{nTranslations}, 'Translation count' );
		is( 63,  $cnt->{nFeatures},     'Feature count' );
		is( 264, $cnt->{nXrefs},        'Xref count' );
		is( 0,   $cnt->{nExons},        'Exon count' );
		diag( "Done exporting genes for " . $dba->species() );
	}

	{
		diag( "Exporting everything incl exons for " . $dba->species() );
		my $exporter = Bio::EnsEMBL::GenomeExporter::GenomeExporterBulk->new();
		my $genes =
		  $exporter->export_genes( $dba, [], 'protein_feature', 1, 1 );
		my $cnt = count($genes);
		is( 12, $cnt->{nGenes},        'Gene count' );
		is( 12, $cnt->{nTranscripts},  'Transcript count' );
		is( 11, $cnt->{nTranslations}, 'Translation count' );
		is( 63, $cnt->{nFeatures},     'Feature count' );
		is( 11,  $cnt->{nExons},        'Exon count' );
		diag( "Done exporting genes for " . $dba->species() );
		open my $out, ">", "/tmp/test.json";
		use JSON qw(to_json);
		print $out to_json($genes);
		close $out;
	}

} ## end for my $dba ( @{ Bio::EnsEMBL::Registry...})

done_testing();
