## 实现

    import re
    def translate(text, kw, ignore_case=False):
        search_keys = map(lambda x:re.escape(x), kw.keys())
        if ignore_case:
            kw = {k.lower():kw[k] for k in kw}
            regex = re.compile('|'.join(search_keys), re.IGNORECASE)
            res = regex.sub( lambda m:kw[m.group().lower()], text)
        else:
            regex = re.compile('|'.join(search_keys))
            res = regex.sub( lambda m:kw[m.group()], text)

        return res

    #'score: 99.5% name:%(name)s' %{'name':'foo'}
    res = translate( 'score: 99.5% name:{name}', {'{name}':'foo'})
    print(res)

    res = translate( 'score: 99.5% name:{NAME}', {'{name}':'foo'}, ignore_case=True)
    print(res)