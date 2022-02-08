#!/usr/bin/env perl

sub fibRec {
  my $n = shift;
  $n < 2 ? $n : fibRec($n - 1) + fibRec($n - 2);
}

use AutoLegacyTest2;

my $res = fibRec(10);
print $res."\n";
