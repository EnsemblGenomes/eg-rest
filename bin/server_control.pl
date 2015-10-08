#!/usr/local/bin/perl

use strict;
use warnings;
use Daemon::Control;
use FindBin qw($Bin);

my $root_dir   = $ENV{ENSEMBL_REST_SERVER_ROOT} || "$Bin/../../";
my $psgi_file  = "$root_dir/ensembl-rest/ensembl_rest.psgi";
my $starman    = '/nfs/public/rw/ensembl/perlbrew/perls/perl-5.16.3/bin/starman';
my $port       = $ENV{ENSEMBL_REST_SERVER_PORT} || 8030;
my $workers    = 5;
my $access_log = "$root_dir/logs/access_log";
my $error_log  = "$root_dir/logs/error_log";
my $pid_file   = "$root_dir/logs/eg_rest.pid";

Daemon::Control->new(
  {
    name         => "EG REST",
    lsb_start    => '$syslog $remote_fs',
    lsb_stop     => '$syslog',
    lsb_sdesc    => 'EG REST server control',
    lsb_desc     => 'Ensembl Genomes REST server control',
    program      => $starman,
    program_args => [ 
      '--listen',     ":$port", 
      '--workers',    $workers, 
      '--access-log', $access_log, 
      '--error-log',  $error_log, 
      '-M',           'EnsEMBL::REST::PreloadRegistry',      
      $psgi_file 
    ],
    pid_file     => $pid_file,
  }
)->run;

