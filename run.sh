#!/bin/bash -x
#pip install koji
rm docs/_redirects
touch docs/_redirects

#python3 koji_update.py
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

echo $OSC_USERNAME
echo $OSC_PASSWORD

cat <<EOF > oscrc
[general]
apiurl=https://api.opensuse.org

[https://api.opensuse.org]
user=$OSC_USERNAME
pass=$OSC_PASSWORD
credentials_mgr_class=osc.credentials.PlaintextConfigFileCredentialsManager

EOF

for i in dart waydroid-image waydroid-image-gapps
do
  osc --config oscrc co home:huakim:matrix "$i"
  cd "home:huakim:matrix/$i"
  cp -v "../../docs/$i.spec" "$i.spec"
  osc --config oscrc addremove
  osc --config oscrc ci -m update
done
