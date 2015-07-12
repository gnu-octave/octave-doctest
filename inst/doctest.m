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
%% @deftypefn  {Function File} {} doctest @var{target}
%% @deftypefnx {Function File} {} doctest @var{target} -recursive
%% @deftypefnx {Function File} {} doctest @var{target} -DIRECTIVE
%% @deftypefnx {Function File} {} doctest @var{target} +DIRECTIVE
%% @deftypefnx {Function File} {@var{success} =} doctest (@var{target}, @dots{})
%% @deftypefnx {Function File} {@var{numpass}, @var{numtests}, @var{summary} =} doctest (@dots{})
%% Run examples embedded in documentation.
%%
%% Doctest finds and runs code found in @var{target}, which can be a:
%% @itemize
%% @item function;
%% @item class;
%% @item Texinfo file;
%% @item directory/folder (pass @code{-recursive} to descend
%%       into subfolders);
%% @item cell array of such items.
%% @end itemize
%% When called with a single return value, return whether all tests have
%% succeeded (SUCCESS).
%%
%% When called with two or more return values, return the number of tests
%% passed (@var{numpass}), the total number of tests (@var{numtests}) and a
%% structure @var{summary} with various fields.
%%
%%
%% Doctest finds example blocks, executes the code and verifies that the
%% results match the expected output.  For example, running
%% @code{doctest doctest} will execute this code:
%%
%% @example
%% @group
%% >> 1 + 3
%% ans =
%%      4
%% @end group
%% @end example
%%
%% If there's no output, just put the next line right after the one with
%% no output.  If the line does produce output (for instance, an error),
%% this will be recorded as a test failure.
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
%% @strong{Wildcards}
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
%% @strong{Expecting an error}
%% Doctest can deal with errors, a little bit.  For instance, this case is
%% handled correctly:
%%
%% @example
%% @group
%% >> not_a_real_function(42)
%% ??? ...ndefined ...
%% @end group
%% @end example
%% (Note use of wildcards here; MATLAB spells this 'Undefined', while Octave
%% uses 'undefined').
%%
%% However, currently this does not work if the code emits other output
%% @strong{before} the error message.  Warnings are different; they work
%% fine.
%%
%%
%% @strong{Multiple lines of code}
%% Code spanning multiple lines can be entered by prefixing all subsequent
%% lines with @code{..}, e.g.,
%%
%% @example
%% @group
%% >> for i = 1:3
%% ..   i
%% .. end
%% i = 1
%% i = 2
%% i = 3
%% @end group
%% @end example
%% (But note this is not required when writing texinfo documentation,
%% see below).
%%
%%
%% @strong{Shortcuts}
%% You can optionally omit @code{ans = } when the output is unassigned.  But
%% actual variable names (such as @code{x = }) must be included.  Leading
%% and trailing whitespace on each line of output will be discarded which
%% gives some freedom to, e.g., indent the code output as you wish.
%%
%%
%% @strong{Directives}
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
%% before comparison.  A stricter mode where ``internal whitespace'' must
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
%% To disable the @code{...} wildcard, use the -ELLIPSIS directive.
%%
%% The default directives can be overridden on the command line using, for
%% example, @code{doctest target -NORMALIZE_WHITESPACE +ELLIPSIS}.  Note that
%% directives local to a test still take precident over these.
%%
%%
%% @strong{Plaintext documentation}
%% When the m-file contains plaintext documentation, doctest finds tests
%% by searching for lines that begin with @code{>>}.  It then finds the
%% expected output starting on the line after @code{>>} and looking for
%% the next @code{>>}, the end of the documentation, or two blank lines
%% (which signify the end of the example).
%%
%% @strong{Texinfo documentation}
%% Octave m-files are commonly documented using Texinfo.  If your m-file
%% contains Texinfo markup, then doctest finds code inside
%% @code{@@example @dots{} @@end example} blocks.  Some comments:
%% @itemize
%% @item The two-blank-lines convention is not required.
%% @item A minor amount of reformatting is done
%% (e.g., stripping the pagination hints @code{@@group}).
%% @item The use of @code{>>} is not required as Octave documentation
%% conventionally indicates output with @code{@@result@{@}} (which renders
%% to an arrow '@result{}').  Thus, if the example contains no @code{>>}
%% prompts, some simple heuristics are used to split around
%% @code{@@result@{@}}.  This works for simple examples, but it may be
%% necessary to add @code{>>} in some cases.
%% @end itemize
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
