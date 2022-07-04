function test_error()
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
% Annoyingly, the doctest directive is still there and
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
%
%
% Copyright (c) 2019, 2022 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause
