function d = doctest_default_directives(varargin)
%DOCTEST_DEFAULT_DIRECTIVES  Return/set defaults directives
%   Possible calling forms:
%     dirs = doctest_default_directives()
%     dirs = doctest_default_directives('ellipsis', true)
%     dirs = doctest_default_directives(dirs, 'ellipsis', true)
%   See source/documentation for valid directives.

  defaults.normalize_whitespace = true;
  defaults.ignore_blocks_wo_output = false;
  defaults.ellipsis = true;

  if (nargin == 0)
    d = defaults;
    return
  elseif (nargin == 2)
    d = defaults;
    directive = varargin{1};
    enable = varargin{2};
  elseif (nargin == 3)
    d = varargin{1};
    directive = varargin{2};
    enable = varargin{3};
  else
    error('invalid input')
  end

  switch directive
    case 'ELLIPSIS'
      d.ellipsis = enable;
    case 'NORMALIZE_WHITESPACE'
      d.normalize_whitespace = enable;
    case 'IGNORE_BLOCKS_WO_OUTPUT'
      d.ignore_blocks_wo_output = enable;
    otherwise
      error('invalid directive "%s"', directive)
  end

end
