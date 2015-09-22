function test_skip_unless()
% This test should have 4 passing tests.
%
% Set up flags that determine test skipping.
% >> my_true_flag = 1;
% >> my_false_flag = 0;
%
%
% A test that would fail:
% >> a = 5  % doctest: +SKIP_UNLESS(my_false_flag)
% b = 7
%
%
% And a passing one:
% >> a = 6  % doctest: +SKIP_UNLESS(my_true_flag)
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
% ..      3 4]    % doctest: +SKIP_UNLESS(my_false_flag)
% A = 42
%
% >> A = [1 2;    % doctest: +SKIP_UNLESS(my_false_flag)
% ..      3 4]
% A = 42
