function test_error()
% The syntax changed a bit between Octave 9 and 10.  We define some
% variables to make it easier to test both.
%
% >> OLD_OCTAVE = is_octave() && compare_versions (ver ("octave").Version, "10.0.0", "<");
% >> NEW_OCTAVE = is_octave() && compare_versions (ver ("octave").Version, "10.0.0", ">=");
% >> a = 42
% a = 42
%
%
% >> 3 + (1 + !))   % doctest: +XFAIL_UNLESS(NEW_OCTAVE)
%
% syntax error
% >>> 3 + (1 + !))   % doctest: +XFAIL_UNLESS(NEW_OCTAVE)
%               ^
% >> a = a + 1
% a = 43
%
%
% Annoyingly, the doctest directive is still there and
% appears in the error mesage.  Perhaps we should move these
% tests to bist.m.
%
% >> 4 + (1 + !))   % doctest: +XFAIL_UNLESS(OLD_OCTAVE)
%
% parse error:
%
% syntax error
% >>> 4 + (1 + !))   % doctest: +XFAIL_UNLESS(OLD_OCTAVE)
%               ^
%
% >> a = a + 1
% a = 44
%
%
% Caution: the file "bist.m" cares about how many tests are in this test_error.m file!
%
% Copyright (c) 2019, 2022, 2025 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause
