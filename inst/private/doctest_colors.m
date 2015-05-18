function [color_ok, color_err, color_warn, reset] = doctest_colors(fid)
% Return terminal color codes to use for current invocation of doctest.
%
% FIXME: Shouldn't use colors if stdout is not a TTY.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% by default, no colors
color_ok = '';
color_err = '';
color_warn = '';
reset = '';

% only use colors in Octave, when printing to stdout, and when terminal supports colors
if (is_octave())
  have_colorterm = index(getenv('TERM'), 'color') > 0;
  if fid == stdout && have_colorterm
    % hide terminal escapes from Matlab
    color_ok = eval('"\033[1;32m"');    % green
    color_err = eval('"\033[1;31m"');   % red
    color_warn = eval('"\033[1;35m"');  % purple
    reset = eval('"\033[m"');
  end
end

end
