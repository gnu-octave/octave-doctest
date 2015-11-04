function test_skip_wo_output_diary()
%
% No output here, so this code block should be skipped:
% >> a = 5;          % doctest: +SKIP_BLOCKS_WO_OUTPUT
% .. assert(false);
%
%
% this one should still happen
% >> a = 5;          % doctest: +SKIP_BLOCKS_WO_OUTPUT
% .. a = 6
% a = 6
%
