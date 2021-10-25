#!/bin/bash

RC=0

grep -E -v '^(halt|sync|shutdown)' /etc/passwd | awk -F: '($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
    RC=1
  else
    for file in $dir/.[A-Za-z0-9]*; do
      if [ ! -h "$file" -a -f "$file" ]; then
        fileperm=$(ls -ld $file | cut -f1 -d" ")
        if [ $(echo $fileperm | cut -c6) != "-" ]; then
          echo "Group Write permission set on file $file"
          RC=1
        fi
        if [ $(echo $fileperm | cut -c9) != "-" ]; then
          echo "Other Write permission set on file $file"
          RC=1
        fi
      fi
    done
  fi
done
exit $RC
