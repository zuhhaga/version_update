#!/bin/dfbash -x
pip install koji
rm docs/_redirects
touch docs/_redirects

python3 koji_update.py
perl json_update.pl

git config --global user.email "zuhhaga@gmail.com"
git config --global user.name "zuhhaga"
git add --all
git commit -m update
git push

git clone https://github.com/zuhhaga/flutter_update --filter=blob:none --no-checkout flup
cd flup
gh workflow run CI
cd ..

