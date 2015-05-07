How to do a release
===================

We use x.y.z.  Bump y for minor changes or z for "micro" changes (bug
fixes etc).

OctaveForge process: http://octave.sourceforge.net/developers.html
TODO: read this during next release, and update below.

TODO: There was a thread on octave-maintainers maillist about automating
most of this with a Makefile.  Find and investigate.


Checklist
---------

  * Update doctest.m:

      - update version number (remove "-dev", check if bump needed).

  * Update DESCRIPTION file (version number and date).

  * Update NEWS file (date, version number, reformat).

  * Double-check version number in Makefile.

  * Test regenerating the html documentation.
      - pkg install -forge generate_html
      - pkg load generate_html
      - options = get_html_options ("octave-forge");
      - generate_package_html ("doctest", "html", options)

  * If packages seem ok, then tag the repo with:

    `git tag -a v2.0.0 -m "Version 2.0.0"`

  * `git push --tags origin master`.  If messed up and want to change
    anything after this, need to bump version number (tag is public).

  * Push and push tags to sourceforge.

  * Then redo the packages.

      - compute the md5sums, upload the packages to github release
        page, and copy-paste the md5sums.

      - regenerating the html documentation.

      - create ticket for binaries and doc tarball on sourceforge.



AFTER release
=============

  * Bump version to the next anticipated version and append "-dev" in
    in doctest.m.  See
    [PEP 440](https://www.python.org/dev/peps/pep-0440).

  * Update version numbers in Makefile.

  * Leave old version in DESCRIPTION ("-dev" not supported here).  We
    will bump it at the next release.  FIXME: this is unfortunate.
