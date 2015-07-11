function summary = doctest_collect(what, directives, summary, recursive, fid)
% Find and run doctests.
%
% The parameter WHAT is the name of a class, directory, function or filename:
%   * For a directory, calls itself on the contents, recursively if
%     RECURSIVE is true;
%   * For a class, all methods are tested;
%   * When running Octave, it can also be the filename of a Texinfo file.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: methods('logical') octave/matlab differ: which behaviour do we want?
% TODO: what about builtin "test" versus dir "test/"?  Do we prefer dir?

% determine type of target
if is_octave()
  % Note: ripe for refactoring once "exist(what, 'class')" works in Octave.
  [~, ~, ext] = fileparts(what);
  if any(strcmpi(ext, {'.texinfo' '.texi' '.txi' '.tex'}))
    type = 'texinfo';
  elseif (exist(what, 'file') && ~exist(what, 'dir')) || exist(what, 'builtin');
    if (exist(['@' what], 'dir'))
      % special case, e.g., @logical is class, logical is builtin
      type = 'class';
    else
      type = 'function';
    end
  elseif (exist(what, 'dir') && what(1) ~= '@')
    type = 'dir';
  elseif exist(what) == 2 || exist(what) == 103
    % Notes:
    %   * exist('@class', 'dir') only works if pwd is the parent of
    %     '@class', having it in the path is not sufficient.
    %   * Return 2 on Octave 3.8 and 103 on Octave 4.
    type = 'class';
  else
    % classdef classes are not detected by any of the above
    try
      temp = methods(what);
      type = 'class';
    catch
      type = 'unknown';
    end
  end
else
  if ~isempty(methods(what))
    type = 'class';
  elseif (exist(what, 'dir'))
    type = 'dir';
  elseif exist(what, 'file') || exist(what, 'builtin');
    type = 'function';
  else
    type = 'unknown';
  end
end


% Deal with directories
if (strcmp(type, 'dir'))
  if (~ strcmp(what, '.'))
    fprintf(fid, 'Descending into directory "%s"\n', what);
  end
  oldcwd = chdir(what);
  files = dir('.');
  for i=1:numel(files)
    f = files(i).name;
    if strcmp(f, '.') || strcmp(f, '..') || strcmpi(f, 'private')
      % skip ., .., and private folders (TODO)
      continue
    end
    if (f(1) == '@')
      % strip the @, prevents processing as a directory
      f = f(2:end);
    elseif (~ recursive && exist(f, 'dir'))
      % skip directories
      continue
    end
    summary = doctest_collect(f, directives, summary, recursive, fid);
  end
  chdir(oldcwd);
  return
end



% Build structure array with the following fields:
%   TARGETS(i).name       Human-readable name of test.
%   TARGETS(i).link       Hyperlink to test for use in Matlab.
%   TARGETS(i).docstring  Associated docstring.
%   TARGETS(i).error:     Contains error string if extraction failed.

if strcmp(type, 'function')
  targets = collect_targets_function(what);
elseif strcmp(type, 'class')
  targets = collect_targets_class(what);
elseif strcmp(type, 'texinfo')
  target = struct();
  target.name = what;
  target.link = '';
  [target.docstring, target.error] = parse_texinfo(fileread(what));
  targets = [target];
else
  target = struct();
  target.name = what;
  target.link = '';
  target.docstring = '';
  target.error = 'Function or class not found.';
  targets = [target];
end


% update summary
summary.num_targets = summary.num_targets + numel(targets);

% get terminal color codes
[color_ok, color_err, color_warn, reset] = doctest_colors(fid);


for i=1:numel(targets)
  % run doctests for target and update statistics
  target = targets(i);
  fprintf(fid, '%s %s ', target.name, repmat('.', 1, 55 - numel(target.name)));

  % extraction error?
  if target.error
    summary.num_targets_with_extraction_errors = summary.num_targets_with_extraction_errors + 1;
    fprintf(fid, [color_err  'EXTRACTION ERROR' reset '\n\n']);
    fprintf(fid, '    %s\n\n', target.error);
    continue;
  end

  % run doctest
  results = doctest_run(target.docstring, directives);

  % determine number of tests passed
  num_tests = numel(results);
  num_tests_passed = 0;
  for j=1:num_tests
    if results(j).passed
      num_tests_passed = num_tests_passed + 1;
    end
  end

  % update summary
  summary.num_tests = summary.num_tests + num_tests;
  summary.num_tests_passed = summary.num_tests_passed + num_tests_passed;
  if num_tests_passed == num_tests
    summary.num_targets_passed = summary.num_targets_passed + 1;
  end
  if num_tests == 0
    summary.num_targets_without_tests = summary.num_targets_without_tests + 1;
  end

  % pretty print outcome
  if num_tests == 0
    fprintf(fid, 'NO TESTS\n');
  elseif num_tests_passed == num_tests
    fprintf(fid, [color_ok 'PASS %4d/%-4d' reset '\n'], num_tests_passed, num_tests);
  else
    fprintf(fid, [color_err 'FAIL %4d/%-4d' reset '\n\n'], num_tests - num_tests_passed, num_tests);
    for j = 1:num_tests
      if ~results(j).passed
        fprintf(fid, '   >> %s\n\n', results(j).source);
        fprintf(fid, [ '      expected: ' '%s' '\n' ], results(j).want);
        fprintf(fid, [ '      got     : ' color_err '%s' reset '\n' ], results(j).got);
        fprintf(fid, '\n');
      end
    end
  end
end

end



function target = collect_targets_function(what)
  target = struct();
  target.name = what;
  if is_octave()
    target.link = '';
  else
    target.link = sprintf('<a href="matlab:editorservices.openAndGoToLine(''%s'', 1);">%s</a>', which(what), what);
  end
  [target.docstring, target.error] = extract_docstring(target.name);
end


function targets = collect_targets_class(what)
  % First, "help class".  For classdef, this differs from "help class.class"
  % (general class help vs constructor help).  For old-style classes we will
  % probably end up testing the constructor twice but... meh.
  target.name = what;
  if is_octave()
    target.link = '';
  else
    target.link = sprintf('<a href="matlab:editorservices.openAndGoToLine(''%s'', 1);">%s</a>', which(what), what);
  end
  [target.docstring, target.error] = extract_docstring(target.name);
  targets = target;

  % Next, add targets for all class methods
  meths = methods(what);
  for i=1:numel(meths)
    target = struct();
    if is_octave()
      target.name = sprintf('@%s/%s', what, meths{i});
      target.link = '';
    else
      target.name = sprintf('%s.%s', what, meths{i});
      target.link = sprintf('<a href="matlab:editorservices.openAndGoToFunction(''%s'', ''%s'');">%s</a>', which(what), meths{i}, target.name);
    end
    [target.docstring, target.error] = extract_docstring(target.name);
    targets = [targets; target];
  end
end


function [docstring, error] = extract_docstring(name)
  if is_octave()
    [docstring, format] = get_help_text(name);
    if strcmp(format, 'texinfo')
      [docstring, error] = parse_texinfo(docstring);
    else
      error = '';
    end
  else
    docstring = help(name);
    error = '';
  end
end


function [docstring, error] = parse_texinfo(str)
  docstring = '';
  error = '';

  % no example blocks? not an error, but nothing to do
  if (isempty(strfind(str, '@example')))
    % error = 'no @example blocks';
    return
  end

  % Mark the occurrence of “@example” and “@end example” to be able to find
  % example blocks after conversion from texi to plain text.  Also consider
  % indentation, so we can later correctly unindent the example's content.
  % There seems to be a bug with substitute replacement in the first line and
  % the second pattern could fail if the file doesn't end with a newline.  Thus
  % we prepend and append a newline.
  str = regexprep (cstrcat (char (10), str, char (10)), ...
                   '^([ \t]*)(@example)(.*)(\r?\n)', ...
                   [ '$1$2$3$4', ... % retain original line
                     '$1###### EXAMPLE START ######$4'], ...
                   'lineanchors', 'dotexceptnewline');
  str = regexprep (str, ...
                   '^([ \t]*)(@end example)(.*)(\r?\n)', ...
                   [ '$1###### EXAMPLE STOP ######$4', ...
                     '$1$2$3$4'], ... % retain original lipne
                   'lineanchors', 'dotexceptnewline');

  % special comments "@c doctest: cmd" are translated
  % the translated comment is moved to a dedicated line (otherwise it might
  % get lost during texi conversion, e. g. when in the same line as @example)
  % FIXME the expression would also match @@c doctest: ...
  re = [ '(?:\n\s*)?'         ... % compensate for \n added during translation 
         '(?:@c(?:omment)?\s' ... % @c or @comment, ?: means no token
            '|[#%])\s*'       ... % or one of #,%
         '(doctest:\s*.*)' ];     % want the doctest token
  str = regexprep (str, re, '\n% $1', 'dotexceptnewline');

  [str, err] = __makeinfo__ (str, 'plain text');
  if (err ~= 0)
    error = '__makeinfo__ returned with error code'
    return
  end

  % extract examples and discard everything else
  T = regexp (str, ...
              '(^\s*###### EXAMPLE START ######.*?###### EXAMPLE STOP ######$)', ...
              'tokens', 'lineanchors');
  if (isempty (T))
    error = 'malformed @example blocks';
    return
  end

  % post-process each example block
  for i = 1 : length (T)
    % flatten
    assert (numel (T{i}), 1);
    T{i} = T{i}{1};

    % unindent
    indent = regexp (T{i}, '#', 'once') - 1;
    T{i} = regexprep (T{i}, ['^', ' '(ones (1, indent))], '', 'lineanchors');

    % remove EXAMPLE markers
    T{i} = regexprep (T{i}, ...
                      '^[ \t]*###### EXAMPLE ST(?:ART|OP) ######\r?\n?', ...
                      '', ...
                      'lineanchors');

    if (regexp (T{i}, '^\s*$', 'once'))
      error = 'empty @example blocks';
      return
    end

    if (regexp (T{i}, '^[ \t]*>>', 'once'))
      %% Has '>>' input indicator in first line
      continue
    end

    % Categorize input and output lines in the example using
    % @result and @print macros.  Everything else, including comment lines and
    % empty lines, is categorized as input (for now).
    L = strsplit (T{i}, {'\r', '\n'});
    Linput = cellfun ('isempty', regexp (L, '^\s*(⇒|=>|-\|)', 'once'));

    if (not (Linput (1)))
      error = 'no command: @result on first line?';
      return
    end

    % Output lines may be wrapped or output goes over several lines and not
    % every line is preceded by “=>”.
    indent = regexp(L, '[^ \t]', 'once');
    indent(cellfun ('isempty', indent)) = inf;
    indent = [indent{:}] - 1;
    row = 1;
    while (row < numel (L))
      begin_of_input = row;
      begin_of_output = row + find (not (Linput(row + 1 : end)), 1);
      if (isempty (begin_of_output))
        begin_of_output = numel (L) + 1;
      end
      end_of_input = begin_of_output - 1;

      % determine minimum indentation of input lines
      min_indent = min (indent(begin_of_input : end_of_input));

      % Find next input line with an equal or less indentation to determine the
      % end of the output.
      row = begin_of_output ...
          + find (Linput(begin_of_output + 1: end) ...
                  & (indent(begin_of_output + 1: end) <= min_indent), ...
                  1);
      if (isempty (row))
        row = numel (L) + 1;
      end
      end_of_output = row - 1;

      if (end_of_output <= numel (L))
        Linput (begin_of_output : end_of_output) = false;
      end

      % Mark verified input lines as such
      L{begin_of_input} = ['>> ' L{begin_of_input}];
      L(begin_of_input + 1 : end_of_input) = ...
        cellfun (@(s) ['.. ' s], L(begin_of_input + 1 : end_of_input), ...
                 'UniformOutput', false);
    end

    % strip @result and @print macro output
    Loutput = not (Linput);
    L(Loutput) = regexprep (L(Loutput), ...
                            '^(\s*)(?:⇒|=>|-\|)', ...
                            '$1', ...
                            'once', 'lineanchors');

    T{i} = strjoin (L, '\n');
  end

  docstring = strjoin (T, '\n');
end
