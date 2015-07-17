ROOT='/nfs/public/rw/ensembl/ensembl-genomes/current/restapi'
PORT=8030
export ENSEMBL_REST_SERVER_ROOT=$ROOT
export ENSEMBL_REST_SERVER_PORT=$PORT
export PERL5LIB=$ROOT/ensembl/modules:$ROOT/ensembl-compara/modules:$ROOT/ensembl-variation/modules:$ROOT/ensembl-funcgen/modules:$ROOT/ensembl-rest/lib:$ROOT/ensemblgenomes-api/modules:$ROOT/ensembl-io/modules:$ROOT/eg-rest/lib:/nfs/public/rw/ensembl/bioperl-live:/nfs/public/rw/ensembl/bioperl-extra:/nfs/public/web-hx/tools/vcftools/perl:/nfs/public/rw/ensembl/tools/tabix:/nfs/public/rw/ensembl/tools/tabix/perl:/net/isilonP/public/rw/homes/ens_adm/src/lib/site_perl/5.16.3/x86_64-linux