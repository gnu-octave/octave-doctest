DOCTEST
  Run examples embedded in documentation
 
  doctest func_name
  doctest('func_name')
  doctest class_name
  doctest('class_name')
 
  Example:
  Say you have a function that adds 7 to things:
      function res = add7(num)
          % >> add7(3)
          %
          % ans =
          %
          %      10
          %
          res = num + 7;
      end
  
  Save that to 'add7.m'.  Now you can say 'doctest add7' and it will run
  'add7(3)' and make sure that it gets back 'ans = 10'.  It prints out
  something like this:
 
  TAP version 13
  1..1
  ok 1 - add7(3)
 
  This is in the Test Anything Protocol format, which I guess is mostly
  used by Perl people, but it's good enough for now.  See testanything.org.
 
  If the output of some function will change each time you call it, for
  instance if it includes a random number or a stack trace, you can put ***
  (three asterisks) where the changing element should be.  This acts as a
  wildcard, and will match anything.  See the example below.
 
  EXAMPLES:
 
  Running 'doctest doctest' will execute these examples and test the
  results.
 
  >> 1 + 3
  
  ans =
  
       4
 
 
  Note the two blank lines between the end of the output and the beginning
  of this paragraph.  That's important so that we can tell that this
  paragraph is text and not part of the example!
 
  If there's no output, that's fine, just put the next line right after the
  one with no output.  If the line does produce output (for instance, an
  error), this will be recorded as a test failure.
 
  >> x = 3 + 4;
  >> x
 
  x =
 
     7
 
 
  Exceptions:
  doctest can deal with errors, a little bit.  For instance, this case is
  handled correctly:
 
  >> not_a_real_function(42)
  ??? Undefined function or method 'not_a_real_function' for input
  arguments of type 'double'.
 
 
  But if the line of code will emit other output BEFORE the error message,
  the current version can't deal with that.  For more info see Issue #4 on
  the bitbucket site (below).  Warnings are different from errors, and they
  work fine.
 
  Wildcards:
  If you have something that has changing output, for instance line numbers
  in a stack trace, or something with random numbers, you can use a
  wildcard to match that part.
 
  >> dicomuid
  1.3.6.1.4.1.***
 
 
  LIMITATIONS:
 
  The examples MUST END with either the END OF THE DOCUMENTATION or TWO
  BLANK LINES (or anyway, lines with just the comment marker % and nothing
  else).
 
  All adjascent white space is collapsed into a single space before
  comparison, so right now it can't detect anything that's purely a
  whitespace difference.
 
  It can't run lines that are longer than one line of code (so, for
  example, no loops that take more than one line).  This is difficult
  because I haven't found a good way to mark these subsequent lines as
  part-of-the-source-code rather than part-of-the-result.
  
  When you're working on writing/debugging a Matlab class, you might need
  to run 'clear classes' to get correct results from doctests (this is a
  general problem with developing classes in Matlab).
 
  It doesn't say what line number/file the doctest error is in.  This is
  because it uses Matlab's plain ol' HELP function to extract the
  documentation.  It wouldn't be too hard to write our own comment parser,
  but this hasn't happened yet.  (See Issue #2 on the bitbucket site,
  below)
 

Result of running 'doctest doctest':
>> doctest doctest
TAP version 13
1..5
ok 1 - "1 + 3"
ok 2 - "x = 3 + 4;"
ok 3 - "x"
ok 4 - "not_a_real_function(42)"
ok 5 - "dicomuid"

