#!/usr/bin/env python3
import os,glob
from sys import argv
from pathlib import Path
import yaml



def yesno(tips="overvide conf?(y/n)"):
    a = input(tips)
    if a not in ("y",""):
        quit("quit")
def convertProj(proj, env):
    chartfile=os.environ.get('HOME')+f'/www/devops/hdmap-helm-charts/{proj}/values_ack_{env}.yaml'
    obj = yaml.load(open(chartfile))
    configMap.env.data
    yaml.dump(obj)


if len(argv)<2:
    quit("helm-conf-import.py proj|list prod|dev|staging")
elif len(argv)==2:
    quit("helm-conf-import.py proj|list prod|dev|staging")
elif len(argv)==3:
    _, proj,env = argv
    convertProj(proj,env)
