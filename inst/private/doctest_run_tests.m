function DOCTEST__results = doctest_run_tests(DOCTEST__tests)
%DOCTEST_RUN_TESTS  Used internally by doctest.
%
%   Usage:
%   doctest_run_tests(tests)
%       Carefully evaluate each test in the "tests" structure in
%       a common newly-created clean namespace (specifically, this
%       functions workspace).
%
%   The input is a structure with various fields including "tests.source",
%   the code to be run and "tests.want" the expected output.  Various
%   other flags such as "tests.xfail" and "tests.ellipsis" effect how
%   the test is run and how the test output is compared.
%
%   The return value is documented in "doctest_run_docstring".

%%
% Copyright (c) 2010 Thomas Grenfell Smith
% Copyright (c) 2011, 2015 Michael Walter
% Copyright (c) 2015-2017, 2019 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause


% Implementation note: all internal variables should start with
% "DOCTEST__" as (1) these will necessarily be exposed to the tests
% and (2) should not overwrite variables used by ongoing tests.

% do not split long rows (TODO: how to do this on MATLAB?)
if is_octave()
  split_long_rows(0, 'local');
end

% initialize data store (used to preserve state across iterations
% in the presence of "clear" and "clear all"s in tests)
doctest_datastore('set_tests', DOCTEST__tests);

for DOCTEST__i = 1:numel(DOCTEST__tests)
  % from the second iteration on, the only local variable that we can
  % rely on being present is DOCTEST__i
  doctest_datastore('set_current_index', DOCTEST__i);
  DOCTEST__current_test = doctest_datastore('get_current_test');

  % define test-global constants (these are accessible by the tests)
  DOCTEST_OCTAVE = is_octave();
  DOCTEST_MATLAB = ~DOCTEST_OCTAVE;

  % determine whether test should be skipped
  % (careful about Octave bug #46397 to not change the current value of “ans”)
  try
    eval (strcat ('DOCTEST__current_test.skip = ', ...
                  doctest_join_conditions(DOCTEST__current_test.skip), ...
                  ';'));
  catch DOCTEST__exception
    DOCTEST__current_test.skip = true;
    DOCTEST__current_test.xfail = [];   % don't know (yet)
    % hack: put the error message into "got"
    DOCTEST__current_test.got = strcat('There was a problem executing +SKIP directive:', ...
                                       sprintf('\n'), ...
                                       doctest_format_exception(DOCTEST__exception));
    DOCTEST__current_test.passed = false;
  end

  % determine whether test is expected to fail
  % (careful about Octave bug #46397 to not change the current value of “ans”)
  try
    eval (strcat ('DOCTEST__current_test.xfail = ', ...
                  doctest_join_conditions(DOCTEST__current_test.xfail), ...
                  ';'));
  catch DOCTEST__exception
    DOCTEST__current_test.skip = true;  % test is not going to run
    DOCTEST__current_test.xfail = [];  % cannot say
    % hack: put the error message into "got"
    DOCTEST__current_test.got = strcat('problem executing +XFAIL directive:', ...
                                       sprintf('\n'), ...
                                       doctest_format_exception(DOCTEST__exception));
    DOCTEST__current_test.passed = false;
  end

  doctest_datastore('set_current_test', DOCTEST__current_test);

  if (DOCTEST__current_test.skip)
    continue
  end

  % run the test code
  try
    DOCTEST__got = evalc(DOCTEST__current_test.source);
  catch DOCTEST__exception
    DOCTEST__got = doctest_format_exception(DOCTEST__exception);
  end

  % at this point, we can only rely on the DOCTEST__got variable
  % being available
  DOCTEST__current_test = doctest_datastore('get_current_test');
  DOCTEST__current_test.got = DOCTEST__got;

  % determine if test has passed
  DOCTEST__current_test.passed = doctest_compare(DOCTEST__current_test.want, DOCTEST__current_test.got, DOCTEST__current_test.normalize_whitespace, DOCTEST__current_test.ellipsis);
  if DOCTEST__current_test.xfail
    DOCTEST__current_test.passed = ~DOCTEST__current_test.passed;
  end

  doctest_datastore('set_current_test', DOCTEST__current_test);
end

% retrieve all tests from data store
tests = doctest_datastore('get_tests');
doctest_datastore('clear_and_munlock');

% unwrap from cell-array, discarding skips
%DOCTEST__results = cell2mat(tests);  % fails b/c they have different fields
DOCTEST__results = [];
for j=1:numel(tests)
  if (~any(tests{j}.skip) || isfield(tests{j}, 'passed'))
    % skipped but pass was false, may be a directive so keep
    DOCTEST__results = [DOCTEST__results tests{j}];
  end
end

end
