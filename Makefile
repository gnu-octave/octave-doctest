.PHONY: test matlab_pkg

MATLAB_PKG_DIR=doctest-matlab-0.4.0-dev
SHELL='/bin/bash'
TEST_CODE=success = doctest({'doctest', 'test_blank_match', 'test_compare_hyperlinks', 'test_compare_backspace', 'test_class'}); exit(~success);

test:
	octave --path inst --path test --eval "${TEST_CODE}"

test-interactive:
	script --quiet --command "octave --path inst --path test --eval \"${TEST_CODE}\"" /dev/null

test-matlab:
	matlab -nojvm -nodisplay -nosplash -r "addpath('inst'); addpath('test'); ${TEST_CODE}"


matlab_pkg:
	mkdir -p tmp/${MATLAB_PKG_DIR}/private
	cp -ra inst/doctest.m tmp/${MATLAB_PKG_DIR}/
	cp -ra inst/private/doctest_collect.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra inst/private/doctest_colors.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra inst/private/doctest_compare.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra inst/private/doctest_run.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra COPYING tmp/${MATLAB_PKG_DIR}/
	cp -ra CONTRIBUTORS tmp/${MATLAB_PKG_DIR}/
	cp -ra NEWS tmp/${MATLAB_PKG_DIR}/
	cp -ra README.matlab.md tmp/${MATLAB_PKG_DIR}/
	pushd tmp; zip -r ${MATLAB_PKG_DIR}.zip ${MATLAB_PKG_DIR}; popd
	mv tmp/${MATLAB_PKG_DIR}.zip .

