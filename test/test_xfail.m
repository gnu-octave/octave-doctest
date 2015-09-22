function test_xfail()
% Let's initialize our dummy variable a.
% >> a = 3
% a = 3
%
%
% The following test will fail:
% >> a = 5  % doctest: +XFAIL
% b = 7
%
%
% Check that it has been executed, though:
% >> a
% a = 5
