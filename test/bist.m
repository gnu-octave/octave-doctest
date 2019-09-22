function bist()
% built-in self tests for Doctest
%
% Doctest mostly tests itself but in some cases we want to ensure
% exactly what is being tested and yet we cannat call doctest recursively
% https://github.com/catch22/octave-doctest/issues/184
%
% Copyright (c) 2019 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause

end


%!error <Invalid> doctest ()
%!error <Invalid> [a, b, c, d] = doctest ('double')

%!assert (doctest ('doctest', '-quiet'))

%!assert (~ doctest ('there_is_no_such_file', '-quiet'))

%!assert (~ doctest ('@there_is_no_such_class', '-quiet'))

%!assert (~ doctest ({'doctest', 'there_is_no_such_file'}, '-quiet'))

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

%!test
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
%! % monkey-patching methods to existing builtin-objects
%! [nump, numt, summ1] = doctest ('logical');
%! % First, there is (at least) the "logical" builtin
%! % >= b/c of https://github.com/catch22/octave-doctest/issues/87
%! assert (summ1.num_targets >= 1)
%! savepath = addpath ('test_methods_in_subdir');
%! % there should be at least "logical" builtin and "logical.mynewmethod"
%! [nump, numt, summ] = doctest ('logical');
%! assert (summ.num_targets >= 2)
%! assert (summ.num_targets >= summ1.num_targets)
%! assert (nump >= 3 && numt >= 3)
%! path(savepath);


%!function y = foo (x)
%!  % >> foo (2)
%!  % 4
%!  % >> foo (10)
%!  % 20
%!  y = 2*x;
%!endfunction

%!assert (doctest ('foo', '-quiet'))

%!test
%! [n, t, summ] = doctest ('foo');
%! assert (n == 2)
%! assert (t == n)
%! assert (summ.num_targets == 1)

%!function y = bar (x)
%!  % >> bar (2)
%!  % 42
%!  % >> bar (3)
%!  % 3
%!  y = x;
%!endfunction

%!test
%! [n, t, summ] = doctest ('bar');
%! assert (n == 1)
%! assert (t == 2)
