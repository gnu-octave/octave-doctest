SHELL   = /bin/bash

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
CC_SOURCES = $(wildcard src/*.cc)
BUILD_DIR = tmp
MATLAB_PKG_DIR=$(PACKAGE)-matlab-$(VERSION)
OCT_COMPILED = $(BUILD_DIR)/.oct

OCTAVE ?= octave
MKOCTFILE ?= mkoctfile -Wall
MATLAB ?= matlab

TEST_CODE=success = doctest({'doctest', 'test_blank_match', 'test_compare_backspace', 'test_compare_hyperlinks', 'test_skip', 'test_skip_only_one', 'test_warning', 'test_class', 'test_comments.texinfo', 'test_skip_comments.texinfo'}); exit(~success);


.PHONY: help test test-interactive matlab_test matlab_pkg

help:
	@echo Available rules:
	@echo "  clean              clean all temporary files"
	@echo "  test               run tests with Octave"
	@echo "  test-interactive   run tests with Octave in interactive mode"
	@echo "  matlab_test        run tests with Matlab"
	@echo "  matlab_pkg         create Matlab package (${MATLAB_PKG_DIR}.zip)"


$(BUILD_DIR) tmp/${MATLAB_PKG_DIR}/private:
	mkdir -p "$@"

clean:
	rm -rf "$(BUILD_DIR)"
	rm -f src/*.oct src/*.o

## If the src/Makefile changes, recompile all oct-files
$(CC_SOURCES): src/Makefile
	@touch --no-create "$@"

## Compilation of oct-files happens in a separate Makefile,
## which is bundled in the release and will be used during
## package installation by Octave.
$(OCT_COMPILED): $(CC_SOURCES) | $(BUILD_DIR)
	MKOCTFILE="$(MKOCTFILE)" $(MAKE) -C src
	@touch "$@"


test: $(OCT_COMPILED)
	$(OCTAVE) --path inst --path src --path test --eval "${TEST_CODE}"

test-interactive: $(OCT_COMPILED)
	script --quiet --command "$(OCTAVE) --path inst --path src --path test --eval \"${TEST_CODE}\"" /dev/null


matlab_test:
	$(MATLAB) -nojvm -nodisplay -nosplash -r "addpath('inst'); addpath('test'); ${TEST_CODE}"

matlab_pkg: | tmp/${MATLAB_PKG_DIR}/private
	cp -ra inst/doctest.m tmp/${MATLAB_PKG_DIR}/
	cp -ra inst/private/*.m tmp/${MATLAB_PKG_DIR}/private/
	cp -ra COPYING tmp/${MATLAB_PKG_DIR}/
	cp -ra CONTRIBUTORS tmp/${MATLAB_PKG_DIR}/
	cp -ra NEWS tmp/${MATLAB_PKG_DIR}/
	cp -ra README.matlab.md tmp/${MATLAB_PKG_DIR}/
	pushd tmp; zip -r ${MATLAB_PKG_DIR}.zip ${MATLAB_PKG_DIR}; popd
	mv tmp/${MATLAB_PKG_DIR}.zip .

