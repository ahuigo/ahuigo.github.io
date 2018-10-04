---
title: Python replace with dict
date: 2018-10-04
---
# Python replace with dict
so 上提到了这个问题
https://stackoverflow.com/questions/14156473/can-you-write-a-str-replace-using-dictionary-values-in-python/52611134

很多人采用 `format()`和`replace()`，但是不严谨:

    data =  '{content} {address}'
    for k,v in {"{content}":"some {address}", "{address}":"New York" }.items():
        data = data.replace(k,v)
    # results: some New York New York
    
    '{ {content} {address}'.format(**{'content':'str1', 'address':'str2'})
    # results: ValueError: unexpected '{' in field name

更严谨的实现是: `re.sub()`:

    import re
    def replace_dict(text, kw):
        search_keys = map(lambda x:re.escape(x), kw.keys())
        regex = re.compile('|'.join(search_keys))
        res = regex.sub( lambda m:kw[m.group()], text)
        return res
    
    #'score: 99.5% name:%(name)s' %{'name':'foo'}
    res = replace_dict( 'score: 99.5% name:{name}', {'{name}':'foo'})
    print(res)