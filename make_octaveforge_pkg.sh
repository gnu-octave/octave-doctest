#!/bin/sh

d=octaveforge_pkg

mkdir -p ${d}/inst/private
cp -ra doctest.m ${d}/inst/
cp -ra doctest_run.m ${d}/inst/private/
cp -ra doctest_compare.m ${d}/inst/private/
cp -ra LICENSE.txt ${d}/COPYING

tar -zcvf doctest.tar.gz ${d}/
