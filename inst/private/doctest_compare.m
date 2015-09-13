function match = doctest_compare(want, got, normalize_whitespace, ellipsis)
% Matches two strings together.  They should be identical, except:
%
%   * multiple spaces are collapsed (if NORMALIZE_WHITESPACE is true);
%   * the first one can contain '...', which matches anything in the
%     second (if ELLIPSIS is true);
%   * they might match after putting "ans = " on the first;
%   * various other nonsense of unknown current relevance.
%

% This looks bad, like hardcoding for lower-case "a href"
% and a double quote... but that's what MATLAB looks for too.
got = regexprep(got, '<a +href=".*?>', '');
got = regexprep(got, '</a>', '');

% WHY do they need backspaces?  huh.
got = regexprep(got, '.\x08', '');

% collapse multiple spaces to one
if normalize_whitespace
    want = strtrim(regexprep(want, '\s+', ' '));
    got = strtrim(regexprep(got, '\s+', ' '));
else
    want = strtrim(strtrim_lines_discard_empties(want));
    got = strtrim(strtrim_lines_discard_empties(got));
end

if isempty(got) && (isempty(want) || (ellipsis && strcmp(want, '...')))
    match = 1;
    return
end

want_re = regexptranslate('escape', want);
if ellipsis
  want_re = regexprep(want_re, '(\\\.){3}', '.*');
end

% allow "ans = " to be missing
want_re = ['^(ans\s*=\s*)?' want_re '$'];


result = regexp(got, want_re, 'once');

match = ~ isempty(result);

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
