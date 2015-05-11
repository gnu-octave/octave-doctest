function [color_ok, color_err, color_warn, reset] = doctest_colors()
% Return terminal color codes to use for current invocation of doctest.
%
% FIXME: Shouldn't use colors if stdout is not a TTY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
  OCTAVE_VERSION;
  running_octave = 1;
catch
  running_octave = 0;
end

if (running_octave)
  have_colorterm = index(getenv('TERM'), 'color') > 0;
  if have_colorterm
    % hide terminal escapes from Matlab
    color_ok = eval('"\033[1;32m"');    % green
    color_err = eval('"\033[1;31m"');   % red
    color_warn = eval('"\033[1;35m"');  % purple
    reset = eval('"\033[m"');
  end
else
  color_ok = '';
  color_err = '';
  color_warn = '';
  reset = '';
end

end
