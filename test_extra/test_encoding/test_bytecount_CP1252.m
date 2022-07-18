%% Copyright (c) 2022 Colin B. Macdonald
%%
%% SPDX-License-Identifier: BSD-3-Clause

%% -*- texinfo -*-
%% @deftypefn {} {} test_bytecount_CP1252 ()
%% Test function with some non-ASCII characters from CP1252
%%
%% This file is encoded in CP1252.  Here is the euro symbol:
%% @example
%% s = '€'
%%   @result{} s = €
%% @end example
%%
%% In CP1252, the euro symbol is encoded as a single byte.
%% However, GNU Octave uses @code{utf-8} internally: when we
%% load this docstring, it will have three bytes:
%% @example
%% double(s)
%%   @result{}
%%        226   130   172
%% @end example
%%
%% Even better, we can look at the bits and compare to known
%% values (e.g., see Wikipedia).
%% @example
%% uint8(s);
%% dec2bin(ans)
%%   @result{}
%%        11100010  10000010  10101100
%% @end example
%% @end deftypefn

function test_bytecount_CP1252 ()
  % no-op
endfunction
