function results = doctest_run(docstring)
%DOCTEST_RUN - used internally by doctest
%
% Usage:
%   doctest_run(docstring)
%       Runs all the examples in the given docstring and returns a
%       structure with the results from running.
%
% The return value is a structure with the following fields:
%
% results.source:   the source code that was run
% results.want:     the desired output
% results.got:      the output that was recieved
% results.passed:   whether .want and .got match each other according to
%       doctest_compare.
%

% loosely based on Python 2.6 doctest.py, line 510
example_re = [
    '(?m)(?-s)'                          ... % options
    '(?:^ *>> )'                         ... % ">> "
    '(.*(?:\n *\.\. .*)*)\n'             ... % rest of line + ".. " lines
    '((?:(?:^ *$\n)?(?!\s*>>).*\S.*\n)*)'];  % the output
[~,~,~,~,examples] = regexp(docstring, example_re);

% default options
skip = false(size(examples));
xfail = false(size(examples));
normalize_whitespace = true(size(examples));
ellipsis = true(size(examples));

% parse directives
for i = 1:length(examples)
  % each block should be split into input/output by the regex
  assert (length(examples{i}) == 2);

  % find doctest directives
  t = regexp(examples{i}{1}, '(?:#|%)\s*doctest:\s+(\+|\-)([\w]+)', 'tokens');

  % process directives
  for j = 1:length(t)
    directive = t{j}{2};
    enable = strcmp(t{j}{1}, '+');

    if strcmp(directive, 'SKIP')
      skip(i) = enable;
    elseif strcmp(directive, 'XFAIL')
      xfail(i) = enable;
    elseif strcmp(directive, 'NORMALIZE_WHITESPACE')
      normalize_whitespace(i) = enable;
    elseif strcmp(directive, 'ELLIPSIS')
      ellipsis(i) = enable;
    else
      error('doctest: internal error: unexpected directive %s', directive);
    end
  end
end

% remove skipped tests
examples = examples(~skip);
xfail = xfail(~skip);
normalize_whitespace = normalize_whitespace(~skip);
ellipsis = ellipsis(~skip);

% replace initial '..' by '  ' in subsequent lines
for i = 1:length(examples)
  lines = strsplit(examples{i}{1}, '\n');
  s = lines{1};
  for j = 2:length(lines)
    T = regexp(lines{j}, '^\s*(\.\.)(.*)$', 'tokens');
    assert(length(T) == 1)
    T = T{1};
    assert(length(T) == 2)
    s = sprintf('%s\n   %s', s, T{2});
  end
  examples{i}{1} = s;
end


% run tests
all_outputs = DOCTEST__evalc(examples);


% deal with whitespace in inputs and outputs
for i = 1:length(examples)
  if (normalize_whitespace(i))
    % collapse multiple spaces to one
    examples{i}{2} = strtrim(regexprep(examples{i}{2}, '\s+', ' '));
    all_outputs{i} = strtrim(regexprep(all_outputs{i}, '\s+', ' '));
  else
    examples{i}{2} = strtrim_lines_discard_empties(examples{i}{2});
    all_outputs{i} = strtrim_lines_discard_empties(all_outputs{i});
  end
end


% store results
results = [];
for i = 1:length(examples)
  want = examples{i}{2};
  got = all_outputs{i};
  results(i).source = examples{i}{1};
  results(i).want = want;
  results(i).got = got;
  passed = doctest_compare(want, got, ellipsis(i));
  if xfail(i)
    passed = ~passed;
  end
  results(i).passed = passed;
end

end


% the following function is used to evaluate all lines of code in same
% namespace (the one of this invocation of DOCTEST__evalc)
function DOCTEST__results = DOCTEST__evalc(DOCTEST__examples_to_run)

% Octave has [no evalc command](https://savannah.gnu.org/patch/?8033).
DOCTEST__has_builtin_evalc = exist('evalc', 'builtin');

% structure adapted from a StackOverflow answer by user Amro, see
% http://stackoverflow.com/questions/3283586 and
% http://stackoverflow.com/users/97160/amro
DOCTEST__results = cell(size(DOCTEST__examples_to_run));
for DOCTEST__i = 1:numel(DOCTEST__examples_to_run)
  try
    if (DOCTEST__has_builtin_evalc)
      DOCTEST__results{DOCTEST__i} = evalc( ...
          DOCTEST__examples_to_run{DOCTEST__i}{1});
    else
      DOCTEST__results{DOCTEST__i} = doctest_evalc( ...
          DOCTEST__examples_to_run{DOCTEST__i}{1});
    end
  catch DOCTEST__exception
    DOCTEST__results{DOCTEST__i} = DOCTEST__format_exception(DOCTEST__exception);
  end
end

end


function formatted = DOCTEST__format_exception(ex)

  if is_octave()
    formatted = ['??? ' ex.message];
    return
  end

  if strcmp(ex.stack(1).name, 'DOCTEST__evalc')
    % we don't want the report, we just want the message
    % otherwise it'll talk about evalc, which is not what the user got on
    % the command line.
    formatted = ['??? ' ex.message];
  else
    formatted = ['??? ' ex.getReport('basic')];
  end
end


function r = strtrim_lines_discard_empties(s)
  lines = strsplit(s, '\n');

  keep = true(size(lines));
  for j = 1:length(lines)
    lines{j} = strtrim(lines{j});
    if (isempty(lines{j}))
      keep(j) = false;
    end
  end
  lines = lines(keep);
  r = strjoin(lines, '');
end
