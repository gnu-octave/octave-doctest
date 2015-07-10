%% Copyright (c) 2010 Thomas Grenfell Smith
%% Copyright (c) 2011, 2013-2015 Michael Walter
%% Copyright (c) 2015 Colin B. Macdonald
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice,
%% this list of conditions and the following disclaimer.
%%
%% 2. Redistributions in binary form must reproduce the above copyright notice,
%% this list of conditions and the following disclaimer in the documentation
%% and/or other materials provided with the distribution.
%%
%% 3. Neither the name of the copyright holder nor the names of its
%% contributors may be used to endorse or promote products derived from this
%% software without specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.

%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn  {Function File} {} doctest @var{what}
%% @deftypefnx {Function File} {} doctest @var{what} -recursive
%% @deftypefnx {Function File} {@var{success} =} doctest (@var{what}, @dots{})
%% @deftypefnx {Function File} {@var{numpass}, @var{numtests}, @var{summary} =} doctest (@dots{})
%% Run examples embedded in documentation.
%%
%% The parameter @var{what} contains a name on which to run tests.  It can be:
%% @itemize
%% @item a function;
%% @item a class;
%% @item a Texinfo file;
%% @item a directory/folder, whose contents are tested (pass "-recursive"
%%   to descend into subfolders).
%% @end itemize
%% @var{what} can also be a cell array of such items.
%%
%% When called with a single return value, return whether all tests have
%% succeeded (SUCCESS).
%%
%% When called with two or more return values, return the number of tests
%% passed (@var{numpass}), the total number of tests (@var{numtests}) and a
%% structure with the following fields:
%%
%%   SUMMARY.num_targets
%%   SUMMARY.num_targets_passed
%%   SUMMARY.num_targets_without_tests
%%   SUMMARY.num_targets_with_extraction_errors
%%   SUMMARY.num_tests
%%   SUMMARY.num_tests_passed
%%
%% The field 'num_targets_with_extraction_errors' is probably only relevant
%% when testing Texinfo documentation, where it typically indicates malformed
%% @@example blocks.
%%
%%
%% @strong{Description}
%%
%% Each time doctest runs a test, it's running a block of code and checking
%% that the output is what you say it should be.  It knows something is an
%% example because it's a line in @code{help('your_function')} that starts with
%% @code{>>}.  It knows what you think the output should be by starting on the
%% line after >> and looking for the next >>, two blank lines, or the end of
%% the documentation.
%%
%%
%% Running 'doctest doctest' will execute these examples and test the
%% results.
%%
%% @example
%% @group
%% >> 1 + 3
%% ans =
%%      4
%%
%% @end group
%% @end example
%%
%%
%% Note the two blank lines between the end of the output and the beginning
%% of this paragraph.  That's important so that we can tell that this
%% paragraph is text and not part of the example!
%%
%% If there's no output, that's fine, just put the next line right after the
%% one with no output.  If the line does produce output (for instance, an
%% error), this will be recorded as a test failure.
%%
%% @example
%% @group
%% >> x = 3 + 4;
%% >> x
%% x =
%%    7
%% @end group
%% @end example
%%
%%
%% @subsection Wildcards
%%
%% If you have something that has changing output, for instance line numbers
%% in a stack trace, or something with random numbers, you can use a
%% wildcard to match that part.
%%
%% @example
%% @group
%% >> datestr(now, 'yyyy-mm-dd')
%% 2...
%% @end group
%% @end example
%%
%% @subsection Expecting an error
%%
%% doctest can deal with errors, a little bit.  For instance, this case is
%% handled correctly:
%%
%% @example
%% @group
%% >> not_a_real_function(42)
%% ??? ...ndefined ...
%% @end group
%% @end example
%% (MATLAB spells this 'Undefined', while Octave uses 'undefined')
%%
%% But if the line of code will emit other output BEFORE the error message,
%% the current version can't deal with that.  For more info see Issue #4 on
%% the bitbucket site (below).  Warnings are different from errors, and they
%% work fine.
%%
%%
%% @subsection Multiple lines of code
%%
%% Code spanning multiple lines of code can be entered by prefixing all
%% subsequent lines with '..',  e.g.
%%
%% @example
%% @group
%% >> for i = 1:3
%% ..   i
%% .. end
%%
%% i = 1
%% i = 2
%% i = 3
%% @end group
%% @end example
%%
%%
%% @subsection Shortcuts
%%
%% You can optionally omit "ans = " when the output is unassigned.  But
%% actual variable names (such as "x = " above) must be included.  Leading
%% and trailing whitespace on each line of output will be discarded which
%% gives some freedom to, e.g., indent the code output as you wish.
%%
%%
%% @subsection Directives
%%
%% You can skip certain tests by marking them with a special comment.  This
%% can be used, for example, for a test not expected to pass or to avoid
%% opening a figure window during automated testing.
%%
%% @example
%% @group
%% >> a = 6         % doctest: +SKIP
%% b = 42
%% >> plot(...)     % doctest: +SKIP
%% @end group
%% @end example
%%
%%
%% These special comments act as directives for modifying test behaviour.
%% You can also mark tests that you expect to fail:
%%
%% @example
%% @group
%% >> a = 6         % doctest: +XFAIL
%% b = 42
%% @end group
%% @end example
%%
%%
%% By default, all adjacent white space is collapsed into a single space
%% before comparison.  A stricter mode where "internal whitespace" must
%% match is available:
%%
%% @example
%% @group
%% >> fprintf('a   b\nc   d\n')    % doctest: -NORMALIZE_WHITESPACE
%% a   b
%% c   d
%%
%% >> fprintf('a  b\nc  d\n')      % doctest: +NORMALIZE_WHITESPACE
%% a b
%% c d
%% @end group
%% @end example
%%
%%
%% To disable the '...' wildcard, use the -ELLIPSIS directive.
%%
%% The default directives can be overridden on the command line using, for
%% example, "doctest target -NORMALIZE_WHITESPACE +ELLIPSIS".  Note that
%% directives local to a test still take precident of these.
%%
%%
%% @subsection Testing Texinfo documentation
%%
%% Octave m-files are commonly documented using Texinfo.  If you are running
%% Octave and your m-file contains texinfo markup, then the rules noted above
%% are slightly different.  First, text outside of "@@example" ... "@@end
%% example" blocks is discarded.  As only examples are expected in those
%% blocks, the two-blank-lines convention is not required.  A minor amount of
%% reformatting is done (e.g., stripping the pagination hints "@@group").
%%
%% Conventionally, Octave documentation indicates results with "@@result@{@}"
%% (which renders to an arrow).  If the text contains no ">>" prompts, we try
%% to guess where they should be based on splitting around the "@@result@{@}"
%% indicators.  Additionally, all lines from the start of the "@@example"
%% block to the first "@@result@{@}" are assumed to be commands.  These
%% heuristics work for simple documentation but for more complicated
%% examples, adding ">>" to the documentation may be necessary.
%%
%% Standalone Texinfo files can be tested using "doctest myfile.texinfo".
%%
%% @seealso{test}
%% @end deftypefn

function varargout = doctest(what, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print usage?
if nargin < 1
  help doctest;
  return;
end

% if given a single object, wrap it in a cell array
if ~iscell(what)
  what = {what};
end

% input parsing for options and directives
recursive = false;
directives = doctest_default_directives();
for i = 1:(nargin-1)
  assert(ischar(varargin{i}))
  pm = varargin{i}(1);
  directive = varargin{i}(2:end);
  switch directive
    case 'recursive'
      assert(strcmp(pm, '-'))
      recursive = true;
    otherwise
      assert(strcmp(pm, '+') || strcmp(pm, '-'))
      enable = strcmp(varargin{i}(1), '+');
      directives = doctest_default_directives(directives, directive, enable);
  end
end

% for now, always print to stdout
fid = 1;

% get terminal color codes
[color_ok, color_err, color_warn, reset] = doctest_colors(fid);

% print banner
fprintf(fid, 'Doctest v0.4.1-dev: this is Free Software without warranty, see source.\n\n');


summary = struct();
summary.num_targets = 0;
summary.num_targets_passed = 0;
summary.num_targets_without_tests = 0;
summary.num_targets_with_extraction_errors = 0;
summary.num_tests = 0;
summary.num_tests_passed = 0;


for i=1:numel(what)
  summary = doctest_collect(what{i}, directives, summary, recursive, fid);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Report summary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(fid, '\nSummary:\n\n');
if (summary.num_tests_passed == summary.num_tests)
  fprintf(fid, ['   ' color_ok 'PASS %4d/%-4d' reset '\n\n'], summary.num_tests_passed, summary.num_tests);
else
  fprintf(fid, ['   ' color_err 'FAIL %4d/%-4d' reset '\n\n'], summary.num_tests - summary.num_tests_passed, summary.num_tests);
end

fprintf(fid, '%d/%d targets passed, %d without tests', summary.num_targets_passed, summary.num_targets, summary.num_targets_without_tests);
if summary.num_targets_with_extraction_errors > 0
  fprintf(fid, [', ' color_err '%d with extraction errors' reset], summary.num_targets_with_extraction_errors);
end
fprintf(fid, '.\n\n');

if nargout == 1
  varargout = {summary.num_targets_passed == summary.num_targets};
elseif nargout > 1
  varargout = {summary.num_tests_passed, summary.num_tests, summary};
end

end
