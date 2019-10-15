function y = mynewmethod(x)
%MYNEWMETHOD: monkey patch something onto class logical
%   >> a = mynewmethod(true);
%   >> double(a)
%   ans = 0
%   >> double(islogical(a))
%   ans = 1
  y = ~ x;
end
