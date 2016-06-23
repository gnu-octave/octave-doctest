function test_comments_with_directives()
% >> a = 6         %doctest: +XFAIL               % comment (with parenthetical)
% b = 5
%
%
% >> a = 7         % doctest: +XFAIL_IF (true)    % comment
% b = 5
%
%
% >> a = 8         % doctest: +XFAIL_IF (false)   % comment (with parenthetical)
% a = 8
