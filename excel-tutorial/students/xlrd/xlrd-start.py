from xlrd import open_workbook
wb = open_workbook('simple.xls')
for s in wb.sheets():
    'Sheet:',s.name
    for row in range(s.nrows):
        cells = []
        for col in range(s.ncols):
            value,ctype = (s.cell(row,col).value, s.cell(row,col).ctype)
            cells.append((ctype, value))
            print(ctype, value, end='')
        print()

