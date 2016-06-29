function test_skip_wo_output_diary()
%
% No output is specified here, so this code block would likely be
% skipped if this was texinfo.  But its not texinfo so this test
% is expected to fail (and its a bug if it does not).
% >> a = 5;          % doctest: +XFAIL
% .. disp('hi')
%
%
% check that previous was not skipped
% >> a
% a = 5
