.PHONY: test

test:
	octave --eval "[~, total_fail, total_extract_err] = doctest('doctest'); exit(total_fail + total_extract_err > 0);"
