function targets = doctest_collect(what)
% Collect all targets for given name.
%
% The parameter WHAT is the name of a function or class. In the latter case,
% all methods are tested. When running Octave, it can also be the filename of
% a Texinfo file.
%
% Returns a structure array with the following fields:
%
%   TARGETS(i).name       Human-readable name of test.
%   TARGETS(i).link       Hyperlink to test for use in Matlab.
%   TARGETS(i).docstring  Associated docstring.
%   TARGETS(i).error:     Contains error string if extraction failed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: methods('logical') octave/matlab differ: which behaviour do we want?
% TODO: what about builtin "test" versus dir "test/"?  Do we prefer dir?

% determine type of target
if is_octave()
  [~, ~, ext] = fileparts(what);
  if any(strcmpi(ext, {'.texinfo' '.texi' '.txi' '.tex'}))
    type = 'texfile';
  elseif (exist(what, 'file') && ~exist(what, 'dir')) || exist(what, 'builtin');
    type = 'function';
  elseif exist(what) == 2 || exist(what) == 103
    % Notes:
    %   * exist('@class', 'dir') only works if pwd is the parent of
    %     '@class', having it in the path is not sufficient.
    %   * Return 2 on Octave 3.8 and 103 on Octave 4.
    type = 'class';
  else
    type = false;
  end
else
  if ~isempty(methods(what))
    type = 'class';
  elseif exist(what, 'file') || exist(what, 'builtin');
    type = 'function';
  else
    type = false;
  end
end
if ~type
  target = struct;
  target.name = what;
  target.link = '';
  target.docstring = '';
  target.error = 'Function or class not found.';
  targets = [target];
  return;
end


% add target(s)
if strcmp(type, 'function')
  target = struct;
  target.name = what;
  if is_octave()
    target.link = '';
  else
    target.link = sprintf('<a href="matlab:editorservices.openAndGoToLine(''%s'', 1);">%s</a>', which(what), what);
  end
  [target.docstring, target.error] = extract_docstring(target.name);
  targets = [target];

elseif strcmp(type, 'class')
  % add target for all methods
  meths = methods(what);
  targets = [];
  for i=1:numel(meths)
    target = struct;
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

else
  % parse texinfo file
  target.name = what;
  target.link = '';
  [target.docstring, target.error] = parse_texinfo(fileread(what));
  targets = [target];
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
