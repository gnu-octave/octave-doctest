function y = test_skip_if()
% This test should have 4 passing tests.
%
% Set up flags that determine test skipping.
% >> my_true_flag = 1;
% >> my_false_flag = 0;
%
%
% A test that would fail:
% >> a = 5  % doctest: +SKIP_IF(my_true_flag)
% b = 7
%
%
% And a passing one:
% >> a = 6  % doctest: +SKIP_IF(my_false_flag)
% a = 6
%
%
% Check that it was indeed not skipped:
% >> a
% a = 6
%
%
% Multiline examples (put it on any line)
% >> A = [1 2;
% ..      3 4]    % doctest: +SKIP_IF(my_true_flag)
% A = 42
%
% >> A = [1 2;    % doctest: +SKIP_IF(my_true_flag)
% ..      3 4]
% A = 42
