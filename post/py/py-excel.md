---
layout: page
title:
category: blog
description:
---
# Preface
1. xlsx
	1. openpyxl
	2. xlsxwriter(alternative)
2. xls
	1. xlrd
	2. xlwt

# xlsx 格式
xlsx 是zip 文件：

	zip -t t.xlsx

## 数据类型
数据类型用s(style_id) 表示：

	2,12	date (天数，从1900-01-00 开始的天数)
	3,11	string

	<c r="A3" s="2"><v>42370</v></c>
	<c r="B3" s="12"><v>42374</v></c>
	<c r="C3" s="3"><v>400</v></c>
	<c r="D3" s="3" t="s"><v>20</v></c>

### 共享类型
`t="s"` 属于共享类型

	//sheet1.xml
	<row r="2" spans="1:256" s="9" customFormat="1" ht="15" customHeight="1" x14ac:dyDescent="0.15">
		<c r="A2" s="11" t="s"><v>0</v></c>
		<c r="B2" s="11" t="s"><v>1</v></c>
		<c r="C2" s="11" t="s"><v>2</v></c>
		<c r="D2" s="11" t="s"><v>3</v></c>
		<c r="E2" s="11" t="s"><v>4</v></c>

	//sharedStrings.xml
	<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="380" uniqueCount="155">
		<si><t>ID</t></si>
		<si><t>提交日期</t></si>
		<si><t>补偿日期</t></si>
		<si><t>订单来源</t></si>
		<si><t>城市</t></si>

# openpyxl
https://openpyxl.readthedocs.io/en/default/tutorial.html

	from openpyxl import load_workbook
	wb = load_workbook(filename = 'empty_book.xlsx')
	for sheetname in wb.sheetnames:
		ws = wb[sheetname]
	for ws in wb.worksheets:
		print(ws['A1'].value)

## row, cell

	from openpyxl import load_workbook
	wb = load_workbook(filename='large_file.xlsx', read_only=True)
	ws = wb['big_data'] # ws is now an IterableWorksheet

	for row in ws.rows:
		for cell in row:
			print(cell.value)

### row slicing
generator:

	rows = ws['A1':'C2']
	ws.iter_rows('A1:C2'):

tuple

	rows = ws.rows[0:3]

### cell

	cell = ws['A1']
	cell = ws.cell(row = 4, column = 2)

## csv

	import openpyxl
	import csv

	wb = openpyxl.load_workbook('test.xlsx')
	print(wb.sheetnames)
	sh = wb.active
	# python3 only
	with open('test.csv', 'w') as f:
		c = csv.writer(f); //writer(f, dialect='excel')
		for r in sh.rows:
			c.writerow([cell.value for cell in r])

# xlrd for old xls
see [xlrd](/excel-tutorial/xlrd/xlrd.md)
