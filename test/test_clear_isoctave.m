function test_clear_isoctave()
% Easy things first, clearing one variable
% >> a = 6
% a =  6
%
%
% >> clear
% >> a
% ??? ...ndefined ...
%
%
% >> clear all
% >> a
% ??? ...ndefined ...
%
%
% Make sure these macros are still available after a clear
% >> a = 42   % doctest: +XFAIL_IF(DOCTEST_OCTAVE | DOCTEST_MATLAB)
% a =  0
