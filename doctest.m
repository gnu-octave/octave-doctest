function doctest(func_name, verbose)
% Run examples embedded in documentation
%
% doctest func_name
% doctest('func_name')
%
% Example:
% Say you have a function that adds 7 to things:
%     function res = add7(num)
%         % >> add7(3)
%         %
%         % ans =
%         %
%         %      10
%         %
%         res = num + 7;
%     end
% 
% Save that to 'add7.m'.  Now you can say 'doctest add7' and it will run
% 'add7(3)' and make sure that it gets back 'ans = 10'.
%
%
% LIMITATIONS:
%
% The examples MUST END with either the END OF THE DOCUMENTATION or TWO
% BLANK LINES (or anyway, lines with just the comment marker % and nothing
% else).
%
% All adjascent white space is collapsed into a single space before
% comparison, so right now it can't detect anything that's purely a
% whitespace difference.
%
% It can't run lines that are longer than one line of code (so, for
% example, no loops that take more than one line).  This is difficult
% because I haven't found a good way to mark these subsequent lines as
% part-of-the-source-code rather than part-of-the-result.
% 

docstring = help(func_name);

if nargin < 2
    verbose = 0;
else
    verbose = 1;
end


test_anything(run_doctests(docstring), verbose);

end

