.PHONY: test matlab_pkg

MATLAB_PKG_DIR=doctest-0.3.0

SHELL = '/bin/bash'

test:
	octave --path inst --path inst/private --eval "[~, total_fail, total_extract_err] = doctest('doctest', 'doctest_run', 'doctest_compare'); exit(total_fail + total_extract_err > 0);"

matlab_pkg:
	mkdir -p tmp/${MATLAB_PKG_DIR}/private
	cp -ra inst/doctest.m tmp/${MATLAB_PKG_DIR}/
	cp -ra inst/private/doctest_run.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra inst/private/doctest_compare.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra COPYING tmp/${MATLAB_PKG_DIR}/
	cp -ra CONTRIBUTORS tmp/${MATLAB_PKG_DIR}/
	cp -ra NEWS tmp/${MATLAB_PKG_DIR}/
	pushd tmp; zip -r ${MATLAB_PKG_DIR}.zip ${MATLAB_PKG_DIR}; popd
	mv tmp/${MATLAB_PKG_DIR}.zip .

