#!/bin/sh

make clean
make extract test
mkdir html && perl ./compare.pl openuh.out gcc.out intel.out pgi.out > ./html/index.html && rm -rf ~/www/html/ && mv html ~/www &&cp -r sources ~/www/html/
