function s = test_angle_brackets()
% https://savannah.gnu.org/bugs/?45084 (Fixed in Octave 4.0)
%
% >> s = test_angle_brackets()
% s = I <3 U
% >> s = '<p>I heart you</p>'
% s = <p>I heart you</p>

s = 'I <3 U';
