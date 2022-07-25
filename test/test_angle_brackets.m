function s = test_angle_brackets()
% https://savannah.gnu.org/bugs/?45084 (Fixed in Octave 4.0)
%
% Copyright (c) 2015-2016, 2022 Colin B. Macdonald
% SPDX-License-Identifier: BSD-3-Clause
%
% Fails on Octave 3.8
% >> oct38 = DOCTEST_OCTAVE && compare_versions(OCTAVE_VERSION, '4.0.0', '<');
%
%
% >> disp (test_angle_brackets ())    % doctest: +XFAIL_IF(oct38)
% I <3 U
%
%
% Slightly off-topic but newer Matlab have quotes around strings.
%
% Here's the Octave version, without quotes:
% >> s = test_angle_brackets()    % doctest: +SKIP_IF(oct38 || DOCTEST_MATLAB)
% s = I <3 U
% >> s = '<p>I heart you</p>'     % doctest: +SKIP_IF(oct38 || DOCTEST_MATLAB)
% s = <p>I heart you</p>
%
%
% On Matlab, we need string indicators in the display:
% >> s = test_angle_brackets()    % doctest: +SKIP_IF(DOCTEST_OCTAVE)
% s = 'I <3 U'
% >> s = '<p>I heart you</p>'     % doctest: +SKIP_IF(DOCTEST_OCTAVE)
% s = '<p>I heart you</p>'

s = 'I <3 U';
