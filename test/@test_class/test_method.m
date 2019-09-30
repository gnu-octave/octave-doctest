function result = test_method(obj, varargin)
%
% >> m = test_class; disp(test_method(m))
% Default Name is 42 years old.

result = sprintf('%s is %d years old.', obj.name, obj.age);

end
