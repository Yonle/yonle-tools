#!/usr/bin/env bash

while read dir; do
  if [ "$dir" == "." ] || [ "$dir" == ".." ]; then
    continue;
    return 0;
  fi

  if [ -d "$dir" ] && [ -z "`ls -A "$dir"`" ]; then
    rm -rvf "$dir"
  fi
done<<<`find $@`
