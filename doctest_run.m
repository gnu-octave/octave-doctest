function results = doctest_run(docstring)
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

file_for_persisting = [ tempname() '.mat' ];

for I = 1:length(matches)

    got = doctest_evalc_persist(matches(I).source, file_for_persisting);
    
    want_unspaced = regexprep(matches(I).want, '\s+', ' ');
    
    got_unspaced = regexprep(got, '\s+', ' ');
    

    
    results(I).source = matches(I).source;
    results(I).want = strtrim(want_unspaced);
    results(I).got = strtrim(got_unspaced);
    results(I).pass = doctest_compare(want_unspaced, got_unspaced);
    
end

delete(file_for_persisting);

end



function doctest_result = doctest_evalc_persist(doctest_example_to_run, doctest_file_to_save)
% I wish I had my very own namespace...

if exist(doctest_file_to_save, 'file')
    load(doctest_file_to_save);
end

try
    doctest_result = evalc(doctest_example_to_run);
catch doctest_exception
    doctest_result = doctest_format_exception(doctest_exception);
end

% to prevent SAVE from dying because it can't save anything
abcdefghijklmnopqrstuvwxyz0123456789_doctest_bleah = 1;

save(doctest_file_to_save, '-regexp', '^(?!doctest_).');

end

function formatted = doctest_format_exception(ex)

if strcmp(ex.stack(1).name, 'doctest_evalc_persist')
    % we don't want the report, we just want the message
    % otherwise it'll talk about evalc, which is not what the user got on
    % the command line.
    formatted = ['??? ' ex.message];
else
    formatted = ['??? ' ex.getReport('basic')];
end



end



