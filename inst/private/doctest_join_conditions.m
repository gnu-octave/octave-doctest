function result = doctest_join_conditions(conditions)
%DOCTEST_JOIN_CONDITIONS - used internally by doctest
%
% Usage:
%   doctest_join_conditions(conditions)
%       Given a cell array of conditions (represented as strings to be eval'ed),
%       return the string that corresponds to their logical "or".
%

if isempty(conditions)
  result = 'false';
else
  result = strcat('(', strjoin(conditions, ') || ('), ')');
end

end
