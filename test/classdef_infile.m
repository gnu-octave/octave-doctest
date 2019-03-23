classdef classdef_infile
%CLASSDEF_INFILE  A classdef living in a single m-file
%
%   Some tests:
%   >> 6 + 7
%   ans = 13
%
%   >> a = classdef_infile()
%   a =
%   class name = "default", age = 42
%
%
%   This general help text should be shown for "help classdef_infile".
%
%   There are also tests in the methods below.

  properties
    name
    age
  end

  methods

    function obj = classdef_infile(n, a)
      % constructor
      % >> a = 13 + 1
      % a = 14
      if (nargin ~= 2)
        obj.name = 'default';
        obj.age = 42;
      else
        obj.name = n;
        obj.age = a;
      end
    end
  end
  methods
    function disp(obj)
      % >> a = 30 + 2
      % a = 32
      fprintf('class name = "%s", age = %d\n', obj.name, obj.age)
    end
  end
end
