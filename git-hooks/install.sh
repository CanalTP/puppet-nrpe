#!/bin/bash
# Use this script to install hooks provided for this module

for file in pre-commit post-commit
do
  cp ./git-hooks/$file .git/hooks/
  chmod +x .git/hooks/$file
  echo "$file git hook installed/updated"
done
