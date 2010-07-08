function results = run_doctests(docstring)
%
% 
% >> 1 + 2
% ans =
%      3
%

% loosely based on Python 2.6 doctest.py, line 510
example_re = '(?m)(?-s)(?:^ *>> )(?<source>.*)\n(?<want>(?:(?:^ *$\n)?(?!\s*>>).*\w.*\n)*)';

[matches] = regexp(docstring, example_re, 'names', 'warnings');

results = [];

for I = 1:length(matches)
    
    % ['<<' matches(I).want '>>']
    
    got = evalc(matches(I).source);
    % ['{{' got '}}']
    
    want_unspaced = regexprep(matches(I).want, '\s+', ' ');
    
    got_unspaced = regexprep(got, '\s+', ' ');
    
    results(I).source = matches(I).source;
    results(I).want = want_unspaced;
    results(I).got = got_unspaced;
    results(I).pass = compare(want_unspaced, got_unspaced);
    
end


