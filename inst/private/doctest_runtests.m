function DOCTEST__results = doctest_runtests(DOCTEST__tests)
%DOCTEST_RUNTESTS - used internally by doctest
%
% Usage:
%   doctest_runtests(tests)
%       Carefully evaluate each test in the "tests" structure in
%       a common newly-created clean namespace (specifically, this
%       functions workspace).
%
% The input is a structure with various fields including "tests.source",
% the code to be run and "tests.want" the expected output.  Various
% other flags such as "tests.xfail" and "tests.ellipsis" effect how
% the test is run and how the test output is compared.
%
% The return value is documented in "doctest_docstring".

% Implementation note: all variables should start with
% "DOCTEST__" as these will be available to the tests.

% do not split long rows (TODO: how to do this on MATLAB?)
if is_octave()
  split_long_rows(0, 'local')
end

% define test-global constants (these are accessible by the tests)
DOCTEST_OCTAVE = is_octave();
DOCTEST_MATLAB = ~DOCTEST_OCTAVE;

DOCTEST__results = [];
for DOCTEST__i = 1:numel(DOCTEST__tests)
  DOCTEST__result = DOCTEST__tests(DOCTEST__i);

  % determine whether test should be skipped
  % (careful about Octave bug #46397 to not change the current value of “ans”)
  eval (strcat ('DOCTEST__result.skip = ', ...
                 DOCTEST__join_conditions (DOCTEST__result.skip), ...
                ';'));
  if (DOCTEST__result.skip)
     continue
  end

  % determine whether test is expected to fail
  % (careful about Octave bug #46397 to not change the current value of “ans”)
  eval (strcat ('DOCTEST__result.xfail = ', ...
                 DOCTEST__join_conditions (DOCTEST__result.xfail), ...
                ';'));

  % evaluate input (structure adapted from a StackOverflow answer by user Amro, see http://stackoverflow.com/questions/3283586 and http://stackoverflow.com/users/97160/amro)
  try
    DOCTEST__result.got = evalc(DOCTEST__result.source);
  catch DOCTEST__exception
    DOCTEST__result.got = DOCTEST__format_exception(DOCTEST__exception);
  end

  % determine if test has passed
  DOCTEST__result.passed = doctest_compare(DOCTEST__result.want, DOCTEST__result.got, DOCTEST__result.normalize_whitespace, DOCTEST__result.ellipsis);
  if DOCTEST__result.xfail
    DOCTEST__result.passed = ~DOCTEST__result.passed;
  end

  DOCTEST__results = [DOCTEST__results; DOCTEST__result];
end

end


function formatted = DOCTEST__format_exception(ex)

  if is_octave()
    formatted = ['??? ' ex.message];
    return
  end

  if strcmp(ex.stack(1).name, 'DOCTEST__run_impl')
    % we don't want the report, we just want the message
    % otherwise it'll talk about evalc, which is not what the user got on
    % the command line.
    formatted = ['??? ' ex.message];
  else
    formatted = ['??? ' ex.getReport('basic')];
  end
end


% given a cell array of conditions (represented as strings to be eval'ed),
% return the string that corresponds to their logical "or".
function result = DOCTEST__join_conditions(conditions)
  if isempty(conditions)
    result = 'false';
  else
    result = strcat('(', strjoin(conditions, ') || ('), ')');
  end
end
