function result = doctest_join_conditions(conditions)
%DOCTEST_JOIN_CONDITIONS  Used internally by doctest.
%
% Usage:
%   doctest_join_conditions(conditions)
%       Given a cell array of conditions (represented as strings to be eval'ed),
%       return the string that corresponds to their logical "or".

%%
% Copyright (c) 2015, 2017 Michael Walter
% SPDX-License-Identifier: BSD-3-Clause


if isempty(conditions)
  result = 'false';
else
  result = strcat('(', strjoin(conditions, ') || ('), ')');
end

end
