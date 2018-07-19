#!/usr/local/bin/python3
import openpyxl
import csv
from sys import argv
from datetime import datetime, timedelta
from dateutil.parser import parse as strptime


'''
Format time
'''
def getCellValue(cell):
    print(cell.value, type(cell.value),cell.row,cell.column,cell.data_type,cell.style, cell.style_id)
    if cell.data_type in ['xxx']: # 's'
        if type(cell.value) == str:
            d = strptime(cell.value).strftime('%Y%m%d')
        elif type(cell.value) == int:
            d = (datetime(1900,1,1)+timedelta(days=cell.value))
        else:
            d = cell.value
        value = d.strftime('%Y%m%d')
    else:
        value = cell.value.replace("\n", ' ') if type(cell.value) is str else cell.value
        #value = cell.value.replace("\\n", '\n') if type(cell.value) is str else cell.value
    return value

def isInValid(cell):
    return cell.value==None and cell.style_id in [62,64]

if len(argv)<3:
    print('Usage:\n$ xlsx2csv.py from.xlsx to.csv')
    quit()

wb = openpyxl.load_workbook(argv[1])
sh = wb.active
maxl = len(next(sh.rows))
to = 'test.csv' if len(argv) < 3 else argv[2]
print(f'Convert xlsx from {argv[1]} to {to}' )



with open(to, 'w') as f:
    c = csv.writer(f)
    for r in sh.rows:
        if r[0].style_id == 64:
            continue;
        print('---')
        c.writerow([getCellValue(cell) for cell in r if not isInValid(cell)])

'''
import openpyxl
import csv
from sys import argv

wb = openpyxl.load_workbook('2.xlsx', guess_types = True)
sh = wb.active
r = sh.rows[3]
a = r[0]
'''
