#!/bin/python3
import koji
session = koji.ClientSession("https://koji.fedoraproject.org/kojihub")
print('koji session initialized')

def getinfo(packageName, pattern='*', compl=0):
    l=session.listBuilds(
        session.getPackageID(packageName), 
        completeAfter=compl, 
        pattern=pattern, 
        state=1)
    if (len(l)):
        l = l[-1]
        return l
    else:
        return None

def getinfotime(packageName, filename, pattern='*'):
    try:
        fx = open(filename, 'r', -1, 'utf-8')
        compl = fx.read()
        fx.close()
        compl = float(compl)
    except Exception:
        compl = 0.0
    info = getinfo(packageName, pattern, compl)
    
    fx = open(filename, 'w', -1, 'utf-8')
    fx.write(str(info['completion_ts']))
    fx.close()
    return info

print(getinfotime('grub2', 'completion_ts/grub2.txt', '*.fc38'))
