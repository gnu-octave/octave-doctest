% To generate .../doctest/README.html, 
% change directory to .../doctest/doc
% then run gen_readme

opts = [];
opts.format = 'html';
opts.outputDir = '..';

publish('README', opts);
