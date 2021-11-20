#!/usr/bin/env bash

(
  echo https://spinkney.github.io/cheatsheets/
  (
    git ls-files \
      | grep -E '\.md$' \
      | grep -v -E 'CONTRIBUTING|README|Readme' \
      | grep -v -E '^_' \
      | sort \
      | uniq \
      | sed 's/\.md$//g'
  ) \
    | sed 's#^#https://spinkney.github.io/cheatsheets/#g'
) \
  | xargs curl >/dev/null
