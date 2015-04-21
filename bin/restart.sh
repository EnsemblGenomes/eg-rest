export PERL5LIB=/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/ensembl/modules:/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/ensembl-compara/modules:/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/ensembl-variation/modules:/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/ensembl-funcgen/modules:/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/ensembl-rest/lib:/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/ensemblgenomes-api/modules:/nfs/public/rw/ensembl/ensembl-genomes/current/restapi/eg-rest/lib
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
$DIR/server_control.pl restart

