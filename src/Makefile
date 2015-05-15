MKOCTFILE = mkoctfile -Wall

all: doctest_evalc.oct


%.oct: %.cc
	$(MKOCTFILE) $<

clean:
	rm -f doctest_evalc.o doctest_evalc.oct
