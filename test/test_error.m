function test_error()
%
% Copyright (c) 2019 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause
%
% >> a = 42
% a = 42
%
%
% >> 2 + (1 + !))   % doctest: +XFAIL_IF(DOCTEST_MATLAB)
% parse error:
%
% syntax error
% >>> 2 + (1 + !))   % doctest: +XFAIL_IF(DOCTEST_MATLAB)
%               ^
%
%
% Annoyingly, we the doctest directive is still there and
% appears in the error mesage.  Perhaps we should move these
% tests to bist.m.
%
% >> 2 + (1 + !))   % doctest: +XFAIL_IF(DOCTEST_MATLAB)
% parse error:
%
% syntax error
% >>> 2 + (1 + !))   % doctest: +XFAIL_IF(DOCTEST_MATLAB)
%               ^
% >> a = 43
% a = 43
