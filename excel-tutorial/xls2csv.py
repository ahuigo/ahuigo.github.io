#!/usr/bin/env python3

import csv
from xlrd import open_workbook
import sys

_,filename, *args = sys.argv
print(filename)
sheet = open_workbook(filename).sheets()[0]
with open('test.csv', 'w') as f:
    c = csv.writer(f); #writer(f, dialect='excel')
    for r in range(sheet.nrows):
        c.writerow([v if str(v).isdigit() else v  for v in sheet.row_values(r)])
