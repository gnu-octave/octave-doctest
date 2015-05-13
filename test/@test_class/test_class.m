function obj = test_class
%
% >> class(test_class)
% ans = test_class

obj = struct;
obj.name = 'My name';
obj.age = 42;
obj = class(obj, 'test_class');

end
