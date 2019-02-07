#!/usr/bin/env zsh

set -e
setopt globsubst

# Fix newline at EOF issues by making sure we have at least two newlines,
# then stripping out any more than one blank line with cat's squeeze option
for chapter in $@; do
  < $chapter
  echo
  echo
done | cat -s
