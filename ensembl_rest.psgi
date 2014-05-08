use strict;
use warnings;
use Plack::Builder;
use EnsEMBL::REST;
use Config;
use Plack::Util;
use File::Basename;
use File::Spec;
my $app = EnsEMBL::REST->psgi_app;
builder {

  my $dirname = dirname(__FILE__);
  my $rootdir = File::Spec->rel2abs(File::Spec->catdir($dirname, File::Spec->updir(), File::Spec->updir()));
  my $staticdir = File::Spec->catdir($rootdir, 'root');
    Plack::Util::load_class('BSD::Resource') if $Config{osname} eq 'darwin';
    enable 'SizeLimit' => (
        max_unshared_size_in_kb => (300 * 1024),    # 100MB per process (memory assigned just to the process)
        check_every_n_requests => 10,
    );
    enable "Plack::Middleware::ReverseProxy";
    enable 'StackTrace';
    enable 'Runtime';
    enable "ContentLength";
    $app;
}

