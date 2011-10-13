#!/bin/sh

DATE=`date "+%s"`

# -- Phase 1 -- Compiling all single source *.c & *.f90 -- #

# Brett playing around with a new, basic testing infrastructure #

BASEDIR=../../sources

#CC=uhcc
#F90=uhf90
CFLAGS="$CFLAGS $@"   # $@ assumes all flags apply to both C and Fortran
F90FLAGS="$CFLAGS $@" # $@ assumes all flags apply to both C and Fortran

EXE=-o 

mkdir -p ./tmp/bin ./tmp/$DATE > /dev/null 2>&1
cd ./tmp/$DATE

PASSED_COUNT=0
FAILED_COUNT=0
TOTAL_ATTEMPTS=0

PWD=`pwd`

for file in `find $BASEDIR -name "*.c"`; do
  TOTAL_ATTEMPTS=$(($TOTAL_ATTEMPTS+1))
  FILE_TO_STRING=`echo "$file" | perl -e '$x=<>; $x =~ s/\.+\/+//g;@y=split("/",$x);printf("%s",pop @y)'` 
  _EXE="$EXE ../bin/$FILE_TO_STRING.x"
  COMPILE_OUT=`$CC $CFLAGS $file $_EXE > /dev/null 2> ./$FILE_TO_STRING.txt && echo 1 || echo -1`
  COMPILE_STATUS=undef
  if [ "$COMPILE_OUT" == 1 ]; then
    STATUS=":) OKAY"
    PASSED_COUNT=$(($PASSED_COUNT+1))
    echo $FILE_TO_STRING >> ./all-passed.out
  else
    STATUS="XX FAIL"
    FAILED_COUNT=$(($FAILED_COUNT+1))
    echo "-------" >> ./all-failed.out
    echo "------- $FILE_TO_STRING" >> ./all-failed.out
    echo "-------" >> ./all-failed.out
    cat $PWD/$FILE_TO_STRING.txt >> ./all-failed.out
  fi
  echo "[$FILE_TO_STRING] $STATUS $PWD/$FILE_TO_STRING.txt $file"
done

for file in `find $BASEDIR -name "*.f90"`; do
  TOTAL_ATTEMPTS=$(($TOTAL_ATTEMPTS+1))
  FILE_TO_STRING=`echo "$file" | perl -e '$x=<>; $x =~ s/\.+\/+//g;@y=split("/",$x);printf("%s",pop @y)'` 
  _EXE="$EXE ../bin/$FILE_TO_STRING.x"
  COMPILE_OUT=`$F90 $F90FLAGS $file $_EXE > /dev/null 2> ./$FILE_TO_STRING.txt && echo 1 || echo -1`
  COMPILE_STATUS=undef
  if [ "$COMPILE_OUT" == 1 ]; then
    STATUS=":) OKAY"
    PASSED_COUNT=$(($PASSED_COUNT+1))
    echo $FILE_TO_STRING >> ./all-passed.out
  else
    STATUS="XX FAIL"
    FAILED_COUNT=$(($FAILED_COUNT+1))
    echo "-------" >> ./all-failed.out
    echo "------- $FILE_TO_STRING" >> ./all-failed.out
    echo "-------" >> ./all-failed.out
    cat $PWD/$FILE_TO_STRING.txt >> ./all-failed.out
  fi
  echo "[$FILE_TO_STRING] $STATUS $PWD/$FILE_TO_STRING.txt $file"
done

echo "Summary of Compliation Test"
printf "%06d files passed %06d failed (out of %06d total files)\n" $PASSED_COUNT $FAILED_COUNT $TOTAL_ATTEMPTS

PWD=`pwd`
echo "Full failure report"
echo "$PWD/all-failed.out"
