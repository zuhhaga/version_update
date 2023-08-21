#!/bin/bash -x
git rm -r --cached .
touch requirements.txt
git add requirements.txt
git add run.sh
git add commit.sh
git add blank.yml
git add koji_update.py
git add waydroid_update.pl
git add `readlink blank.yml`
git add docs/_redirects
#git add docs/index.html
git commit -m update
git push
