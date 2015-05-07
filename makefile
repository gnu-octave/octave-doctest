.PHONY: test octaveforge_pkg

OCTAVEFORGE_PKG_DIR=octaveforge_pkg

test:
	octave --eval "[~, total_fail, total_extract_err] = doctest('doctest'); exit(total_fail + total_extract_err > 0);"

octaveforge_pkg:
	mkdir -p ${OCTAVEFORGE_PKG_DIR}/inst/private
	cp -ra doctest.m ${OCTAVEFORGE_PKG_DIR}/inst/
	cp -ra doctest_run.m ${OCTAVEFORGE_PKG_DIR}/inst/private/
	cp -ra doctest_compare.m ${OCTAVEFORGE_PKG_DIR}/inst/private/
	cp -ra COPYING ${OCTAVEFORGE_PKG_DIR}/COPYING
	cp -ra CONTRIBUTORS ${OCTAVEFORGE_PKG_DIR}/CONTRIBUTORS
	cp -ra NEWS ${OCTAVEFORGE_PKG_DIR}/NEWS

	tar -zcvf doctest.tar.gz ${OCTAVEFORGE_PKG_DIR}/
