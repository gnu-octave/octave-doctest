/*
  Copyright 2015 Oliver Heimlich
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

#include <octave/oct.h>
#include <octave/parse.h>

DEFUN_DLD (doctest_evalc, args, nargout,
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefn  {Loadable Function} {@var{S} =} doctest_evalc (@var{TRY})\n"
  "@deftypefnx {Loadable Function} {@var{S} =} doctest_evalc (@var{TRY}, @var{CATCH})\n"
  "\n"
  "Parse the string @var{TRY} and evaluate it as if it were an Octave "
  "program.  If that fails, evaluate the optional string @var{CATCH}.  The "
  "string @var{TRY} is evaluated in the current context, so any results "
  "remain available after @command{doctest_evalc} returns."
  "\n\n"
  "This function is like @command{eval}, except any output that would "
  "normally be written in the console is captured and returned as string "
  "@var{S}."
  "\n\n"
  "@example\n"
  "@group\n"
  "s = doctest_evalc (\"t = 42\"), t\n"
  "  @result{}\n"
  "    s = t =  42\n\n"
  "    t =  42\n"
  "@end group\n"
  "@end example\n"
  "@seealso{eval, evalin}\n"
  "@end deftypefn"
  )
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin > 0)
    {
      // Redirect stdout to capturing buffer
      std::ostream & out_stream = octave_stdout;
      std::ostream & err_stream = std::cerr;
      std::ostringstream buffer;
      std::streambuf* old_out_buf = out_stream.rdbuf (buffer.rdbuf ());
      std::streambuf* old_err_buf = err_stream.rdbuf (buffer.rdbuf ());

      int parse_status = 0;

      octave_value_list tmp = eval_string (args(0).string_value (), false,
                                           parse_status, 0);

      if (nargin > 1 && (parse_status != 0 || error_state))
        {
          error_state = 0;

          tmp = eval_string (args(1).string_value (), false,
                             parse_status, 0);
        }

      // Stop capturing buffer and restore stdout
      out_stream.flush ();
      err_stream.flush ();
      retval (0) = buffer.str ();
      out_stream.rdbuf (old_out_buf);
      err_stream.rdbuf (old_err_buf);

      // Reset error state, otherwise this function would
      // not be able to return anything in case of errors.
      // XXX: The following line causes errors not to be propagated to the parent (#61).
      // error_state = 0;
    }
  else
    print_usage ();

  return retval;
}
