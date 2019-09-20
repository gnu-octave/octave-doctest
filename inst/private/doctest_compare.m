function match = doctest_compare(want, got, normalize_whitespace, ellipsis)
%DOCTEST_COMPARE  Check if two strings match.
%
%   Returns true if string GOT matches the template string WANT.  Basically
%   WANT and GOT should be identical, except:
%
%   * whitespace at the start/end of each line is trimmed;
%   * multiple spaces are collapsed (if NORMALIZE_WHITESPACE is true);
%   * WANT can have "..."; matches anything in GOT (if ELLIPSIS is true);
%   * WANT can omit "ans = ";
%   * various other nonsense of unknown current relevance.

%%
% Copyright (c) 2010 Thomas Grenfell Smith
% Copyright (c) 2015 Michael Walter
% Copyright (c) 2015-2016 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause


% This looks bad, like hardcoding for lower-case "a href"
% and a double quote... but that's what MATLAB looks for too.
got = regexprep(got, '<a +href=".*?>', '');
got = regexprep(got, '</a>', '');

% WHY do they need backspaces?  huh.
got = regexprep(got, '.\x08', '');

  want = strtrim(want);
  got = strtrim(got);

  if (isempty(got) && (isempty(want) || (ellipsis && strcmp(want, '...'))))
    match = 1;
    return
  end

  want = regexptranslate('escape', want);
  if normalize_whitespace
    % collapse multiple spaces, then have each match many
    if is_octave && compare_versions (OCTAVE_VERSION, '4.1', '<')
      want = regexprep(want, '\s+', '\s+');
    else
      want = regexprep(want, '\s+', '\\s\+');
    end
  else
    want = strtrim_lines_discard_empties(want);
    got = strtrim_lines_discard_empties(got);
  end

  if ellipsis
    want = regexprep(want, '(\\\.){3}', '.*');
  end

  % allow "ans = " to be missing
  want = ['^(ans\s*=\s*)?' want '$'];


  result = regexp(got, want, 'once');

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
