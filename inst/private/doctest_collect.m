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

  % strip @group, and escape sequences
  str = regexprep(str, '^\s*@group\n', '\n', 'lineanchors');
  str = regexprep(str, '@end group\n', '');
  str = strrep(str, '@{', '{');
  str = strrep(str, '@}', '}');
  str = strrep(str, '@@', '@');

  % special comments "@c doctest: cmd" are translated
  re = [ '@c(?:omment)?'    ...  % @c or @comment, ?: means no token
         '\s*(?:#|%|\s)\s*' ...  % at least one space or one of #,%
         '(doctest:\s*.*\n)' ];  % want the doctest token
  str = regexprep(str, re, '% $1', 'dotexceptnewline');

  % texinfo comments: drop remainder of line
  str = regexprep(str, '@c(omment)?\s+.*\n', '\n', 'dotexceptnewline');

  % no example blocks? not an error, but nothing to do
  if (isempty(strfind(str, '@example')))
    % error = 'no @example blocks';
    return
  end

  % leave the @example lines in, may need them later
  T = regexp(str, '(@example.*?@end example)', 'tokens');
  if (isempty(T))
    error = 'malformed @example blocks';
    return
  else
    % flatten
    for i=1:length(T)
      assert(length(T{i}) == 1)
      T{i} = T{i}{1};
    end
    str = strjoin(T, '\n');
  end

  % replace @var{abc} with abc
  str = regexprep(str, '\@var\{(\w+)\}', '$1');

  if (isempty(str) || ~isempty(regexp(str, '^\s*$')))
    error = 'empty @example blocks';
    return
  end

  if (~isempty(strfind(str, '>>')))
    %% Has '>>' indicators
    % err = 1;  msg = 'used >>';
  else
    %% No '>>', split on @result
    % err = 2;  msg = 'used @result splitting';
    L = strsplit (str, '\n');

    % mask for lines with @result in them
    S = regexp(L, '@result\s*{}');
    Ires = ~cellfun(@isempty, S);
    if (nnz(Ires) == 0)
      if (isempty(regexp(str, '% doctest: \+SKIP\n')))
        error = 'has @example blocks but neither ">>" nor "@result{}"';
        return
      else
        % PR #72: special case if no >>, no @result, but +SKIP is present.
        % Don't raise extraction error; workaround could mask later errors
        % but low risk (as someone has deliberately marked +SKIP).
        return
      end
    end
    if Ires(1)
      error = 'no command: @result on first line?';
      return
    end
    for i=1:length(L)
      if (length(S{i}) > 1)
        error = 'more than one @result on one line';
        return
      end
    end

    % mask for lines with @example in them
    Iex_start = ~cellfun(@isempty, regexp(L, '@example'));
    Iex_end = ~cellfun(@isempty, regexp(L, '@end example'));

    % build a new mask for lines which we think are commands
    I = false(size(Ires));
    start_of_block = false;
    for i=1:length(L)-1
      if Iex_start(i)
        start_of_block = true;
      end
      if (start_of_block)
        I(i) = true;
      end
      if Ires(i+1)
        % Next line has an @result so mark this line with '>>'
        I(i) = true;
        start_of_block = false;
      end
    end
    % remove @example/@end lines from commands
    I(Iex_start) = false;
    I(Iex_end) = false;

    starts = [0 diff(I)] == 1;
    for i=1:length(L)
      if (I(i) && ~isempty(L{i}) && isempty(regexp(L{i}, '^\s+$', 'match')))
        if (starts(i))
          L{i} = ['>> ' L{i}];
        else
          L{i} = ['.. ' L{i}];
        end
      end
    end
    str = strjoin(L, '\n');
    str = [str sprintf('\n')];
  end
  str = regexprep(str, '^\s*@example\n', '', 'lineanchors');
  str = regexprep(str, '^\s*@end example\n', '', 'lineanchors');
  str = regexprep(str, '@result\s*{}', '');

  docstring = str;
end
