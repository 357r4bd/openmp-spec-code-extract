all: extract

extract:
	sh ./bin/appendixA-to-text.sh 2> /dev/null
	sh ./bin/expected-examples.sh > MANIFEST 
	perl ./bin/build-dump.pl < spec/omp3.1-2011.0130.txt > dump.out
	mkdir -p ./sources/c/complete ./sources/c/partial ./sources/f90/complete ./sources/f90/partial 
	perl ./bin/split-dump.pl < dump.out

test: openuh intel pgi gcc html 

openuh:
	CC=uhcc CFLAGS="-mp" F90=uhf90 F90FLAGS="-mp" sh bin/test-singles-compile.sh | tee openuh.out | tail -n 3

intel:
	CC=icc CFLAGS="-openmp" F90=ifort F90FLAGS="-openmp" sh bin/test-singles-compile.sh | tee intel.out | tail -n 3

pgi:
	CC=pgcc CFLAGS="" F90=pgf90 F90FLAGS="" sh bin/test-singles-compile.sh | tee pgi.out | tail -n 3

gcc:
	CC=gcc CFLAGS="-fopenmp" F90=gfortran F90FLAGS="-fopenmp" sh bin/test-singles-compile.sh | tee gcc.out | tail -n 3

html:
	sh bin/compare.sh

clean:
	rm -rf ./sources *.txt *.out MANIFEST ./tmp ./compare
