#!/bin/bash

RC=0

grep -E -v '^(halt|sync|shutdown)' /etc/passwd | awk -F: '($7 != "/sbin/nologin" && $7 != "/usr/sbin/nologin" && $7 != "/bin/false") { print $1 " " $6 }' | while read -r user dir; do
  if [ ! -d "$dir" ]; then
    echo "The home directory ($dir) of user $user does not exist."
    RC=1
  fi
done
exit $RC
