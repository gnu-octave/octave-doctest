function match = compare(want, got)
% Matches two strings together... they should be identical, except that the
% first one can contain '***', which matches anything in the second string.

got = regexprep(got, '<a href=.*?>', '');
got = regexprep(got, '</a>', '');
got = regexprep(got, '.\x08', ''); % WHY do they need backspaces?  huh.

want = strtrim(want);
got = strtrim(got);
any(got == '{')
if isempty(want) && isempty(got)
    match = 1;
    return
end

want_escaped = regexptranslate('escape', want);
want_re = regexprep(want_escaped, '(\\\*){3}', '.*');



match = regexp(got, want_re);

end