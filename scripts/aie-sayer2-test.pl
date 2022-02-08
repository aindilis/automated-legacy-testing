#!/usr/bin/env perl

use PerlLib::IE::AIE;

use Data::Dumper;
use File::Slurp;

use AutoLegacyTest;

my $file = $ARGV[0];
my $c = read_file($file);
my $aie = PerlLib::IE::AIE->new
  (
   Contents => $c,
  );
