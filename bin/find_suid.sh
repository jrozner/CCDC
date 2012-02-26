#!/bin/bash

# Searches the filesystem for all SUID and SGID binaries on the system. This
# must run as root in order to search the entire filesystem.

if [ $(id -u) -ne 0 ]; then
  echo "Re-run as root to search full file system."
  exit 1
fi

find / -perm +6000 -type f -exec ls -ld {} \;
