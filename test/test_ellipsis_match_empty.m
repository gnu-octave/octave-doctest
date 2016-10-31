function test_ellipsis_match_empty()
% Ellipses should match empty string:
% >> disp('abcdef')
% abc...def
%
%
% empty at ends:
% >> disp('def')
% ...def
%
% >> disp('def')
% def...
%
%
% Empty and whitespace:
% >> disp('abc def')
% abc ...def
%
% >> disp('abc def')
% abc... def
