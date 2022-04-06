#!/usr/bin/env python3
import os,sys
fp = sys.argv[1]
if not os.path.exists(fp):
    from subprocess import getoutput
    fp = getoutput('which %s' % fp)
    if fp == '':
        quit(fp+'not exists')
for i in range(100):
    if os.path.islink(fp):
        print(fp, file=sys.stderr)
        fp_old = fp
        fp = os.readlink(fp)
        if fp[0] != '/':
            fp = os.path.join(os.path.dirname(fp_old), fp)
        fp = os.path.abspath(fp)
    else:
        print(fp)
        break

if '-e' in sys.argv:
    import subprocess
    subprocess.call(f"nvim {fp} ", shell=True)
#print(fp)
#print(os.path.realpath(filepath))
