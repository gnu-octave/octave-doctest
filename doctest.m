function doctest(func_or_class)
% Run examples embedded in documentation
%
% doctest func_name
% doctest('func_name')
% doctest class_name
% doctest('class_name')
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
% If the output of some function will change each time you call it, for
% instance if it includes a random number or a stack trace, you can put ***
% (three asterisks) where the changing element should be.  This acts as a
% wildcard, and will match anything.
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

to_test = { func_or_class };

theMethods = methods(func_or_class);
for I = 1:length(theMethods) % might be 0
    to_test = [ to_test; ...
        sprintf('%s.%s', func_or_class, theMethods{I}) ];
end

to_test

result = [];

for I = 1:length(to_test)
    result = [result, do_test(to_test{I})];
end
    
test_anything(result, 1);


end

function result = do_test(func_name)
docstring = help(func_name);

result = run_doctests(docstring);

end

