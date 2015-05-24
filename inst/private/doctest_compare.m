function match = doctest_compare(want, got, ellipsis)
% Matches two strings together.  They should be identical, except:
%
%   * the first one can contain '...', which matches anything in
%     the second (if ellipsis is true)
%   * they might match after putting "ans = " on the first;
%   * various other nonsense of unknown current relevance.
%

% This looks bad, like hardcoding for lower-case "a href"
% and a double quote... but that's what MATLAB looks for too.
got = regexprep(got, '<a +href=".*?>', '');
got = regexprep(got, '</a>', '');

% WHY do they need backspaces?  huh.
got = regexprep(got, '.\x08', '');

want = strtrim(want);
got = strtrim(got);

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
