function s = test_angle_brackets()
% https://savannah.gnu.org/bugs/?45084 (Fixed in Octave 4.0)
%
% Fails on 3.8
% >> oct38 = DOCTEST_OCTAVE && compare_versions(OCTAVE_VERSION, '4.0.0', '<');
%
%
% >> s = test_angle_brackets()    % doctest: +XFAIL_IF(oct38)
% s = I <3 U
% >> s = '<p>I heart you</p>'     % doctest: +XFAIL_IF(oct38)
% s = <p>I heart you</p>

s = 'I <3 U';
