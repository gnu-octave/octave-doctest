function obj = test_class
%
% >> class(test_class)
% ans = test_class
%
%
% >> methods test_class
% Methods for class test_class:
% test_class   test_method

obj = struct;
obj.name = 'Default Name';
obj.age = 42;
obj = class(obj, 'test_class');

end
