function test_ellipsis_match_whitespace()
% >> disp('    def')
% ... def
%
% >> disp('def     ')
% def ...
%
%
% Whitespace in middle
% >> disp('abc    def')
% abc ... def
% >> disp('abc  def')
% abc ... def
% >> disp('abc def')
% abc...def
