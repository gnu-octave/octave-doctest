function test_whitespace()
% >> disp('a   b')    % doctest: -NORMALIZEWHITESPACE
% a   b
%
% >> disp('a   b')    % doctest: +NORMALIZEWHITESPACE
% a b
% >> disp('a   b')    % doctest: +NORMALIZEWHITESPACE
% a       b
%
%
% Indenting is ok:
%
% >> disp('a   b')    % doctest: -NORMALIZEWHITESPACE
%
%    a   b
%
%
% But this should fail:
%
% >> disp('a   b')    % doctest: -NORMALIZEWHITESPACE   % doctest: +XFAIL
%
%    a b
%
%
% Multiline: Matlab and Octave format matrices differently but a
% column vector is safe to use in cross-platform tests.
%
% >> A = [1; 2; -3]   % doctest: -NORMALIZEWHITESPACE
% A =
%   1
%   2
%  -3
%
% >> A                % doctest: -NORMALIZEWHITESPACE
%
% A =
%
%     1
%
%     2
%
%    -3
%
%
% Matlab and Octave format differently, even for scalars, so
% make sure our auto "ans = " bit still works.
%
% >> 42                 % doctest: -NORMALIZEWHITESPACE
% 42
%
%
% Note: even very simple scalar tests like "x = 5" are difficult to
% pass in both Octave and Matlab when using -NORMALIZEWHITESPACE.
