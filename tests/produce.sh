#!/usr/bin/env bash

values=(
  $(echo test1|base64)
  $(echo test2|base64)
  $(echo test3|base64)
)

for v in ${values[@]}; do
  curl -X POST localhost:8080 -d "{\"record\":{\"value\": \"$v\"}}"
done
