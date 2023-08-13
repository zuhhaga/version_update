#!/bin/bash -x
git rm -r --cached .
git add run.sh
git add commit.sh
git add blank.yml
git add `readlink blank.yml`
git add docs/README.md
git commit -m update
git push
