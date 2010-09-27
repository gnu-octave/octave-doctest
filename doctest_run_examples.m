function [DOCTEST__b varargout] = testContext(DOCTEST__src, DOCTEST__srcOutput)
    % TESTCONTEXT   Executes the source code and tests for
    %               equality against the expected output
    %
    %   Input:
    %       DOCTEST__src       - source to execute, cellarry of statements
    %       DOCTEST__srcOutput - output to expect, cellarray of output of each statement
    %
    %   Output:
    %       DOCTEST__b         - true/false for success/failure of test
    %                          note that the output is strtrim()'ed then strcmp()'ed
    %       varargout{1}     - variable names assigned in this confined context
    %       varargout{2}     - variable values assigned
    %
    %   Example 1:
    %       source = { 'I = 5+33;' 'I' };
    %       output = { [], ['I =' char(10) '    38'] };
    %       b = testContext(source, output);
    %
    %   Example 2:
    %       source = { 'I = 5+33; J = 2;' 'K = 1;' 'disp(I+J+K)' };
    %       output = { [], [], '41' };
    %       [b varNames varValues] = testContext(source, output);
    %
    %   See also: eval evalc
    %

    DOCTEST__b = true;

    try
        % for each statement
        for DOCTEST__i=1:numel(DOCTEST__src)
            % evaluate
            DOCTEST__output = evalc( DOCTEST__src{DOCTEST__i} );
            DOCTEST__output = strtrim(DOCTEST__output);            % trim whitespaces
            % compare output
            if ~isempty( DOCTEST__srcOutput{DOCTEST__i} )
                if ~strcmp(DOCTEST__output,DOCTEST__srcOutput{DOCTEST__i})
                    DOCTEST__b = false;
                    return
                end
            end
        end

        if nargout > 1
            % list created variables in this context
            %clear ans
            DOCTEST__vars = whos('-regexp', '^(?!DOCTEST__).*');   % java regex negative lookahead
            varargout{1} = { DOCTEST__vars.name };

            if nargout > 2
                % return those variables
                varargout{2} = cell(1,numel(DOCTEST__vars));
                for DOCTEST__i=1:numel(DOCTEST__vars)
                    [~,varargout{2}{DOCTEST__i}] = evalc( DOCTEST__vars(DOCTEST__i).name );
                end
            end
        end

    catch ME
        warning(ME.identifier, ME.message)
        DOCTEST__b = false;
        varargout{1} = {};
        varargout{2} = {};
    end
end