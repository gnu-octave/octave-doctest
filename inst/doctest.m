function varargout = doctest(varargin)
% Run examples embedded in documentation
%
% Usage
% =====
%
% doctest class_name1 func_name2 class_name3 ...
%
%
% Description
% ===========
%
% Each time doctest runs a test, it's running a line of code and checking
% that the output is what you say it should be.  It knows something is an
% example because it's a line in help('your_function') that starts with
% '>>'.  It knows what you think the output should be by starting on the
% line after >> and looking for the next >>, two blank lines, or the end of
% the documentation.
%
%
% Examples
% ========
%
% Running 'doctest doctest' will execute these examples and test the
% results.
%
% >> 1 + 3
%
% ans =
%
%      4
%
%
% Note the two blank lines between the end of the output and the beginning
% of this paragraph.  That's important so that we can tell that this
% paragraph is text and not part of the example!
%
% If there's no output, that's fine, just put the next line right after the
% one with no output.  If the line does produce output (for instance, an
% error), this will be recorded as a test failure.
%
% >> x = 3 + 4;
% >> x
%
% x =
%
%    7
%
%
% Expecting an error
% ------------------
%
% doctest can deal with errors, a little bit.  For instance, this case is
% handled correctly:
%
% >> not_a_real_function(42)
% ??? ***ndefined ***
%
%
% (MATLAB spells this 'Undefined', while Octave uses 'undefined')
%
% But if the line of code will emit other output BEFORE the error message,
% the current version can't deal with that.  For more info see Issue #4 on
% the bitbucket site (below).  Warnings are different from errors, and they
% work fine.
%
%
% Wildcards
% ---------
%
% If you have something that has changing output, for instance line numbers
% in a stack trace, or something with random numbers, you can use a
% wildcard to match that part.
%
% >> datestr(now, 'yyyy-mm-dd')
% 2***
%
%
% Multiple lines of code
% ----------------------
%
% Code spanning multiple lines of code can be entered by prefixing all
% subsequent lines with '..',  e.g.
%
% >> for i = 1:3
% ..   i
% .. end
%
% i = 1
% i = 2
% i = 3
%
%
% Shortcuts
% ---------
%
% You can optionally omit "ans = " when the output is unassigned.  But
% actual variable names (such as "x = " above) must be included.  Leading
% and trailing whitespace on each line of output will be discarded which
% gives some freedom to, e.g., indent the code output as you wish.
%
%
% Limitations
% ===========
%
% The examples MUST END with either the END OF THE DOCUMENTATION or TWO
% BLANK LINES (or anyway, lines with just the comment marker % and nothing
% else).
%
% All adjacent white space is collapsed into a single space before
% comparison, so right now it can't detect anything that's purely a
% whitespace difference.
%
% When you're working on writing/debugging a Matlab class, you might need
% to run 'clear classes' to get correct results from doctests (this is a
% general problem with developing classes in Matlab).
%
% It doesn't say what line number/file the doctest error is in.  This is
% because it uses Matlab's plain ol' HELP function to extract the
% documentation.  It wouldn't be too hard to write our own comment parser,
% but this hasn't happened yet.  (See Issue #2 on the bitbucket site,
% below)
%
%
% Octave-specific notes
% =====================
%
% Octave m-files are commonly documented using Texinfo.  If you are running
% Octave and your m-file contains texinfo markup, then the rules noted above
% are slightly different.  First, text outside of "@example" ... "@end
% example" blocks is discarded.  As only examples are expected in those
% blocks, the two-blank-lines convention is not required.  A minor amount of
% reformatting is done (e.g., stripping the pagination hints "@group").
%
% Conventionally, Octave documentation indicates results with "@result{}"
% (which renders to an arrow).  If the text contains no ">>" prompts, we try
% to guess where they should be based on splitting around the "@result{}"
% indicators.  Additionally, all lines from the start of the "@example"
% block to the first "@result{}" are assumed to be commands.  These
% heuristics work for simple documentation but for more complicated
% examples, adding ">>" to the documentation may be necessary.
%
% Standalone Texinfo files can be tested using "doctest myfile.texinfo".
%
% FIXME: Instead of the current pre-parsing to add ">>" prompts, one could
% presumably refactor the testing code so that input lines are tried
% one-at-a-time checking the output after each.
%
%
% Return values
% =============
%
% [n, f, e] = doctest('class_name1', 'func_name1')
%
% Here 'n' is the number of test, 'f' is the number of failures and 'e' is
% the number of extraction errors.  The latter is probably only relevant
% when using Texinfo on Octave where it indicates malformed @example blocks.
%
%
% History
% =======
%
% The original version was written by Thomas Smith and is available
% at http://bitbucket.org/tgs/doctest-for-matlab/src
%
% This modified version adds multiline and Octave support, among other things.
% It is available at https://github.com/catch22/octave-doctest
% See the CONTRIBUTORS file for a list of authors and contributors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Doctest v0.4.0-dev: this is Free Software without warranty, see source.');

% Make a list of every method/function that we need to examine, in the
% to_test struct.%

% determine whether we are running octave or matlab
try
  OCTAVE_VERSION;
  running_octave = 1;
catch
  running_octave = 0;
end

% We include a link to the function where the docstring is going to come
% from, so that it's easier to navigate to that doctest.
to_test = [];
for i = 1:nargin
  func_or_class = varargin{i};
  to_test = [to_test; doctest_collect(func_or_class)];
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Examine each function/method for a docstring, and run any examples in
% that docstring
%

[color_ok, color_err, color_warn, reset] = doctest_colors();

all_results = cell(1, length(to_test));

if running_octave
  disp('==========================================================================')
  disp('Start of temporary output (github.com/catch22/octave-doctest/issues/6)');
  disp('==========================================================================')
end

for I = 1:length(to_test)
    these_results = doctest_run(to_test(I).docstring);


    if ~ isempty(these_results)
        [these_results.link] = deal(to_test(I).link);
    end

    all_results{I} = these_results;
    % Print the results after each file
    %print_test_results(to_test(I), these_results, err, msg);
end

if running_octave
  disp('========================================================================')
  disp('End of temporary output (github.com/catch22/octave-doctest/issues/6)');
  disp('========================================================================')
end

total_test = 0;
total_fail = 0;
total_notests = 0;
total_extract_errs = 0;
for I=1:length(all_results);
  extract_error = to_test(I).error;
  [count, numfail] = print_test_results(to_test(I), all_results{I}, extract_error);
  total_test = total_test + count;
  total_fail = total_fail + numfail;
  if (length(all_results{I}) == 0)
    total_notests = total_notests + 1;
  end
  if (extract_error)
    total_extract_errs = total_extract_errs + 1;
  end
end

fprintf('\nDoctest Summary:\n\n');
fprintf('  Searched %d targets: found %d tests total, %d targets without tests.\n', ...
        length(all_results), total_test, total_notests);

fprintf('  Extraction errors: ');
if (total_extract_errs == 0)
  fprintf('0\n');
else
  fprintf([color_warn '%d targets appear to have unusable tests.' reset '\n'], ...
          total_extract_errs);
end
if (total_fail == 0)
  hilite = color_ok;
else
  hilite = color_err;
end
fprintf(['  ' hilite 'Tests passed: %d/%d' reset '\n\n'], ...
        total_test - total_fail, total_test);

if (nargout > 0)
  varargout = {total_test, total_fail, total_extract_errs};
end

end


function [total, errors] = print_test_results(to_test, results, extract_err)

out = 1; % stdout
err = 2;

total = length(results);
errors = 0;
for i = 1:total
  if ~results(i).pass
    errors = errors + 1;
  end
end

[color_ok, color_err, color_warn, reset] = doctest_colors();

if total == 0 && extract_err
  fprintf(err, ['%s: ' color_warn  'Warning: could not extract tests' reset '\n'], to_test.name);
  fprintf(err, '  %s\n', extract_err);
elseif total == 0
  fprintf(err, '%s: NO TESTS\n', to_test.name);
elseif errors == 0
  fprintf(out, '%s: OK (%d tests)\n', to_test.name, length(results));
else
  fprintf(err, ['%s: ' color_err '%d ERRORS' reset '\n'], to_test.name, errors);
end
for I = 1:length(results)
  if ~results(I).pass
    fprintf(out, '  >> %s\n\n', results(I).source);
    fprintf(out, [ '     expected: ' '%s' '\n' ], results(I).want);
    fprintf(out, [ '     got     : ' color_err '%s' reset '\n' ], results(I).got);
  end
end

end
