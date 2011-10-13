#!/bin/sh

# clean from last comparison
rm -rf ./compare

# compare, generate HTML
mkdir -p ./compare/html &&\
 cd ./compare &&\
 cp ../openuh.out ../gcc.out ../intel.out ../pgi.out . &&\
 perl ../bin/compare.pl openuh.out gcc.out intel.out pgi.out > ./html/index.html &&\
 cp -fr ../sources ./html

find ./html/sources -name "*.c" | perl -ne'chomp; next unless -e; $oldname = $_; s/\.c$/\.c\.txt/; next if -e; rename $oldname, $_' &&\
find ./html/sources -name "*.f90" | perl -ne'chomp; next unless -e; $oldname = $_; s/\.f90$/\.f90\.txt/; next if -e; rename $oldname, $_' &&\
echo "You may now copy ./compare to a web directory and view the comparison matrix in compare/html/index.html"
