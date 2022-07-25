%% Copyright (c) 2022 Markus Mützel
%% Copyright (c) 2022 Colin B. Macdonald
%%
%% SPDX-License-Identifier: BSD-3-Clause
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice,
%% this list of conditions and the following disclaimer.
%%
%% 2. Redistributions in binary form must reproduce the above copyright notice,
%% this list of conditions and the following disclaimer in the documentation
%% and/or other materials provided with the distribution.
%%
%% 3. Neither the name of the copyright holder nor the names of its
%% contributors may be used to endorse or promote products derived from this
%% software without specific prior written permission.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.


%!test
%! %% test with file that is not encoded in UTF-8
%! % this is a bare minimal test: the file is probably not read correctly
%! % until Octave >= 7.0.0.
%! path_orig = path ();
%! warn_orig = warning ('off', 'octave:get_input:invalid_utf8');
%! unwind_protect
%!   addpath (canonicalize_file_name ('test_encoding'));
%!   assert (doctest ('test_CP1252.m', '-quiet'));
%! unwind_protect_cleanup
%!   path (path_orig)
%!   warning (warn_orig)
%! end

%!test
%! %% CP1252 to UTF-8 internally, check byte counts
%! % A bug in Octave 7 requires that the folder containing the .oct-config file
%! % is in the load path (not the current directory).
%! if (compare_versions (OCTAVE_VERSION(), '7.0.0', '>='))
%!   path_orig = path ();
%!   unwind_protect
%!     addpath (canonicalize_file_name ('test_encoding'));
%!     assert (doctest ('test_bytecount_CP1252.m', '-quiet'));
%!   unwind_protect_cleanup
%!     path (path_orig)
%!   end
%! end

%!test
%! %% On Octave 8, we can go to the actual directory
%! if (compare_versions (OCTAVE_VERSION(), '8.0.0', '>='))
%!   d = pwd ();
%!   unwind_protect
%!     cd ('test_encoding');
%!     assert (doctest ('test_bytecount_CP1252.m', '-quiet'));
%!   unwind_protect_cleanup
%!     cd (d)
%!   end
%! end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%!test
%! %% Issue #220, workarounds for testing classdef are sensitive to
%! % the order of tests in the main "test" directory.  Here we clear
%! % first.  But we "preload" some methods as a workaround.
%! if (compare_versions (OCTAVE_VERSION(), '4.4.0', '>='))
%! clear classes
%! d = pwd ();
%! unwind_protect
%!   cd ('../test/')
%!   if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!     doc = help ('@test_classdef/amethod');
%!     assert (length (doc) > 10)
%!     % dot notation broken before Octave 6
%!     doc = help ('test_classdef.disp')
%!     assert (length (doc) > 10)
%!   end
%!   doctest ('@test_classdef')
%!   [numpass, numtest, summary] = doctest ('@test_classdef');
%!   assert (numpass == numtest)
%!   summary
%!   if (compare_versions (OCTAVE_VERSION(), '4.4.0', '>='))
%!     assert (summary.num_targets_without_tests <= 2)
%!   end
%!   if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!     assert (summary.num_targets_without_tests <= 1)
%!   end
%!   % glorious future!
%!   % if (compare_versions (OCTAVE_VERSION(), 'X.Y.Z', '>='))
%!   %   assert (summary.num_targets_without_tests == 0)
%!   % end
%! unwind_protect_cleanup
%!   cd (d)
%! end
%! end

%!xtest
%! %% Issue #220, as above but w/o preload workaround, lots broken.
%! % xtest b/c Issue #220 is still open and broken upstream.
%! if (compare_versions (OCTAVE_VERSION(), '4.4.0', '>='))
%! clear classes
%! d = pwd ();
%! unwind_protect
%!   cd ('../test/')
%!   doctest ('@test_classdef')
%!   [numpass, numtest, summary] = doctest ('@test_classdef');
%!   assert (numpass == numtest)
%!   summary
%!   if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%!     % before this missing many methods
%!     assert (summary.num_targets_without_tests <= 1)
%!   end
%! unwind_protect_cleanup
%!   cd (d)
%! end
%! end

%!xtest
%! %% Issue #220 and Issue #261
%! if (compare_versions (OCTAVE_VERSION(), '6.0.0', '>='))
%! clear classes
%! d = pwd ();
%! unwind_protect
%!   cd ('../test/')
%!   doctest ('@test_classdef')
%!   [numpass, numtest, summary] = doctest ('@test_classdef');
%!   assert (numpass == numtest)
%!   assert (summary.num_targets_without_tests == 0)
%! unwind_protect_cleanup
%!   cd (d)
%! end
%! end