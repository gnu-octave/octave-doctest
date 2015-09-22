function y = test_skip_if_multiple()
% Set up flags that determine test skipping.
% >> false_flag = 0;
% >> true_flag = 1;
% >> z = 3;
%
%
% The following test should not be skipped
% >> z = 5 % doctest: +SKIP_IF(false_flag)
% z = 5
%
%
% The following test should be skipped (thanks to the second condition)
% >> z = 7 % doctest: +SKIP_IF(false_flag) % doctest: +SKIP_IF(true_flag)
% w = 9
%
% Check that it was indeed skipped:
% >> z
% z = 5
