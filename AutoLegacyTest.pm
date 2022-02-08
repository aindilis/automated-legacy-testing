package AutoLegacyTest;

$UNIVERSAL::debug = 1;

use AutoLegacyTest::Lists;
use Sayer2;

use Data::Dumper;
use Hook::PrePostCall;
use String::ShellQuote qw(shell_quote);
use Symbol::Table;

# FIXME: autocompute the white and black lists either by running the
# program once without anything else and caching the result, or
# possibly using PPI to parse

my $symboltables = {};
my $functions = {};
my $seen = {};

my $sayer2 = Sayer2->new(DBName => 'sayer2_test');
$sayer2->Debug(1);

sub PopulateData {
  my (%args) = @_;
  # print Dumper({BlackList => Blacklist()});
  return unless $ENV{AUTO_LEGACY_TEST_RUNNING} == 1;
  my @packages = (['main']);
  while (@packages) {
    my $packagelist = shift @packages;
    my $package = join('::',@$packagelist);

    # apply whitelist and blacklist here

    if (! exists $seen->{$package} and
	(! exists Blacklist()->{$package} or
	 exists Whitelist()->{$package})) {
      $seen->{$package} = 1;
      $symboltables->{$package} = Symbol::Table ->New('PACKAGE', $package);
      $functions->{$package} = Symbol::Table->New('CODE', $package);
      foreach my $function (sort keys(%{$symboltables->{$package}})) {
	my @list = @$packagelist;
	push @list, $function;
	push @packages, \@list;
      }
    }
  }
}

sub InstrumentFunctions {
  my (%args) = @_;

  # make a whitelist and a blacklist

  # make a list of packages to test

  my $arrayofargs = {};
  foreach my $package (sort keys %$symboltables) {
    foreach my $function (sort keys %{$functions->{$package}}) {
      # if ($function ne "DESTROY" and $function ne "Dumper") {
      if (
	  $function ne "DESTROY" and

	  $function ne 'min' and
	  $function ne 'GetAllSubstringsLengthLessThanSize' and
	  $function ne 'ExtractMostUsefulTerms' and
	  $function ne 'GenerateRegexFromCycle' and
	  $function ne 'ExtractRegexFromCycles'

	 ) {

	my $fullfunctionname = "${package}::${function}";
	{
	  $arrayofargs->{$fullfunctionname} = ();
	  my $test3 =
	    Hook::PrePostCall->new
	      (
	       $fullfunctionname,
	       sub {
		 my @args;
		 if (wantarray()) {
		   # list context
		   @args = @_;
		 }
		 elsif (defined wantarray()) {
		   # scalar context
		   @args = [$_];
		 }
		 else {
		   # void context
		 }
		 push @{$arrayofargs->{$fullfunctionname}}, \@args;

		 my $id = $ENV{AUTO_LEGACY_TEST_ID} || -1;
		 print STDERR "Call:\n" if $UNIVERSAL::debug;
		 print STDERR "<function>\n" if $UNIVERSAL::debug;
		 print STDERR "id: $id\n" if $UNIVERSAL::debug;
		 print STDERR 'caller: '.((caller(0))[3])."\n" if $UNIVERSAL::debug;
		 print STDERR 'function: '.$fullfunctionname."\n" if $UNIVERSAL::debug;
		 print STDERR "pre: ".Dumper({Args => \@args}) if $UNIVERSAL::debug;
		 print STDERR "\n" if $UNIVERSAL::debug;
		 # if ($ENV{AUTO_LEGACY_TEST_MODE} eq 'record') {


		 #   # look into the sayer2 cache to see if we get the
		 #   # expected result for this data point

		 #   # does the data point exist in the cache

		 #   # if it isn't the same, mark the function as being
		 #   # nondeterministic

		 # } elsif ($ENV{AUTO_LEGACY_TEST_MODE} eq 'test') {
		 #   # look into the sayer2 cache to see if we get the
		 #   # expected result for this data point

		 #   # does the data point exist in the cache

		 # }
		 @_;
	       },
	       sub {
		 my @retval = @_;
		 my @args = @{pop @{$arrayofargs->{$fullfunctionname}}};
		 print STDERR "Return:\n" if $UNIVERSAL::debug;
		 print STDERR $fullfunctionname."\n" if $UNIVERSAL::debug;
		 print STDERR "post: ".Dumper
		   ({
		     RetVal => \@retval,
		     Args => \@args,
		    }) if $UNIVERSAL::debug;
		 print STDERR "</function>\n" if $UNIVERSAL::debug;
		 if ($sayer2) {
		   my $coderef = $fullfunctionname;
		   print Dumper
		     ({
		       Sayer2 => $sayer2->ExecuteCodeOnData
		       (
			CodeRef => $coderef,
			Data => \@args,
			Result => \@retval,
			Overwrite => 1,
		       )});
		   print "<<<".$coderef."(".join(",",map {shell_quote($_)} @args).") = [".join(",",map {shell_quote($_)} @retval)."];>>>\n";
		 }
		 # @args = ();
		 my $s = scalar @retval;
		 if (wantarray) {
		   return @retval;
		 } else {
		   return $retval[0];
		 }
	       }
	      );
	}
      }
    }
  }

  # # now what we should do here, is 
  # # PrePostHook/Sayer2 stuff here
  # print Dumper
  #   ({
  #     Seen => $seen,
  #     MainFunctions => $functions->{'main'},
  #    });

}

      # if (! exists $self->HasBeenInitialized->{$key}) {

      # 	# check Sayer2 to see if it's in the cache so we don't have to
      # 	# bother initializing at least for now
      # 	my $res = $sayer2->ExecuteCodeOnData
      # 	  (
      # 	   GiveHasResult => 1,
      # 	   CodeRef => $self->Codes->{$key},
      # 	   Data => [{
      # 		     Text => $args{Text},
      # 		     Date => $args{Date},
      # 		    }],
      # 	   Overwrite => (exists $overwrite->{$key} or exists $overwrite->{_ALL}),
      # 	   NoRetrieve => $args{NoRetrieve},
      # 	   Skip => $args{Skip},
      # 	  );
      # 	print Dumper({RawResults => $res}) if $args{Debug};
      # 	if ($res->{Success}) {
      # 	  $results->{$key} = $res->{Result};
      # 	  $complete = 1;
      # 	} else {
      # 	  print "Initializing $key\n";
      # 	  if (exists $self->Inits->{$key}) {
      # 	    &{$self->Inits->{$key}}($self);
      # 	  }
      # 	  $self->HasBeenInitialized->{$key} = 1;
      # 	}
      # }
      # if (! $complete) {
      # 	$results->{$key} =
      # 	  [
      # 	   $sayer2->ExecuteCodeOnData
      # 	   (
      # 	    CodeRef => $self->Codes->{$key},
      # 	    Data => [{
      # 		      Text => $args{Text},
      # 		      Date => $args{Date},
      # 		     }],
      # 	    Overwrite => (exists $overwrite->{$key} or exists $overwrite->{_ALL}),
      # 	    NoRetrieve => $args{NoRetrieve},
      # 	    OnlyRetrieve => $args{OnlyRetrieve},
      # 	    Skip => $args{Skip},
      # 	   ),
      # 	  ];
      # 	$self->IsCached->{$key} = $sayer2->IsCached();

PopulateData();
InstrumentFunctions();

1;


# some things this is going to want to do

# automated code converage analysis

# path quantifiers

# call graph mapping

# version control integration

# automated continuous integration testing


