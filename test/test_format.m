% Default number formatting
% >> a = 1.3
% a =  1.3000
%
%
% If tests change it...
% >> format long
% >> b = 1/6
% b = 0.166666666...7
%
%
% ... they should change it back to defaults
% >> format()
% >> a
% a =  1.3000
%
%
% TODO: should test that we restore the users settings, but probably
% Issue #184 prevents doing this within our doctests.
