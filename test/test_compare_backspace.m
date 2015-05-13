function test_compare_backspace()
% Matlab appears to emit backspace characters (0x08) for no apparent reason.
% This doctest verifies that backspace characters are correctly processed
% before comparison. Note a bit of fuss here because Octave needs this escape
% sequence in double quotes which Matlab won't parse.
%
% >> if (exist('OCTAVE_VERSION'))
% ..   eval('sprintf("Hi, no question mark here?\x08 goodbye")')
% .. else
% ..   sprintf('Hi, no question mark here?\x08 goodbye')
% .. end
%
% ans =
%
% Hi, no question mark here goodbye
%
%
% All of the doctests should pass, and they manipulate this function.
%
