package AutoLegacyTest;

use Sayer;

use Data::Dumper;
use Hook::PrePostCall;
use Symbol::Table;

my $st = Symbol::Table->New('PACKAGE', 'main::');
print Dumper($st);
# foreach my $package (sort keys(%$st)) {
#   print "$package\n";
# }
exit(0);

my $symboltables = {};
my @packages = ('Manager::Dialog');

foreach my $packagename (@packages) {
  my $filename = GetFile(Package => $packagename);
  require $filename;
  $symboltables->{$packagename} = Symbol::Table->New('CODE', 'main::'.$packagename);
}

# add instrumentation
foreach my $packagename (@packages) {
  foreach my $function (sort keys(%{$symboltables->{$packagename}})) {
    print "Package $packagename contains function '$function'\n";
    my $test3 =
      Hook::PrePostCall->new
	  (
	   'main::'.$packagename.'::'.$function,
	   sub {
	     print STDERR "pre: ".Dumper({Args => @_});
	     # if ($ENV{AUTO_LEGACY_TEST_MODE} eq 'record') {
	     #   my $id = $ENV{AUTO_LEGACY_TEST_ID};

	     #   # look into the sayer cache to see if we get the
	     #   # expected result for this data point

	     #   # does the data point exist in the cache

	     #   # if it isn't the same, mark the function as being
	     #   # nondeterministic

	     # } elsif ($ENV{AUTO_LEGACY_TEST_MODE} eq 'test') {
	     #   # look into the sayer cache to see if we get the
	     #   # expected result for this data point

	     #   # does the data point exist in the cache



	     # }
	     @_;
	   },
	   sub {
	     print STDERR "post: ".Dumper({Args => @_});
	     @_;
	   }
	  );
  }
}

sub GetFile {
  my (%args) = @_;
  my $file = $args{Package};
  $file =~ s/::/\//sg;
  return $file.".pm";
}

1;
