function y = mynewmethod(x)
%MYNEWMETHOD: monkey patch something onto class logical
%   >> a = 42
%   a = 42
%   >> mynewmethod(true)
%   ans = 0
%   >> islogical(ans)
%   ans = 1
  y = ~ x;
end
