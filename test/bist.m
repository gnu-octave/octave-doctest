function bist()
% built-in self tests for Doctest
%
% Doctest mostly tests itself but in some cases we want to ensure
% exactly what is being tested and yet we cannot call doctest recursively
% https://github.com/gnu-octave/octave-doctest/issues/184
%
% Copyright (c) 2019, 2022-2023, 2025 Colin B. Macdonald
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
%! % maybe not recommended notation for classdef, but works for now...
%! [nump, numt, summ] = doctest ('@test_classdef/amethod');
%! assert (nump == 1 && numt == 1)

%!xtest
%! % maybe not recommended notation for classdef
%! [nump, numt, summ] = doctest ('@test_classdef/disp');
%! assert (nump == 1 && numt == 1)

%!test
%! % https://github.com/gnu-octave/octave-doctest/issues/92
%! % Should have 4 targets and 5 tests
%! %   * general class help (2 tests)
%! %   * ctor (1 test)
%! %   * disp method (1 test)
%! %   * amethod in external file (1 test)
%! if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!   [nump, numt, summ] = doctest ('test_classdef');
%!   assert (nump == numt && numt >= 4)
%!   assert (summ.num_targets >= 3)
%! end

%!xtest
%! % complicated classdef has correct number of tests and targets
%! % https://github.com/gnu-octave/octave-doctest/issues/268
%! % Now on Octave 9, #268 fixed but it fails in new way:
%! % https://github.com/gnu-octave/octave-doctest/issues/288
%! % (these issues test separately elsewhere)
%! if (compare_versions (OCTAVE_VERSION(), '9.0.0', '>='))
%!   [nump, numt, summ] = doctest ('test_classdef');
%!   assert (nump == numt && numt == 5)
%!   assert (summ.num_targets == 4)
%! end

%!test
%! % https://github.com/gnu-octave/octave-doctest/issues/268
%! if (compare_versions (OCTAVE_VERSION(), '9.0.0', '>='))
%!   [nump, numt, summ] = doctest ('classdef_infile.classdef_infile');
%!   assert (nump == numt && numt == 1)
%!   assert (summ.num_targets == 1)
%! end

%!test
%! % https://github.com/gnu-octave/octave-doctest/issues/268
%! if (compare_versions (OCTAVE_VERSION(), '9.0.0', '>='))
%!   [nump, numt, summ] = doctest ('test_classdef.test_classdef');
%!   assert (nump == numt && numt == 1)
%!   assert (summ.num_targets == 1)
%! end

%!test
%! %% Issue #220, Issue #261, clear and w/o special order or workarounds
%! if (compare_versions (OCTAVE_VERSION(), '7.0.0', '>='))
%!   clear classes
%!   [numpass, numtest, summary] = doctest ('test_classdef');
%!   assert (numpass == numtest)
%!   assert (summary.num_targets >= 3)
%! end

%!test
%! %% Issue #220, workarounds for testing classdef are sensitive to
%! % the order of tests above.  Here we clear first.  But we "preload"
%! % some methods as a workaround.
%! if (compare_versions (OCTAVE_VERSION(), '4.4.0', '>='))
%!   clear classes
%!   if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!     doc = help ('@test_classdef/amethod');
%!     assert (length (doc) > 10)
%!     % dot notation broken before Octave 6
%!     doc = help ('test_classdef.disp');
%!     assert (length (doc) > 10)
%!   end
%!   % doctest ('test_classdef')
%!   [numpass, numtest, summary] = doctest ('test_classdef');
%!   assert (numpass == numtest)
%!   if (compare_versions (OCTAVE_VERSION(), '4.4.0', '>='))
%!     assert (summary.num_targets_without_tests <= 2)
%!   end
%!   if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!     assert (summary.num_targets_without_tests <= 1)
%!   end
%!   % glorious future!  Issue #261
%!   % if (compare_versions (OCTAVE_VERSION(), 'X.Y.Z', '>='))
%!   %   assert (summary.num_targets_without_tests == 0)
%!   % end
%! end


%!test
%! % maybe not recommended notation for classdef, but currently at least no error
%! % https://github.com/gnu-octave/octave-doctest/issues/199
%! [nump, numt, summ] = doctest ('@classdef_infile/disp');
%! assert (nump >= 0)

%!xtest
%! % maybe not recommended notation for classdef
%! [nump, numt, summ] = doctest ('@classdef_infile/disp');
%! assert (nump == 1 && numt == 1)

%!test
%! % https://github.com/gnu-octave/octave-doctest/issues/92
%! % Should have 3 targets and 4 tests
%! %   * general class help (2 tests)
%! %   * ctor (1 test)
%! %   * disp method (1 test)
%! if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!   [nump, numt, summ] = doctest ('classdef_infile');
%!   assert (nump == numt && numt >= 3)
%!   assert (summ.num_targets >= 2)
%! end

%!test
%! % https://github.com/gnu-octave/octave-doctest/issues/268
%! if (compare_versions (OCTAVE_VERSION(), '9.0.0', '>='))
%!   [nump, numt, summ] = doctest ('classdef_infile');
%!   assert (summ.num_targets == 3)
%!   assert (nump == numt && numt == 4)
%! end

%!test
%! % monkey-patching methods to existing builtin-objects
%! [nump, numt, summ1] = doctest ('logical');
%! % First, there is (at least) the "logical" builtin
%! % >= b/c of https://github.com/gnu-octave/octave-doctest/issues/87
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

%!test
%! [n, t, summ] = doctest({});
%! assert (n == 0)
%! assert (t == 0)
%! assert (summ.num_targets == 0)

%!test
%! % skip empty targets
%! [n, t, summ] = doctest({'', ''});
%! assert (n == 0)
%! assert (t == 0)
%! assert (summ.num_targets == 0)
%! assert (summ.num_targets_with_extraction_errors == 0)

%!test
%! % skip empty targets
%! [n1, t1, summ1] = doctest('doctest');
%! [n2, t2, summ2] = doctest({'', '', 'doctest', ''});
%! assert (n1 == n2)
%! assert (t1 == t2)
%! assert (summ1.num_targets == summ2.num_targets)
%! assert (summ2.num_targets_with_extraction_errors == 0)

%!test
%! % correct number of tests
%! [n, t, summ] = doctest('test_tab_before_prompt');
%! assert (n == 2)

%!test
%! % correct number of error tests
%! [n, t, summ] = doctest('test_error');
%! assert (t == 7)

%!test
%! % class inside a package
%! if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!   [n, t, summary] = doctest ("containers.Map");
%!   assert (n == t)
%!   assert (summary.num_targets >= 10)  % lots of methods
%! end

%!test
%! % classdef.method
%! if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!   [n, t, summary] = doctest ("test_classdef.disp");
%!   assert (n == t)
%!   assert (n == 1)
%! end

%!test
%! % classdef.method, where method is external file
%! if ((compare_versions (OCTAVE_VERSION(), '6.0.0', '>=')) && ...
%!     (compare_versions (OCTAVE_VERSION(), '9.0.0', '<')))
%!   [n, t, summary] = doctest ("test_classdef.amethod");
%!   assert (n == t)
%!   assert (n == 1)
%! end
%!xtest
%! % classdef.method, where method is external file
%! % https://github.com/gnu-octave/octave-doctest/issues/288
%! [n, t, summary] = doctest ("test_classdef.amethod");
%! assert (n == t)
%! assert (n == 1)

%!test
%! % classdef.method
%! if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!   [n, t, summary] = doctest ("classdef_infile.disp");
%!   assert (n == t)
%!   assert (n == 1)
%! end

%!test
%! % classdef handle subclass delete behaviour
%! if (compare_versions (OCTAVE_VERSION(), '9.0.0', '>='))
%!   [n, t, summary] = doctest ('cdef_subhandle1');
%!   assert (n == t)
%!   assert (n == 4)
%!   assert (summary.num_targets_with_extraction_errors == 0)
%! end

%!test
%! % classdef handle subclass delete behaviour
%! if (compare_versions (OCTAVE_VERSION(), '9.0.0', '>='))
%!   [n, t, summary] = doctest ('cdef_subhandle2');
%!   assert (n == t)
%!   assert (n == 3)
%!   assert (summary.num_targets_with_extraction_errors == 0)
%! end
