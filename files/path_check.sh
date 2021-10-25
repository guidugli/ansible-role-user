#!/bin/bash

RC=0

for x in $(echo $PATH | tr ":" " ") ; do
  if [ -d "$x" ] ; then
    ls -ldH "$x" | awk '
$9 == "." {print "PATH contains current working directory (.)"; err=1 }
$3 != "root" {print $9, "is not owned by root", err=1 }
substr($1,6,1) != "-" {print $9, "is group writable"; err=1 }
substr($1,9,1) != "-" {print $9, "is world writable"; err=1 }
END {exit err}'
    if [ $? -gt 0 ]; then
      RC=1
    fi
  elif [ -f "$x" ] ; then
    echo "$x is a file"
    RC=1
  fi
done

exit $RC
