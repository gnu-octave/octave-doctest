function match = compare(want, got)
% Matches two strings together... they should be identical, except that the
% first one can contain '***', which matches anything in the second string.
want_escaped = regexptranslate('escape', want);
want_re = regexprep(want_escaped, '(\\\*){3}', '.*');



match = regexp(got, want_re);

end