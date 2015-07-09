Doctest [![Build Status](https://travis-ci.org/catch22/octave-doctest.svg?branch=master)](https://travis-ci.org/catch22/octave-doctest)
=======

The [Octave-Forge Doctest](http://octave.sourceforge.net/doctest/) package finds specially-formatted blocks of example code within documentation files.
It then executes the code and confirms the output is correct.
This can be useful as part of a testing framework or simply to ensure that documentation stays up-to-date during software development.

To get started, here is a simple example:

~~~matlab
function greeting = greet(user)
% Returns a greeting.
%
% >> greet World
%
% Hello, World!

greeting = ['Hello, ' user '!'];

end
~~~

We can test it by invoking `doctest greet` at the Octave prompt, which will give the following output:

~~~
greet .................................................. PASS    1/1

Summary:

   PASS    1/1

1/1 targets passed, 0 without tests.
~~~

Doctest also supports Texinfo markup, which is [quite popular](https://www.gnu.org/software/octave/doc/interpreter/Documentation-Tips.html) in the Octave world, and it provides various toggles and switches for customizing its behavior.
The [documentation](http://octave.sourceforge.net/doctest/function/doctest.html) contains information on all this.
Quite appropriately, Doctest can test its own documentation.
We also maintain a [list of software](https://github.com/catch22/octave-doctest/wiki/WhoIsUsingDoctest) that is using Doctest.
