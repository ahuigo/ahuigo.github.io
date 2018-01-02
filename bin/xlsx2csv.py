#!/usr/local/bin/python3
import openpyxl
import csv
from sys import argv
from datetime import datetime, timedelta

wb = openpyxl.load_workbook(argv[1])
sh = wb.active
max = 0;
for row in sh.rows[0:2]:
    for idx, v in enumerate(row):
        if v.value != None:
            max = idx
to = 'test.csv' if len(argv) < 3 else argv[2]

'''
Format time
'''
def getCellValue(cell):
    if cell.style_id in [12]:
        v = cell.value - 2;
        value = (datetime(1900,1,1)+timedelta(days=v)).strftime('%Y%m%d')
    else:
        value = cell.value.replace("\n", ' ') if type(cell.value) is str else cell.value
        #value = cell.value.replace("\\n", '\n') if type(cell.value) is str else cell.value
    return value

with open(to, 'w') as f:
    c = csv.writer(f)
    for r in sh.rows:
        c.writerow([getCellValue(cell) for cell in r[0:max]])

'''
import openpyxl
import csv
from sys import argv

wb = openpyxl.load_workbook('2.xlsx', guess_types = True)
sh = wb.active
r = sh.rows[3]
a = r[0]
'''
