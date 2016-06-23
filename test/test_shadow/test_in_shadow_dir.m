function test_in_shadow_dir(x)
% this test is in a directory shadowed/shadowing both a class
% and an m-file.  Its probably not entirely well-posed what
% should happen here but on Octave at least, you can doctest
% all three.
%
% >> a = 4
% a = 4
% >> a = 5
% a = 5
% >> a = 6
% a = 6
