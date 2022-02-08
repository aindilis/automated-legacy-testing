#!/usr/bin/perl -w

use Sayer2::Multiple;

use Data::Dumper;
use Hook::PrePostCall;
use Symbol::Table;

my $sayer2multiple = Sayer2::Multiple->new(DBName => 'sayermultiple_auto_legacy_test');
$sayer2multiple->Debug(1);

sub TestLowerCase {
  my (%args) = @_;
  return lc($args{Item});
}

my $package = 'main';
my $symboltables = {};
$symboltables->{$package} = Symbol::Table->New('CODE', $package);
print Dumper($symboltables);

sub InstrumentFunction {
  my (%args) = @_;
  my $functionname = $args{FunctionName};
  my $test3 = Hook::PrePostCall->new
    (
     $functionname,
     sub {
       my $id = $ENV{AUTO_LEGACY_TEST_ID} || -1;
       print STDERR "<function>\n";
       print STDERR "id: $id\n";
       print STDERR 'caller: '.((caller(0))[3])."\n";
       print STDERR 'function: '.$fullfunctionname."\n";
       print STDERR "pre: ".Dumper({Args => \@_});
       if ($ENV{AUTO_LEGACY_TEST_MODE} eq 'record') {
	 my $res = $sayer2multiple->RecordCall # FIXME: make this recordargs
	   (
	    CodeRef => $symboltables->{$package}{$functionname},
	    Data => \@_,
	    # Execution => $execution,
	   );
       } elsif ($ENV{AUTO_LEGACY_TEST_MODE} eq 'test') {
	 my $res = $sayer2multiple->Test
	   (
	    CodeRef => $symboltables->{$package}{$functionname},
	    Data => \@_,
	    # Execution => $execution,
	   );
       }
       @_;
     },
     sub {
       my $id = $ENV{AUTO_LEGACY_TEST_ID} || -1;
       print STDERR $fullfunctionname."\n";
       print STDERR "id: $id\n";
       print STDERR "post: ".Dumper({RetVal => \@_});
       print STDERR "</function>\n";
       if ($ENV{AUTO_LEGACY_TEST_MODE} eq 'record') {
	 my $res = $sayer2multiple->RecordResult
	   (
	    CodeRef => $symboltables->{$package}{$functionname},
	    Result => \@_,
	    # Execution => $execution,
	   );
       } elsif ($ENV{AUTO_LEGACY_TEST_MODE} eq 'test') {
	 my $res = $sayer2multiple->Compare
	   (
	    CodeRef => $symboltables->{$package}{$functionname},
	    Result => \@_,
	    # Execution => $execution,
	   );
       }
       @_;
     },
    );
}

InstrumentFunction
  (
   FunctionName => 'TestLowerCase',
  );

print Dumper
  (TestLowerCase
   (
    Item => 'Hello',
   ));
