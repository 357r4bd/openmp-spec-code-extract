#!/bin/sh

TARGETPDF=./spec/omp3.1-2011.0130.pdf
START=167
END=294

if [ ! -e "$TARGETPDF" ]; then
  echo :\( xXxXxXxXxXxX
  echo "FATAL: can't find '$TARGETPDF'"
  echo :\( xXxXxXxXxXxX
  exit
fi

pdftotext -f $START -l $END -layout -nopgbrk $TARGETPDF 
