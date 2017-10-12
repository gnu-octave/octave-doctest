function test_clear_all_first()
% If we "clear all" very early, our implementation may break if
% subfunctions haven't yet been called.  At least on Octave 4.2.1.
% >> clear all
% >> a
% ??? ...ndefined ...
%
%
% >> a = 6
% a =  6
