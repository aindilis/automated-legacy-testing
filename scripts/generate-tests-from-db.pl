#!/usr/bin/env perl

# Sayer2;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

my $mysql = PerlLib::MySQL->new(DBName => 'sayer2_test');

use Sayer2;
my $sayer2 = Sayer2->new(DBName => 'sayer2_test');

my $res = $sayer2->PrintAllInformation(Silent => 1);
# print Dumper($res);

my $datahash = $res->{Data};
my $codehash = $res->{Code};
my $graphhash = $res->{Graph};
print Dumper($graphhash);

foreach my $dataid2 (sort {$a <=> $b} keys %{$graphhash}) {
  next if $dataid2 eq 'counter';
  foreach my $codeid (sort {$a <=> $b} keys %{$graphhash->{$dataid2}}) {
    foreach my $dataid1 (sort {$a <=> $b} keys %{$graphhash->{$dataid2}{$codeid}}) {
      next if $dataid1 eq 'counter';
      my $input1 = DeDumper($datahash->{$dataid1});
      my $input2 = DeDumper($datahash->{$dataid2});
      print DeDumper($codehash->{$codeid})."(". join(",",@{$input2->[0]}).") = ";
      print "[".join(",",@{$input1->[0]})."];\n";
    }
  }
}

# DO NOT HOSE YOUR SSD BY USING THE TIED HASH TOO MUCH, FIGURE THAT
# OUT.  Maybe do it in memory first, and then commit.

# generate using Test::More
