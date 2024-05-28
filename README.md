Doctest
=======

The [Octave Doctest](https://gnu-octave.github.io/packages/doctest/) package
finds specially-formatted blocks of example code within documentation files.
It then executes the code and confirms the output is correct.
This can be useful as part of a testing framework or simply to ensure that
documentation stays up-to-date during software development.

To get started, here is a simple example:

~~~matlab
function greet(user)
  % Returns a greeting.
  %
  % >> greet World
  %
  % Hello, World!

  disp(['Hello, ' user '!']);

end
~~~

We can test it by invoking `doctest greet` at the Octave prompt, which will give the following output:

~~~
greet .................................................. PASS    1/1

Summary:

   PASS    1/1

1/1 targets passed, 0 without tests.
~~~

Doctest also supports Texinfo markup, which is [popular](https://www.gnu.org/software/octave/doc/interpreter/Documentation-Tips.html) in the Octave world, and it provides various toggles and switches for customizing its behavior.
The [Doctest documentation](https://octave.sourceforge.io/doctest/function/doctest.html) contains information on all this.
Quite appropriately, Doctest can test its own documentation.
We also maintain a [list of software](https://github.com/gnu-octave/octave-doctest/wiki/WhoIsUsingDoctest) that is using Doctest.
