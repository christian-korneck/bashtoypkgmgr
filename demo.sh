#!/bin/bash
sorted_deps=$(./parse-deps.sh app | tsort | tac | sed '/^none$/d')
while IFS= read -r line; do cmd="./$line.pkg"; source $cmd; done <<< $sorted_deps
