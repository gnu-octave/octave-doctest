classdef cdef_subhandle1 < handle
% >> a = 42
% a = 42

  properties
  end

  methods
    function obj = cdef_subhandle1()
    end
    function delete()
      % >> a = 43
      % a = 43
    end
    function disp(obj)
      % >> a = 44
      % a = 44
      % >> a = a + 1
      % a = 45
      fprintf('hi')
    end
  end
end
