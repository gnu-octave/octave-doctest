function test_xfail_if_code()
%
% Initialize a dummy variable a:
% >> a = 3
% a = 3
%
%
% The following test will fail:
% >> a = 5     % doctest: +XFAIL_IF(6 + 0*now() >= 0)
% b = 7
%
%
% Check that it has been executed:
% >> a
% a = 5
%
%
% This test succeeds and should not fail:
% >> a    % doctest: +XFAIL_IF(str2num("17") > 20)
% a = 5
