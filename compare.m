function match = compare(want, got)
want_escaped = regexptranslate('escape', want);
want_re = regexprep(want_escaped, '(\\\*){3}', '.*');



match = regexp(got, want_re);

end