function bist()
% built-in self tests for Doctest
%
% Doctest mostly tests itself but in some cases we want to ensure
% exactly what is being tested and yet we cannat call doctest recursively
% https://github.com/catch22/octave-doctest/issues/184
%
% The output is rather noisy: perhaps evalc could make it less verbose?

end


%!error <Invalid> doctest ()
%!error <Invalid> [a, b, c, d] = doctest ('double')

%!assert (doctest ('doctest', '-quiet'))

%!assert (~ doctest ('there_is_no_such_file', '-quiet'))

%!assert (~ doctest ({'doctest', 'there_is_no_such_file'}, '-quiet'))

%!error
%! % TODO: maybe this should be EXTRACTION_ERROR, not raise an error...
%! doctest @there_is_no_such_class -quiet

%!test
%! [n, t] = doctest ('doctest', '-quiet');
%! assert (n == t)
%! assert (t >= 10)

%!test
%! [n, t, summ] = doctest ('doctest');
%! assert (n == t)
%! assert (t >= 10)
%! assert (summ.num_targets == 1)
%! assert (summ.num_tests == t)
%! assert (summ.num_tests_passed == n)

%!test
%! % list input
%! [n, t1, summ] = doctest ({'doctest'});
%! [n, t2, summ] = doctest ({'doctest' 'doctest'});
%! assert (t2 == 2*t1)
%! assert (summ.num_targets == 2)

%!test
%! % nonrecursion stays out of subdirs
%! [n1, t1] = doctest ('test_dir', '-quiet');
%! [n2, t2] = doctest ('test_dir', '-nonrecursive', '-quiet');
%! assert (t2 < t1)

%!test
%! [nump, numt, summ] = doctest ('@test_classdef/amethod');
%! assert (nump == 1 && numt == 1)

%!xtest
%! % https://github.com/catch22/octave-doctest/issues/92
%! [nump, numt, summ] = doctest ('@test_classdef/disp');
%! assert (nump == 1 && numt == 1)

%!xtest
%! % https://github.com/catch22/octave-doctest/issues/92
%! % Should have 4 targets and 5 tests
%! %   * general class help (2 tests)
%! %   * ctor (1 test)
%! %   * disp method (1 test)
%! %   * amethod in external file (1 test)
%! [nump, numt, summ] = doctest ('test_classdef');
%! assert (nump == 5 && numt == 5)
%! assert (summ.num_targets == 4)

%!xtest
%! % Currently cannot even run
%! % https://github.com/catch22/octave-doctest/issues/199
%! [nump, numt, summ] = doctest ('@classdef_infile/disp');
%! assert (nump >= 0)

%!xtest
%! % https://github.com/catch22/octave-doctest/issues/92
%! [nump, numt, summ] = doctest ('@classdef_infile/disp');
%! assert (nump == 1 && numt == 1)

%!xtest
%! % https://github.com/catch22/octave-doctest/issues/92
%! % Should have 3 targets and 4 tests
%! %   * general class help (2 tests)
%! %   * ctor (1 test)
%! %   * disp method (1 test)
%! [nump, numt, summ] = doctest ('classdef_infile');
%! assert (nump == 4 && numt == 4)
%! assert (summ.num_targets == 3)

%!test
%! % monkey patching methods to existing builtin-objects
%! % TODO: need to test (and fix?) this if `@logical` is not in pwd
%! [nump, numt, summ] = doctest ('logical');
%! % there should be at least "logical" and "logical.mynewmethod"
%! % >= b/c of https://github.com/catch22/octave-doctest/issues/87
%! assert (summ.num_targets >= 2)
%! assert (nump >= 3 && numt >= 3)
