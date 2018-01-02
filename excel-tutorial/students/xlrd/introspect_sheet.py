from xlrd import open_workbook,cellname

book = open_workbook('odd.xls')
sheet = book.sheet_by_index(0)

print(sheet.name)

for row_index in range(sheet.nrows):
    for col_index in range(sheet.ncols):
        print(cellname(row_index,col_index),'-', end='')
        print(sheet.cell(row_index,col_index).value)
