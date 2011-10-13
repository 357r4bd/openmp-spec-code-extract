#!/bin/sh

grep "Example A" spec/omp3.1-2011.0130.txt | perl -pi -e 's/^ *[1-9]+[0-9]* *//' | awk '{print $2}'
