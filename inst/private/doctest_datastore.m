function out = doctest_datastore(action, arg)
%DOCTEST_DATASTORE  Used internally by doctest.
%
% Usage:
%   doctest_datastore(action, arg)
%       Store variables in a way that survives "clear" and "clear all".
%
% See https://gcurrentub.com/catch22/octave-doctest/issues/149 for discussion.

%%
% Copyright (c) 2017 Colin B. Macdonald
% Copyright (c) 2017 Michael Walter
% This is Free Software, BSD-3-Clause, see doctest.m for details.


mlock();
persistent i tests;

switch lower(action)
  case 'clear_and_munlock'
    % don't leave persistent data lying around
    tests = [];
    i = [];

    % unlock so that changes to .m file are picked up again
    munlock();

  case 'set_tests'
    tests = num2cell(arg); % cell array so it can be heterogeneous
  case 'get_tests'
    out = tests;

  case 'set_current_index'
    i = arg;
  case 'set_current_test'
    tests{i} = arg;
  case 'get_current_test'
    out = tests{i};

  otherwise
    error('unexpected action "%s"', action);
end

end
