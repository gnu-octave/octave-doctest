function formatted = doctest_format_exception(ex)
%DOCTEST_FORMAT_EXCEPTION  Used internally by doctest.
%
% Usage:
%   doctest_format_exception(ex)
%       Given an exception, return error message to be reported.

%%
% Copyright (c) 2010 Thomas Grenfell Smith
% Copyright (c) 2015, 2019 Colin B. Macdonald
% Copyright (c) 2015, 2017 Michael Walter
% This is Free Software, BSD-3-Clause, see doctest.m for details.


% octave?
if is_octave()
  formatted = ['??? ' strtrim(ex.message)];
  return
end

% matlab!
if strcmp(ex.stack(1).name, 'doctest_run_tests')
  % we don't want the report, we just want the message
  % otherwise it'll talk about evalc, which is not what the user got on
  % the command line.
  formatted = ['??? ' ex.message];
else
  formatted = ['??? ' ex.getReport('basic')];
end

end
