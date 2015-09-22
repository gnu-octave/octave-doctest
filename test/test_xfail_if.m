function test_xfail_if()
% These flags control our expectations:
% >> my_true_flag = 1;
% >> my_false_flag = 0;
%
%
% Let's initialize our dummy variable a:
% >> a = 3
% a = 3
%
%
% The following test will fail:
% >> a = 5  % doctest: +XFAIL_IF(my_true_flag)
% b = 7
%
%
% Check that it has been executed, though:
% >> a
% a = 5
%
%
% This one should succeed, however:
% >> a  % doctest: +XFAIL_IF(my_false_flag)
% a = 5
