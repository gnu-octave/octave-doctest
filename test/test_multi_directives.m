function test_multi_directives()
% Dummy:
% >> z = 0;
%
%
% Will fail if we do not skip
% >> s = 'a   b'         % doctest: +SKIP_IF (1 > 0)  % doctest: -NORMALIZE_WHITESPACE
% .. z = 1;
% s = a b
%
%
% and we did skip
% >> z
% z = 0
%
%
%
% Will fail if we do not skip
% >> s = 'a   b'         % my comment  % doctest: -NORMALIZE_WHITESPACE  % doctest: +SKIP_IF (true)   % other comment
% .. z = 2;
% s = a b
%
%
% and we did skip:
% >> z
% z = 0
%
%
%
% >> s = 'a ...23   b'   % doctest: -ELLIPSIS  % doctest: +NORMALIZE_WHITESPACE  % doctest: +XFAIL
% .. z = 3;
% s = a ... b
%
%
% >> z
% z = 3
