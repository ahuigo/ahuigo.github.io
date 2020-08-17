---
title: pandas html parser
date: 2020-08-17
private: true
---
# read_html parser

    pd.read_html('URL_ADDRESS_or_HTML_FILE')

## parse table
    import pandas as pd
    html = '''<table>
    <tr><th>a</th><th>b</th> <th>c</th><th>d</th></tr>
    <tr><td>1</td><td>2</td> <td>3</td><td>4</td></tr>
    </table>'''

    l = pd.read_html(html)
    print(l) # [   a  b  c  d 0  1  2  3  4]
    print(type(l)) # list

