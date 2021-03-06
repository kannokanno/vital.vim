#!/bin/bash

if [ $# -gt 1 ]; then
  echo "Usage: spec.sh {spec_file}" 1>&2
  exit 1
fi

VIM=vim
SPEC_FILE=$1
OUTFILE=/tmp/vital_spec.result
echo '' > $OUTFILE

if [ -n "$SPEC_FILE" ]; then
  # not required '&'(background process)
  $VIM -u NONE -i NONE -N --cmd 'filetype indent on' -S $SPEC_FILE -c "FinUpdate $OUTFILE" > /dev/null 2>&1
else
  # all test
  for FILE in `find spec -type f -name "*.vim"`
  do
    if [ $FILE != "spec/base.vim" ]; then
      echo Testing... $FILE
      # required '&'(background process)
      OFILE="$OUTFILE.`basename ${FILE}`"
      cat /dev/null > ${OFILE}
      $VIM -u NONE -i NONE -N --cmd 'filetype indent on' -S $FILE -c "FinUpdate $OFILE" >/dev/null 2>&1 &
    fi
  done
  wait
  echo Done.

  find spec -type f -name "*.vim" | while read FILE
  do
    OFILE="$OUTFILE.`basename ${FILE}`"
    if [ -f ${OFILE} ]
    then
      cat ${OFILE} >> ${OUTFILE}
      rm -f ${OFILE}
    fi
  done
fi

cat $OUTFILE

ALL_TEST_NUM=`grep "\[.\]" $OUTFILE | wc -l`
FAILED_TEST_NUM=`grep "\[F\]" $OUTFILE | wc -l`

if [ $FAILED_TEST_NUM -eq 0 ]; then
  echo $ALL_TEST_NUM tests success
  echo
  exit 0
else
  FAILED_ASSERT_NUM=`grep " - " $OUTFILE | wc -l`
  echo FAILURE!
  echo $ALL_TEST_NUM tests. Failure: $FAILED_TEST_NUM tests, $FAILED_ASSERT_NUM assertions
  echo
  exit 1
fi
