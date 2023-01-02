function s = test_matlab_style_utf8()
% Test function with some non-ASCII characters in UTF-8
%
% This file is encoded in UTF-8.  Here is the euro symbol:
% >> s = '€';
% >> disp(s)
% €
% >> disp(test_matlab_style_utf8())
% €
%
%
% Its not our business how this is storied internally (its utf-8
% on Octave, not sure on Matlab).  But we can convert explicitly
% to utf-8:
% >> nums = unicode2native(s, 'utf-8');
% >> double(nums)
%        226   130   172

% Copyright (c) 2022-2023 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause

  s = '€';
end
