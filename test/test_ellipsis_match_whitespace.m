function test_ellipsis_match_whitespace()
% Whitespace in middle
% >> disp('abc    def')
% abc ... def
% >> disp('abc  def')
% abc ... def
% >> disp('abc def')
% abc...def
%
%
% Should fail: expects something surrounded by whitespace
% >> disp('abc def')   % doctest: +XFAIL
% abc ... def
%
%
% This is ok, because there are two whitespaces in input
% >> disp('abc  def')
% abc ... def
%
%
% Currently, ellipses will match empty the string but we trim begin/end of
% lines, so these probably fail because there is nothing to match the space
% after/before the "...".  Probably ok to change this behaviour.
% >> disp('    def')   % doctest: +XFAIL
% ... def
%
% >> disp('def    ')   % doctest: +XFAIL
% def ...
%
%
% However, these are ok:
% >> disp('def')
% ...def
%
% >> disp('def')
% def...
