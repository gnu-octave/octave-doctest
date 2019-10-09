function test_clear()
% Easy things first, clearing one variable
% >> a = 6;
% >> b = 7;
% >> clear a
% >> b
% b =  7
% >> a
% ...ndefined ...
%
%
% Harder:
% >> clear
% >> a
% ...ndefined ...
%
%
% >> a = 4
% a = 4
%
%
% "clear all" clears stuff inside persistent vars
% >> clear all
% >> a
% ...ndefined ...
%
%
% >> a = 5
% a = 5
