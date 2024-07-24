---
title: python http lib
date: 2024-07-24
private: true
---
# urllib
urllib2 is deprecated, use requests instead , except: `urllib.parse.urlsplit/urlparse`

## urllib.request.urlopen() file-like
.status .reason getheaders() read()

    from urllib import request
    with request.urlopen('https://www.baidu.com') as f:
        data = f.read()
        print('Status:', f.status, f.reason) # 200 OK
        for k, v in f.getheaders():
            print('%s: %s' % (k, v))
        print('Data:', data.decode('utf-8'))

## .parse.urlparse
	u = urllib.parse.urlparse(url)
		.scheme
		.path
		.query
		.netloc not .host
    >>> u._replace(scheme='http')

urlparse

    >>> from urlparse import urlparse
    >>> o = urlparse('http://www.cwi.nl:80/%7Eguido/Python.html')
    >>> o   
    ParseResult(scheme='http', netloc='www.cwi.nl:80', path='/%7Eguido/Python.html',
                params='', query='', fragment='')
    >>> o.scheme
    'http'
    >>> o.port
    80
    >>> o.geturl()
    'http://www.cwi.nl:80/%7Eguido/Python.html'

### .parse.parse_qsl

	import urllib.parse
	urllib.parse.parse_qs('a=1&b=2&b=3');
		{'a': ['1'], 'b': ['2','3']}
	urllib.parse.parse_qsl('a=1&b=2&b=3')
		[('a', '1'), ('b', '2'), ('b', '3')]

dict + parse_qsl:

	dict(urllib.parse.parse_qsl('a=1&b=2&b=3'))
        {'a': '1', 'b': '3'}

## .parse.urlencode

	urllib.parse.urlencode({'a':1})
	'a=1'
	urllib.parse.urlencode({'a':[1,2]}, doseq=True)
	'a=1&a=2'

### .parse.quote unquote
	urllib.parse.quote('中国人')
	urllib.parse.unquote('1%2C3)

# SimpleCookie

    from Cookie import SimpleCookie
    >>> sc = SimpleCookie('key1=val1; key2=val2; key3=val3')
    >>> for c,v in sc.items():
    ...     print c,v
    ...
    key3 Set-Cookie: key3=val3
    key2 Set-Cookie: key2=val2
    key1 Set-Cookie: key1=val1
    >>> sc['key1'].key
    >>> sc['key1'].value
