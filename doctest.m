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

docstring = help(func_name);

if nargin < 2
    verbose = 0;
else
    verbose = 1;
end


test_anything(run_doctests(docstring), verbose);

end

