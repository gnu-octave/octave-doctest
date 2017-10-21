function results = doctest_run_docstring(docstring, defaults)
%DOCTEST_RUN_DOCSTRING  Used internally by doctest.
%
%   Usage: doctest_run_docstring(docstring, defaults)
%       Extract all the examples in the input docstring into a
%       structure.  Process various flags and directives that
%       about each test.  Run the tests in a common namespace.
%
%   The return value is a structure with the following fields:
%
%   results.source:   the source code that was run
%   results.want:     the desired output
%   results.got:      the output that was recieved
%   results.passed:   whether .want and .got match each other according to
%                     doctest_compare.

%%
% Copyright (c) 2010 Thomas Grenfell Smith
% Copyright (c) 2011, 2015 Michael Walter
% Copyright (c) 2015-2017 Colin B. Macdonald
% License: BSD-3-Clause, see doctest.m for details


% extract tests from docstring
TEST_RE = [                               % loosely based on Python 2.6 doctest.py, line 510
    '(?m)(?-s)'                          ... % options
    '(?:^ *>> )'                         ... % ">> "
    '(.*(?:\n *\.\. .*)*)\n'             ... % rest of line + ".. " lines
    '((?:(?:^ *$\n)?(?!\s*>>).*\S.*\n)*)'];  % the output

tests = [];
test_matches = regexp(docstring, TEST_RE, 'tokens');
for i=1:length(test_matches)
  % each block should be split into source and desired output
  source = test_matches{i}{1};
  tests(i).want = test_matches{i}{2};

  % replace initial '..' by '  ' in subsequent lines
  lines = strsplit(source, '\n');
  source = lines{1};
  for j = 2:length(lines)
    T = regexp(lines{j}, '^\s*(\.\.)(.*)$', 'tokens');
    assert(length(T) == 1);
    T = T{1};
    assert(length(T) == 2);
    source = sprintf('%s\n   %s', source, T{2});
  end
  tests(i).source = source;

  % set default options
  tests(i).normalize_whitespace = defaults.normalize_whitespace;
  tests(i).ellipsis = defaults.ellipsis;
  tests(i).skip = {};
  tests(i).xfail = {};

  % find and process directives
  re = [ ...
    '[#%]\s*doctest:\s+' ... % e.g., "# doctest: "
    '([\+\-]\w+)'        ... % token for cmd, e.g., "+XSKIP_IF"
    '(\s*\('             ... % token for code, starting with "("
      '[^#%\n]+'         ... % no newlines, no comments in code
    '\))?'];                 % ")" of code, at most one code arg
  directive_matches = regexp(tests(i).source, re, 'tokens');
  for j = 1:length(directive_matches)
    directive = directive_matches{j}{1};
    if (strcmp('+SKIP_IF', directive) || strcmp('+SKIP_UNLESS', directive) || strcmp('+XFAIL_IF', directive) || strcmp('+XFAIL_UNLESS', directive))
      if length(directive_matches{j}) == 2
        condition = directive_matches{j}{2};
      else
        error('doctest: syntax error, expected %s(varname)', directive);
      end
    end

    if strcmp('NORMALIZE_WHITESPACE', directive(2:end))
      tests(i).normalize_whitespace = strcmp(directive(1), '+');
    elseif strcmp('ELLIPSIS', directive(2:end))
      tests(i).ellipsis = strcmp(directive(1), '+');
    elseif strcmp('+SKIP', directive)
      tests(i).skip{end + 1} = 'true';
    elseif strcmp('+SKIP_IF', directive)
      tests(i).skip{end + 1} = condition;
    elseif strcmp('+SKIP_UNLESS', directive)
      tests(i).skip{end + 1} = sprintf('~(%s)', condition);
    elseif strcmp('+XFAIL', directive)
      tests(i).xfail{end + 1} = 'true';
    elseif strcmp('+XFAIL_IF', directive)
      tests(i).xfail{end + 1} = condition;
    elseif strcmp('+XFAIL_UNLESS', directive)
      tests(i).xfail{end + 1} = sprintf('~(%s)', condition);
    else
      warning('Doctest:unexpected-directive', 'doctest: ignoring unexpected directive %s', directive);
    end
  end
end

results = doctest_run_tests(tests);

end
