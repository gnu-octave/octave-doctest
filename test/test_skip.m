function y = test_skip()
% This file should have 3 passed tests
%
% A test that would fail:
% >> a = 5  % doctest: +SKIP
% b = 7
%
%
% And a passing one:
% >> a = 6
% a = 6
%
%
% Multiline input:
% >> A = [1 2;
% ..      3 4]    % doctest: +SKIP
% A = 42
%
%
% Put it on any line of multiline input:
% >> A = [1 2;    % doctest: +SKIP
% ..      3 4]
% A = 42
%
%
% Skip means not evaluated
% >> a = 6
% a = 6
% >> a = 5        % doctest: +SKIP
% >> a
% a = 6
