function test_xfail_if_multiple()
% Set up flags that determine test skipping.
% >> false_flag = 0;
% >> true_flag = 1;
% >> z = 3;
%
%
% The following test should succeed
% >> z = 5 % doctest: +XFAIL_IF(false_flag)
% z = 5
%
%
% Check that the first test was executed
% >> z
% z = 5
%
%
% The following test should be fail
% >> z = 7 % doctest: +XFAIL_IF(false_flag) % doctest: +XFAIL_IF(true_flag)
% w = 9
%
%
% Check that the second test was indeed executed
% >> z
% z = 7
