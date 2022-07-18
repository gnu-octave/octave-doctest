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
%! %% test for file that is not encoded in UTF-8
%! % A bug in Octave 7 requires that the folder containing the .oct-config file
%! % is in the load path (not the current folder).
%! path_orig = path ();
%! path_protect = onCleanup (@() path (path_orig));
%!
%! if (compare_versions (OCTAVE_VERSION(), '8.0.0', '>='))
%!   addpath (canonicalize_file_name ('test_encoding'));
%!   success = doctest ('test_CP1252.m', '-quiet');
%!   assert (success)
%! end
%! clear path_protect;

%!test
%! %% CP1252 to UTF-8 internally, check byte counts
%! path_orig = path ();
%! path_protect = onCleanup (@() path (path_orig));
%!
%! if (compare_versions (OCTAVE_VERSION(), '8.0.0', '>='))
%!   addpath (canonicalize_file_name ('test_encoding'));
%!   success = doctest ('test_bytecount_CP1252.m', '-quiet');
%!   assert (success)
%! end
%! clear path_protect;
