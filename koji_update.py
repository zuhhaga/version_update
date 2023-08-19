#!/bin/python3
import koji
from os.path import join
session = koji.ClientSession("https://koji.fedoraproject.org/kojihub")
output=open('docs/_redirects', 'a', -1, 'utf-8')

def setsrc(name, tag):
    info = session.listTagged(tag, latest=True, package=name)[0]
    name = info['name']
    version = info['version']
    release = info['release']
    domain='https://kojipkgs.fedoraproject.org/packages/'
    path=join(domain, name, version, release, 'src', 
        '.'.join((
        '-'.join((name, version, release)), 'src', 'rpm'))
    )
    redirect = join('/fedora', tag, 'src', '.'.join((name, 'src', 'rpm')))
    print(redirect, path, file=output)

setsrc('grub2', 'f38')
setsrc('dolphin', 'f38')

output.close()
