.PHONY: test

test:
	octave --eval "[_, total_fail, total_extract_err] = doctest('doctest'); exit(total_fail + total_extract_err > 0);"
