#!/usr/bin/perl -w

use PerlLib::Cacher;
use PerlLib::IE::AIE;
use PerlLib::SwissArmyKnife;

use AutoLegacyTestOrig;

use Data::Dumper;

my $file = $ARGV[0];
my $c;
if ($file =~ /^http:/) {
  my $cacher = PerlLib::Cacher->new;
  $c = $cacher->get($file);
} else {
  $c = read_file($file);
}

# print Dumper($c);
# exit(0);

my $aie = PerlLib::IE::AIE->new
  (
   Contents => $c,
  );
