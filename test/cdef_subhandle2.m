classdef cdef_subhandle2 < handle
% >> a = 42
% a = 42

  properties
  end

  methods
    function obj = cdef_subhandle2()
    end
    function disp(obj)
      % >> a = 43
      % a = 43
      % >> a = a + 1
      % a = 44
      fprintf('hi')
    end
  end
end
