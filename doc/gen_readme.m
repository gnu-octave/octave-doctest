% To generate .../doctest/README.html, 
% change directory to .../doctest/doc
% then run gen_readme
% 
% Then in the shell run html2markdown.py README.html > README.markdown
%

opts = [];
opts.format = 'html';
opts.outputDir = '..';

publish('README', opts);

if ~ exist('html2text.py', 'file')
    ! wget http://www.aaronsw.com/2002/html2text/html2text.py
    ! chmod a+rx html2text.py
end

! ./html2text.py ../README.html > ../README.markdown


