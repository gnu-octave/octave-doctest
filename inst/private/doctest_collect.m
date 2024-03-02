function summary = doctest_collect(w, directives, summary, recursive, verbose, depth, fid)
%DOCTEST_COLLECT  Find and run doctests.
%
%   The input W is the name of a class, directory, function or filename:
%   * For a directory, calls itself on the contents, recursively if
%     RECURSIVE is true;
%   * For a class, all methods are tested;
%   * When running Octave, it can also be the filename of a Texinfo file.

%%
% Copyright (c) 2010 Thomas Grenfell Smith
% Copyright (c) 2015 Michael Walter
% Copyright (c) 2015-2019, 2022-2024 Colin B. Macdonald
% Copyright (c) 2015 Oliver Heimlich
% Copyright (C) 2018 Mike Miller
% SPDX-License-Identifier: BSD-3-Clause


% TODO: methods('logical') octave/matlab differ: which behaviour do we want?
% TODO: what about builtin "test" versus dir "test/"?  Do we prefer dir?

if (isempty(w))
  return
end

% determine type of target
if is_octave()
  % Note: ripe for refactoring once "exist(w, 'class')" works in Octave.
  [~, ~, ext] = fileparts(w);
  if any(strcmpi(ext, {'.texinfo' '.texi' '.txi' '.tex'}))
    type = 'texinfo';
  elseif (strcmp (ext, '.oct') && exist (w) == 3)  % .oct explicitly
    type = 'octfile';
  elseif (exist (w) == 3)  % .oct/.mex
    [~, w, ~] = fileparts (w);  % strip extension if present
    type = 'function';                % then access like any function
  else
    type = 'unknown';
  end

  %% Let's see if its a class by checking if methods returns
  % What about classdef in oct file above?  Should we do this even if
  % type is 'octfile'?
  if (strcmp (type, 'unknown'))
    if (~ isempty (w) && strcmp (w(1), '@'))
      temp = w(2:end);
    else
      temp = w;
    end
    try
      temp = methods(temp);
      type = 'class';
    catch
      type = 'unknown';
    end
  end

  if (strcmp (type, 'unknown'))
    if (exist(w, 'dir'))
      type = 'dir';
    elseif (exist(w, 'file') || exist(w, 'builtin') || exist(w) == 103)
      type = 'function';
    else
      type = 'unknown';
    end
  end

  % This covers anything that we can get help from that wasn't covered above,
  % notably "doctest class.method".  Quite possibly some other things too.
  if (strcmp (type, 'unknown'))
    try
      if (~isempty (help (w)))
        type = 'function';
      end
    catch
      % no-op
    end
  end

else % Matlab
  if (strcmp(w(1), '@')) && ~isempty(methods(w(2:end)))
    % covers "doctest @class", but not "doctest @class/method"
    type = 'class';
  elseif ~isempty(methods(w))
    % covers "doctest class"
    type = 'class';
  elseif (exist(w, 'dir'))
    type = 'dir';
  elseif exist(w, 'file') || exist(w, 'builtin');
    type = 'function';
  elseif ~isempty(help(w))
    % covers "doctest class.method" and "doctest class/method"
    % no try-catch needed as no error when w has no help
    type = 'function';
  else
    type = 'unknown';
  end
  % Note: ambiguous what happens for "doctest @class/method"... as it is
  % for "help @class/method", e.g., "help @class/class" does not give the
  % constructor's help.
end


% Deal with directories
if (strcmp(type, 'dir'))
  if (strcmp(w, '.'))
    if (depth == 0)
      % cheap hack to not indent when calling "doctest ."
      depth = -1;
    end
  else
    spaces = repmat(' ', 1, 2*depth);
    if (strcmp(w(end), filesep()))
      slashchar = '';
    else
      slashchar = filesep();
    end
    if (verbose)
      fprintf(fid, '%s%s%s\n', spaces, w, slashchar);
    end
  end
  oldcwd = chdir(w);
  files = dir('.');
  for i=1:numel(files)
    f = files(i).name;
    if (exist(f, 'dir'))
      if (strcmp(f, '.') || strcmp(f, '..'))
        % skip "." and ".."
        continue
      elseif (strcmp(f(1), '@'))
        % class, don't skip if nonrecursive
      elseif (~ recursive)
        % skip all directories
        continue
      elseif (strcmp(f(1), '.'))
        %fprintf(fid, 'Ignoring hidden directory "%s"\n', f)
        continue
      end
    else
      [~, ~, ext] = fileparts(f);
      if (~ any(strcmpi(ext, ...
                {'.m' '.texinfo' '.texi' '.txi' '.tex' '.oct' '.mex'})))
        %fprintf(fid, 'Debug: ignoring file "%s"\n', f)
        continue
      end
    end
    summary = doctest_collect(f, directives, summary, recursive, verbose, depth + 1, fid);
  end
  chdir(oldcwd);
  return
end



% Build structure array with the following fields:
%   TARGETS(i).name       Human-readable name of test.
%   TARGETS(i).link       Hyperlink to test for use in Matlab.
%   TARGETS(i).docstring  Associated docstring.
%   TARGETS(i).error:     Contains error string if extraction failed.
%   TARGETS(i).depth      How "deep" in a recursive traversal are we

if strcmp(type, 'function')
  target = collect_targets_function(w);
  target.depth = depth;
  targets = [target];
elseif strcmp(type, 'class')
  targets = collect_targets_class(w, depth);
elseif strcmp (type, 'octfile')
  targets = collect_targets_octfile (w, depth);
elseif strcmp(type, 'texinfo')
  target = struct();
  target.name = w;
  target.link = '';
  target.depth = depth;
  [target.docstring, target.error] = parse_texinfo(fileread(w));
  targets = [target];
else
  target = struct();
  target.name = w;
  target.link = '';
  target.depth = depth;
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
  spaces = repmat(' ', 1, 2*target.depth);
  dots = repmat('.', 1, 55 - numel(target.name) - 2*target.depth);
  if (verbose)
    fprintf(fid, '%s%s %s ', spaces, target.name, dots);
  end

  % extraction error?
  if target.error
    summary.num_targets_with_extraction_errors = summary.num_targets_with_extraction_errors + 1;
    if (verbose)
      fprintf(fid, [color_err  'EXTRACTION ERROR' reset '\n\n']);
      fprintf(fid, '    %s\n\n', target.error);
    end
    continue;
  end

  % run doctest
  results = doctest_run_docstring(target.docstring, directives);

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

  if (verbose)
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
          if results(j).xfail
            fprintf(fid, '      expected failure, but test succeeded!');
          end
          fprintf(fid, '\n');
        end
      end
    end
  end
end

end



function target = collect_targets_function(w)
  target = struct();
  target.name = w;
  if is_octave()
    target.link = '';
  else
    target.link = sprintf('<a href="matlab:editorservices.openAndGoToLine(''%s'', 1);">%s</a>', which(w), w);
  end
  [target.docstring, target.error] = extract_docstring(target.name);
end


function targets = collect_targets_class(w, depth)
  if (strcmp(w(1), '@'))
    % Octave methods('@foo') gives java error, Matlab just says "No methods"
    w = w(2:end);
  end

  % workaround github.com/gnu-octave/octave-doctest/issues/135 by
  % accessing all non-constructor method help text *before* "help obj"
  if (is_octave () && compare_versions (OCTAVE_VERSION, '7.0.0', '<'))
    meths = methods (w);
    for i=1:numel (meths)
      if (~ strcmp (meths{i}, w))  % skip @obj/obj
        name = sprintf ('@%s%s%s', w, filesep (), meths{i});
        [docstring, format] = get_help_text (name);
      end
    end
  end  % end workaround

  % First, "help class".  For classdef, this differs from "help class.class"
  % (general class help vs constructor help).  For old-style classes we will
  % probably end up testing the constructor twice but... meh.
  target.name = w;
  if is_octave()
    target.link = '';
  else
    target.link = sprintf('<a href="matlab:editorservices.openAndGoToLine(''%s'', 1);">%s</a>', which(w), w);
  end
  target.depth = depth;
  [target.docstring, target.error] = extract_docstring(target.name);
  targets = target;

  % Next, add targets for all class methods
  meths = methods(w);
  meths = unique (meths);  % Issue #260
  for i=1:numel(meths)
    target = struct();
    if is_octave()
      if compare_versions (OCTAVE_VERSION, '9.0.0', '>=') && exist (w, "class") == 8
        % classdef on newish Octave: use cls.method
        target.name = sprintf ('%s.%s', w, meths{i});
        target.link = '';
      elseif compare_versions (OCTAVE_VERSION, '7.0.0', '>=') && exist (w, "class") == 8
        % use cls.method, use cls.method, but skip cls.cls
        if strcmp (meths{i}, w)
          % gathering the ctor help fails https://savannah.gnu.org/bugs/?62803
          continue
        end
        target.name = sprintf ('%s.%s', w, meths{i});
        target.link = '';
      else
        % use @cls/method for old-style classes https://savannah.gnu.org/bugs/?61521
        target.name = sprintf ('@%s%s%s', w, filesep (), meths{i});
        target.link = '';
      end
    else
      target.name = sprintf('%s.%s', w, meths{i});
      target.link = sprintf('<a href="matlab:editorservices.openAndGoToFunction(''%s'', ''%s'');">%s</a>', which(w), meths{i}, target.name);
    end
    target.depth = depth;
    [target.docstring, target.error] = extract_docstring(target.name);
    targets = [targets; target];
  end
end


function targets = collect_targets_octfile (file, depth)
  % first target is the name of the octfile (w/o extension)
  [~, basename, ext] = fileparts (file);
  assert (strcmp (ext, '.oct'))
  target = collect_targets_function (basename);
  target.name = file;
  target.depth = depth;
  targets = [target];

  % octfile may have many fcns in it: find them using the autoload map
  autoloadmap = autoload ();
  len = numel (file);
  % matches both "/foo/bar.oct" and "/baz/bar.oct"; uncommon in practice
  pmatch = @(e) (numel (e.file) >= len) && strcmp (e.file(end-len+1:end), file);
  idx = find (arrayfun (pmatch, autoloadmap));

  if (~ isempty (idx))
    % indicate that octfile has other fcns, and indent those targets
    targets(1).name = [targets(1).name ':'];
    for i = 1:numel (idx)
      f = autoloadmap(idx(i)).function;
      target = collect_targets_function (f);
      target.depth = depth + 1;
      targets = [targets; target];
    end
  end
end


function [docstring, error] = extract_docstring(name)
  if is_octave()
    [docstring, format] = get_help_text(name);
    if strcmp(format, 'texinfo')
      [docstring, error] = parse_texinfo(docstring);
    elseif strcmp(format, 'plain text')
      error = '';
    elseif strcmp(format, 'Not documented')
      assert (isempty (docstring))
      error = '';
    elseif strcmp(format, 'Not found')
      % looks like "doctest test_no_docs.m" gets us here: octave bug?
      if (regexp(name,'\.m$'))
        assert (isempty (docstring))
        error = '';
      else
        assert (isempty (docstring))
        error = 'Not an m file.';
      end
    else
      format
      warning('Doctest:unexpected-format', 'Unexpected format in that file/function');
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

  % Normalize line endings in files which have been edited in Windows
  % This simplifies the regular expressions below.
  str = strrep (str, sprintf ('\r\n'), sprintf ('\n'));

  % The subsequent regexprep would fail if the example block is located right
  % at the beginning of the file. This is probably a bug in regexprep and is
  % only possible inside included texinfo files.
  if (isempty (regexp (str, '^\s', 'once')))
    str = cstrcat (sprintf ('\n'), str);
  end

  % Mark the occurrence of “@example” and “@end example” to be able to find
  % example blocks after conversion from texi to plain text.  Also consider
  % indentation, so we can later correctly unindent the example's content.

  % These should work, but I keep hitting ARM-specific when $1 is empty:
  % https://savannah.gnu.org/bugs/index.php?52810
  % TODO: fixed in 4.2.2, so can revert this once we drop 4.2.1 support
  %str = regexprep (str, ...
  %                 '^([ \t]*)(\@example)(.*)$', ...
  %                 [ '$1$2$3\n', ... % retain original line
  %                   '$1###### EXAMPLE START ######'], ...
  %                 'lineanchors', 'dotexceptnewline', 'emptymatch');
  %str = regexprep (str, ...
  %                 '^([ \t]*)(\@end example)(.*)$', ...
  %                 [ '$1###### EXAMPLE STOP ######\n', ...
  %                   '$1$2$3'], ... % retain original line
  %                 'lineanchors', 'dotexceptnewline', 'emptymatch');

  % Instead we do it manually
  [S, E, TE, M, T, NM, SP] = regexp (str, '^([ \t]*)(\@example)(.*)$', ...
                             'lineanchors', 'dotexceptnewline', 'emptymatch');
  str = SP{1};
  for i=1:length (T)
    str = [str ...
           T{i}{:} sprintf('\n') ...  % retain original line
           T{i}{1} '###### EXAMPLE START ######' ...
           SP{i+1}];
  end

  [S, E, TE, M, T, NM, SP] = regexp (str, '^([ \t]*)(\@end example)(.*)$', ...
                             'lineanchors', 'dotexceptnewline', 'emptymatch');
  str = SP{1};
  for i=1:length (T)
    str = [str ...
           T{i}{1} '###### EXAMPLE STOP ######' sprintf('\n') ...
           T{i}{:} ...  % retain original line
           SP{i+1}];
  end

  % special comments "@c doctest: cmd" are translated
  % FIXME the expression would also match @@c doctest: ...
  re = [ '(?:\@c(?:omment)?\s' ... % @c or @comment, ?: means no token
            '|#|%)\s*'        ... % or one of #,%
         '(doctest:\s*.*)' ];     % want the doctest token
  str = regexprep (str, re, '% $1', 'dotexceptnewline');

  % We use eval to not produce compile errors in Matlab,
  % the __makeinfo__ function exists in Octave only.
  [str, err] = eval('__makeinfo__ (str, ''plain text'')');
  if (err ~= 0)
    error = sprintf('__makeinfo__ returned error code %d', err);
    return
  end

  % Normalize end of line characters again.  __makeinfo__ returns end of line
  % characters depending on the current OS.  Since we want Unix line endings,
  % the conversion is only required under Windows.
  if (ispc ())
    str = strrep (str, sprintf ('\r\n'), sprintf ('\n'));
  end

  % extract examples and discard everything else
  T = regexp (str, ...
              [ '(^[ \t]*###### EXAMPLE START ######', ...
                '.*?', ...
                '###### EXAMPLE STOP ######$)'], ...
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
    T{i} = regexprep (T{i}, sprintf ('^[ \t]{%d}', indent), '', 'lineanchors');

    % remove EXAMPLE markers
    T{i} = regexprep (T{i}, ...
                      '[ \t]*###### EXAMPLE ST(?:ART|OP) ######(?:\n|$)', ...
                      '');

    if (regexp (T{i}, '^\s*$', 'once', 'emptymatch'))
      error = 'empty @example blocks';
      return
    end

    if (regexp (T{i}, '^\s*>>', 'once'))
      % First nonblank line starts with '>>': assume diary style.  However,
      % we strip @result and @print macros (TODO: perhaps unwisely?)
      L = strsplit (T{i}, '\n');
      L = regexprep (L, '^(\s*)(?:⇒|=>|⊣|-\||error→|error->)', '$1', 'once', 'lineanchors');
      T{i} = strjoin (L, '\n');
      continue
    end


    % Hack: the @example block is commonly mis-used to store non-examples such as
    % diagrams or math.  Delete an example block that has no indicated output.
    % (Hard to leave for "later" as we don't keep track of @example blocks.)
    R1 = regexp (T{i}, '^\s*(⇒|=>|⊣|-\||error→|error->)', 'lineanchors');
    R2 = regexp (T{i}, '(doctest:\s+-TEXINFO_SKIP_BLOCKS_WO_OUTPUT)');
    T{i} = regexprep (T{i}, '(doctest:\s+-TEXINFO_SKIP_BLOCKS_WO_OUTPUT)', '');
    if (isempty (R1) && isempty (R2))
      T{i} = '';
      continue
    end

    % split into lines
    L = strsplit (T{i}, '\n');

    % Categorize input and output lines in the example using
    % @result and @print macros.  Everything else, including comment lines and
    % empty lines, is categorized as input (for now).
    Linput = cellfun ('isempty', regexp (L, '^\s*(⇒|=>|⊣|-\||error→|error->)', 'once'));

    if (not (Linput (1)))
      error = 'no command: @result on first line?';
      return
    end

    % Output lines may be wrapped or output goes over several lines and not
    % every line is preceded by “=>”.
    indent = regexp(L, '\S', 'once');
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
                            '^(\s*)(?:⇒|=>|⊣|-\||error→|error->)', ...
                            '$1', ...
                            'once', 'lineanchors');

    T{i} = strjoin (L, '\n');
  end

  docstring = strjoin (T, '\n');
end
