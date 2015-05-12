Running Doctest on Matlab
=========================

The Doctest package finds specially-formatted blocks of example code
within documentation files.  It then executes the code and confirms
the output is correct.  This can be useful as part of a testing
framework or simply to ensure that documentation stays up-to-date
during software development.

The package is designed for Octave but aims to be compatible with
Matlab as well.

See `help doctest` for documention and other information.


Installation
------------

To install on Matlab, download the `doctest-matlab-x.y.z.zip` file and
unzip it somewhere.  Add it to your Matlab path (e.g., with the Matlab
`addpath` command).  Type `doctest doctest` to have Doctest test
itself.
