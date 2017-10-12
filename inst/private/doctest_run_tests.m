function DOCTEST__results = doctest_run_tests(DOCTEST__tests)
%DOCTEST_RUN_TESTS - used internally by doctest
%
% Usage:
%   doctest_run_tests(tests)
%       Carefully evaluate each test in the "tests" structure in
%       a common newly-created clean namespace (specifically, this
%       functions workspace).
%
% The input is a structure with various fields including "tests.source",
% the code to be run and "tests.want" the expected output.  Various
% other flags such as "tests.xfail" and "tests.ellipsis" effect how
% the test is run and how the test output is compared.
%
% The return value is documented in "doctest_run_docstring".

% Implementation note: all variables should start with
% "DOCTEST__" as these will be available to the tests.

  % Call subfcns at least once, workaround for test doing early "clear all"
  DOCTEST__join_conditions([]);
  try
    error('meh')
  catch ex
  end
  DOCTEST__format_exception(ex);

% do not split long rows (TODO: how to do this on MATLAB?)
if is_octave()
  split_long_rows(0, 'local')
end

DOCTEST__datastore('set_all', DOCTEST__tests)

for DOCTEST__i = 1:numel(DOCTEST__tests)
  %DOCTEST__result = DOCTEST__tests(DOCTEST__i);
  DOCTEST__datastore('init_i', DOCTEST__i)
  DOCTEST__result = DOCTEST__datastore('get_ith');

  % define test-global constants (these are accessible by the tests)
  DOCTEST_OCTAVE = is_octave();
  DOCTEST_MATLAB = ~DOCTEST_OCTAVE;

  % determine whether test should be skipped
  % (careful about Octave bug #46397 to not change the current value of “ans”)
  eval (strcat ('DOCTEST__result.skip = ', ...
                 DOCTEST__join_conditions (DOCTEST__result.skip), ...
                ';'));
  if (DOCTEST__result.skip)
     DOCTEST__datastore('set_ith', DOCTEST__result);
     continue
  end

  % determine whether test is expected to fail
  % (careful about Octave bug #46397 to not change the current value of “ans”)
  eval (strcat ('DOCTEST__result.xfail = ', ...
                 DOCTEST__join_conditions (DOCTEST__result.xfail), ...
                ';'));
  DOCTEST__datastore('set_ith', DOCTEST__result);

  try
    DOCTEST__got = evalc(DOCTEST__result.source);
  catch DOCTEST__exception
    DOCTEST__got = DOCTEST__format_exception(DOCTEST__exception);
  end
  % pull from datastore (in case test did "clear")
  DOCTEST__result = DOCTEST__datastore('get_ith');
  DOCTEST__result.got = DOCTEST__got;

  % determine if test has passed
  DOCTEST__result.passed = doctest_compare(DOCTEST__result.want, DOCTEST__result.got, DOCTEST__result.normalize_whitespace, DOCTEST__result.ellipsis);
  if DOCTEST__result.xfail
    DOCTEST__result.passed = ~DOCTEST__result.passed;
  end

  %DOCTEST__results = [DOCTEST__results; DOCTEST__result];
  DOCTEST__datastore('set_ith', DOCTEST__result);
end

DOCTEST__results = DOCTEST__datastore('get_all');
DOCTEST__datastore('clear');
end


function out = DOCTEST__datastore(action, var)
  % store variables in a way that survives "clear" and "clear all".

  % try to survive a test doing "clear" and "clear all"
  % https://github.com/catch22/octave-doctest/issues/149
  mlock()
  persistent i results

  switch lower(action)
    case 'clear'
      % don't leave mlocked persistent data lying around
      results = [];
      i = [];
    case 'set_all'
      % cell array so it can be heterogeneous
      results = num2cell(var);
    case 'init_i'
      i = var;
    case 'set_ith'
      results{i} = var;
    case 'get_ith'
      out = results{i};
    case 'get_all'
      % unwrap from cell-array, discarding skips
      %out = cell2mat(results);  % fails b/c they have different fields
      out = [];
      for j=1:numel(results)
        if (~ any(results{j}.skip))
          out = [out results{j}];
        end
      end
    otherwise
      error ('unexpected action')
  end
end


function formatted = DOCTEST__format_exception(ex)
  mlock()  % not clear why we need this

  if is_octave()
    formatted = ['??? ' ex.message];
    return
  end

  if strcmp(ex.stack(1).name, 'doctest_run_tests')
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
  mlock()  % not clear why we need this
  if isempty(conditions)
    result = 'false';
  else
    result = strcat('(', strjoin(conditions, ') || ('), ')');
  end
end
