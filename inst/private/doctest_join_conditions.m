function result = doctest_join_conditions(conditions)
%DOCTEST_JOIN_CONDITIONS  Used internally by doctest.
%
% Usage:
%   doctest_join_conditions(conditions)
%       Given a cell array of conditions (represented as strings to be eval'ed),
%       return the string that corresponds to their logical "or".

%%
% Copyright (c) 2015, 2017 Michael Walter
% This is Free Software, BSD-3-Clause, see doctest.m for details.


if isempty(conditions)
  result = 'false';
else
  result = strcat('(', strjoin(conditions, ') || ('), ')');
end

end
