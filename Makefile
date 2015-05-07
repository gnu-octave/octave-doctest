.PHONY: test

OCTAVEFORGE_PKG_DIR=octaveforge_pkg

test:
	octave --eval "[~, total_fail, total_extract_err] = doctest('doctest'); exit(total_fail + total_extract_err > 0);"

