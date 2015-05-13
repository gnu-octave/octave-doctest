.PHONY: test matlab_pkg

MATLAB_PKG_DIR=doctest-matlab-0.4.0-dev
SHELL = '/bin/bash'

test:
	octave --path inst --path inst/private --eval "success = doctest({'doctest', 'doctest_run', 'doctest_compare', 'doctest_collect', 'doctest_colors'}); exit(~success);"

test-matlab:
	matlab -nojvm -nodisplay -nosplash -r "addpath('inst'); success = doctest({'doctest', 'private/doctest_run', 'private/doctest_compare', 'private/doctest_collect', 'private/doctest_colors'}); exit(~success);"

matlab_pkg:
	mkdir -p tmp/${MATLAB_PKG_DIR}/private
	cp -ra inst/doctest.m tmp/${MATLAB_PKG_DIR}/
	cp -ra inst/private/doctest_run.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra inst/private/doctest_compare.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra COPYING tmp/${MATLAB_PKG_DIR}/
	cp -ra CONTRIBUTORS tmp/${MATLAB_PKG_DIR}/
	cp -ra NEWS tmp/${MATLAB_PKG_DIR}/
	cp -ra README.matlab.md tmp/${MATLAB_PKG_DIR}/
	pushd tmp; zip -r ${MATLAB_PKG_DIR}.zip ${MATLAB_PKG_DIR}; popd
	mv tmp/${MATLAB_PKG_DIR}.zip .

