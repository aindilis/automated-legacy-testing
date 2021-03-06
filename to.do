((mkdir /home/andrewdo/perl5/perlbrew/perls/perl-5.28.1_WITH_THREADS/lib/site_perl/5.28.1/x86_64-linux-thread-multi/Hook/)
 (cp ./Hook/PrePostCall.pm /home/andrewdo/perl5/perlbrew/perls/perl-5.28.1_WITH_THREADS/lib/site_perl/5.28.1/x86_64-linux-thread-multi/Hook/))

(if (the function is called with the same inputs twice)
 (if (the results are the same)
  (it is possibly det)
  (else it is necessarily nondet))
 (it is possibly nondet))

(can try to make tests small, by omitting large text data)
(look at how aop-swipl did it)


(Is anyone aware of a system that takes a perl program, and
 instruments the function calls in order to memoize the calls,
 builds a database of objects being passed to these calls, and
 generates test cases for the functions using the arguments and
 results, so that during execution of a program, one need only
 perform all the important operations, and provided that they are
 implemented correctly, can obtain a useful set of insufficient
 tests for capturing the behavior of the code, so as to bring
 legacy systems into test, and ultimately sift through the calls
 for possible test cases, weeding out extraneous or unilluminating
 examples.)

(see icodebase-testing)

(note that I have some ideas for how to get sayer to work with
 this correctly.  Basically, we can use a compression table over
 data entries, and have sayer entries consisting of data, usually
 deeply dumped perl data structures, and pointers to existing
 versions of subcomponents.  Or we could use Dumpers existing
 indexing mechanism and link them to existing entries as needed.
 Then, what we do is to take an md5 sum of the given item, or its
 length or other derivable properties, expressed via a function
 application, as in "(equal (md5 item) 'klefkjfds')" 
 (or whatever perl equivalent would be), and use that to index
 the items.  Then we can assert things about the data stored in
 the system, such as that we've seen it repeatedly for a given
 function invocation.  Basically I have to rewrite sayer here, so
 that it works well with this notion of using multiple data
 points per function.  We should be even to watch data flowing
 through programs as a result.  Compress the data that we record.
 Prove things about it.)

(okay, in just rereading this, I realize that we should have things
 that work like path quantifiers over the histories of functions, and
 then that goes into the logic.  These may need to be defeasible. (not
 sure if ACL2 can handle that.) But the logics should be stored in the
 system as well.  Maybe, Flora-2, or maybe some kind of modal
 semantics where the truth value depends on the index i, which indexes
 function invocations.)
