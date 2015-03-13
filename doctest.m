function doctest(func_or_class, varargin)
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
% 'add7(3)' and make sure that it gets back 'ans = 10'.  It prints out
% something like this:
%
%  add7: OK
%
% If the output of some function will change each time you call it, for
% instance if it includes a random number or a stack trace, you can put ***
% (three asterisks) where the changing element should be.  This acts as a
% wildcard, and will match anything.  See the example below.
%
% EXAMPLES:
%
% Running 'doctest doctest' will execute these examples and test the
% results.
%
% >> 1 + 3
%
% ans =
%
%      4
%
%
% Note the two blank lines between the end of the output and the beginning
% of this paragraph.  That's important so that we can tell that this
% paragraph is text and not part of the example!
%
% If there's no output, that's fine, just put the next line right after the
% one with no output.  If the line does produce output (for instance, an
% error), this will be recorded as a test failure.
%
% >> x = 3 + 4;
% >> x
%
% x =
%
%    7
%
%
% Exceptions:
% doctest can deal with errors, a little bit.  For instance, this case is
% handled correctly:
%
% >> not_a_real_function(42)
% ??? Undefined function
%
%
% But if the line of code will emit other output BEFORE the error message,
% the current version can't deal with that.  For more info see Issue #4 on
% the bitbucket site (below).  Warnings are different from errors, and they
% work fine.
%
% Wildcards:
% If you have something that has changing output, for instance line numbers
% in a stack trace, or something with random numbers, you can use a
% wildcard to match that part.
%
% >> dicomuid
% 1.3.6.1.4.1.***
%
%
% Multiple lines of code:
% Code spanning multiple lines of code can be entered by prefixing all
% subsequent lines with '..',  e.g.
%
% >> for i = 1:3
% ..   i
% .. end
%
% i = 1
% i = 2
% i = 3
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
% When you're working on writing/debugging a Matlab class, you might need
% to run 'clear classes' to get correct results from doctests (this is a
% general problem with developing classes in Matlab).
%
% It doesn't say what line number/file the doctest error is in.  This is
% because it uses Matlab's plain ol' HELP function to extract the
% documentation.  It wouldn't be too hard to write our own comment parser,
% but this hasn't happened yet.  (See Issue #2 on the bitbucket site,
% below)
%
%
% The latest version from the original author, Thomas Smith, is available
% at http://bitbucket.org/tgs/doctest-for-matlab/src
%
% This version, created by Michael Walter for multiline and Octave
% support (among other things), is available at
% https://github.com/catch22/doctest-for-matlab

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make a list of every method/function that we need to examine, in the
% to_test struct.
%

% determine whether we are running octave or matlab
try
  OCTAVE_VERSION;
  running_octave = 1;
catch
  running_octave = 0;
end

% We include a link to the function where the docstring is going to come
% from, so that it's easier to navigate to that doctest.
to_test = [];
to_test.name = func_or_class;
to_test.func_name = func_or_class;
to_test.link = sprintf('<a href="matlab:editorservices.openAndGoToLine(''%s'', 1);">%s</a>', ...
            which(func_or_class), func_or_class);


% If it's a class, add the methods to to_test.
if (~running_octave)
  theMethods = methods(func_or_class);
else
  % Octave unhappy on methods(<non-class>)
  if (exist(func_or_class, 'file'))
    theMethods = [];
  else
    theMethods = methods(func_or_class);
  end
end

for I = 1:length(theMethods) % might be 0
    this_test = [];

    this_test.func_name = theMethods{I};
    if (running_octave)
      this_test.name = sprintf('@%s/%s', func_or_class, theMethods{I});
    else
      this_test.name = sprintf('%s.%s', func_or_class, theMethods{I});
    end

    try
        this_test.link = sprintf('<a href="matlab:editorservices.openAndGoToFunction(''%s'', ''%s'');">%s</a>', ...
            which(func_or_class), this_test.func_name, this_test.name);
    catch
        this_test.link = this_test.name;
    end

    to_test = [to_test; this_test];
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Examine each function/method for a docstring, and run any examples in
% that docstring
%

% Can't predict number of results beforehand, depends of number of examples
% in each docstring.
result = [];

for I = 1:length(to_test)
    if running_octave
      [docstring, form] = get_help_text(to_test(I).name);
      if (strcmp(form, 'texinfo'))
        %% Just convert to plain text
        % Matlab parser unhappy with underscore, hide inside eval
        %docstring = eval('__makeinfo__(docstring, "plain text")');

        %% Find @example blocks
        % strip @group and @result{}
        docstring = strrep(docstring, '@result{}', '');
        % FIXME: pass through __makeinfo__ instead?
        docstring = strrep(docstring, '@group', '');
        docstring = strrep(docstring, '@end group', '');
        docstring = strrep(docstring, '@{', '{');
        docstring = strrep(docstring, '@}', '}');
        T = regexp(docstring, '@example(.*?)@end example', 'tokens');
        if (isempty(T))
          docstring = '';
        else
          T = strcat(T{:});
          docstring = T{1};
        end
      end
    else
      docstring = help(to_test(I).name);
    end

    these_results = doctest_run(docstring);


    if ~ isempty(these_results)
        [these_results.link] = deal(to_test(I).link);
    end

    result = [result, these_results];

    % Print the results after each file
    test_anything(to_test(I), these_results);
end

end


function test_anything(to_test, results)

out = 1; % stdout
err = 2;

total = length(results);
errors = 0;
for i = 1:total
  if ~results(i).pass
    errors = errors + 1;
  end
end

if total == 0
  fprintf(err, '%s: NO TESTS\n', to_test.name);
elseif errors == 0
  fprintf(out, '%s: OK (%d tests)\n', to_test.name, length(results));
else
  fprintf(err, '%s: %d ERRORS\n', to_test.name, errors);
end
for I = 1:length(results)
  if ~results(I).pass
    fprintf(out, '  >> %s\n\n', results(I).source);
    fprintf(out, '     expected: %s\n', results(I).want);
    fprintf(out, '     got     : %s\n', results(I).got);
  end
end


end
