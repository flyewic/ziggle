#!/usr/bin/bash
for file in $(find . -name "test_*.zig"); do
    echo "Running tests in $file"
    zig test "$file" || exit 1
done
