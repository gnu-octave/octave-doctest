classdef test_classdef
%TEST_CLASSDEF  A test for classdef classes
%
%   Some tests:
%   >> 6 + 7
%   ans = 13
%
%   >> a = test_classdef()
%   a =
%   class name = "default", age = 42
%
%
%   This general help text should be shown for "help test_classdef".
%
%   There are also tests in the methods below.

  properties
    name
    age
  end

  methods

    function obj = test_classdef(n, a)
      % constructor help text
      %
      % note sure how to see this but here's an embedded doctest
      %
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
      % disp method help text
      % >> a = 30 + 2
      % a = 32
      fprintf('class name = "%s", age = %d\n', obj.name, obj.age)
    end
  end
end
