#!/usr/bin/env bash

##
## Finds all packages used in .R files in this project
## and dumps them into a file called REQUIREMENTS.txt
##

source_files=($(git ls-files '*.R'))
grep -hE '\b(require|library)\([\.a-zA-Z0-9]*\)' "${source_files[@]}" | \
    sed '/^[[:space:]]*#/d' | \
    sed -E 's/.*\(([\.a-zA-Z0-9]*)\).*/\1/' | \
    sort -uf \
    > REQUIREMENTS.txt
