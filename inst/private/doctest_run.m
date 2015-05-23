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


% Some tests are marked to skip
skip = false(size(examples));
for i = 1:length(examples)
  % each block should be split into input/output by the regex
  assert (length(examples{i}) == 2);

  % this test marked for skip
  if (regexp(examples{i}{1}, '(#|%)\s*doctest:\s*\+SKIP'))
    skip(i) = true;
  end
end
examples = examples(~skip);


% Some tests are marked to fail
xfailmarked = false(size(examples));
for i = 1:length(examples)
  if (regexp(examples{i}{1}, '(#|%)\s*doctest:\s*\+XFAIL'))
    xfailmarked(i) = true;
  end
end


% whitespace treatment
normalizewhitespace_default = true;
normalizewhitespace = normalizewhitespace_default .* true(size(examples));
for i = 1:length(examples)
  re = '(?:#|%)\s*doctest:\s*(\+|\-)NORMALIZEWHITESPACE';
  T = regexp(examples{i}{1}, re, 'tokens');

  if (isempty(T))
    % no-op
  elseif (strcmp(T{1}, '+'))
    normalizewhitespace(i) = true;
  elseif (strcmp(T{1}, '-'))
    normalizewhitespace(i) = false;
  else
    error('tertium non datur (bug?)');
  end
end


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


% run tests and store results
all_outputs = DOCTEST__evalc(examples);


% deal with whitespace
for i = 1:length(examples)
  if (normalizewhitespace(i))
    % collapse multiple spaces to one
    examples{i}{2} = strtrim(regexprep(examples{i}{2}, '\s+', ' '));
    all_outputs{i} = strtrim(regexprep(all_outputs{i}, '\s+', ' '));
  else
    examples{i}{2} = strtrim_lines_discard_empties(examples{i}{2});
    all_outputs{i} = strtrim_lines_discard_empties(all_outputs{i});
  end
end



results = [];
for i = 1:length(examples)
  want = examples{i}{2};
  got = all_outputs{i};
  results(i).source = examples{i}{1};
  results(i).want = want;
  results(i).got = got;
  % a list of acceptably-missing prefixes (allow customizing?)
  prefix = {'', 'ans = '};
  for ii = 1:length(prefix)
    passed = doctest_compare([prefix{ii} want], got);
    if passed, break, end
  end
  if xfailmarked(i)
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
