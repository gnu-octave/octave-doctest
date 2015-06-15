function obj = test_shadow()
% >> 6 + 7
% ans = 13

  obj = struct()
  obj.name = 'Do not shadow me bro';
  obj = class(obj, 'test_shadow');

end
