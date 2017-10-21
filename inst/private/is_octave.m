function r = is_octave()
%IS_OCTAVE  True if we are running Octave, false for Matlab.

%%
% Copyright (c) 2015 Colin B. Macdonald
% This is Free Software, BSD-3-Clause, see doctest.m for details.


% Timings for different implementations, 10000 calls
%
%     test        Matlab    Octave
%     ----------------------------
%     try-catch   1.2s      0.18s
%     if-exist    0.14s     0.22s
%     dummy       0.13s     0.13s
%
% Conclusions: "if-exist" only twice as slow as "dummy" (always return
% true), so no need to bother with a persistent variable.

  r = exist('OCTAVE_VERSION', 'builtin') ~= 0;

  %try
  %  OCTAVE_VERSION;
  %  r = true;
  %catch
  %  r = false;
  %end

end
