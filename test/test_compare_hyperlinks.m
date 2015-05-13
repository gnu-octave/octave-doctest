function test_compare_hyperlinks()
% There are some tricky things that Matlab does to strings, such as adding
% hyperlinks to help. We remove those before comparison, as verified by the
% following doctest:
%
% >> disp('Hi there!  <a href="matlab:help help">foo</a>')
% Hi there!  foo
