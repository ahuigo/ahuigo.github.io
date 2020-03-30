---
title: Requests
date: 2018-09-28
---
# Requests
Refer to: http://aiohttp.readthedocs.io/en/stable/tutorial.html#aiohttp-tutorial
```
import aiohttp
import asyncio
import async_timeout

async def fetch(session, url):
    with async_timeout.timeout(10):
        async with session.get(url) as response:
            return await response.text()

async def main():
    async with aiohttp.ClientSession() as session:
        html = await fetch(session, 'http://python.org')
        print(html)

loop = asyncio.get_event_loop()
loop.run_until_complete(main())
```

## options

    async with session.options(url, headers=headers) as r:

## post
Your dictionary of data will automatically be form-encoded when the request is made:

    payload = {'key1': 'value1', 'key2': 'value2'}
    # data = json.dumps(payload)
    async with session.post('http://httpbin.org/post', data=payload) as resp:
        print(await resp.text())

## post file
To upload Multipart-encoded files:

    url = 'http://httpbin.org/post'
    files = {'file1': open('report.xls', 'rb'), 'key':'value', 'file2':b'binary_file'}
    await session.post(url, data=files)

You can set the filename, content_type explicitly:

    url = 'http://httpbin.org/post'
    data = aiohttp.helpers.FormData(
        {'key1':'str1', 'key2':'str2'} # not allow int
    )
    data.add_fields([('key1', 'val1'), {'key2':'val2', 'key3':'val3'}])
    data.add_field('file',
                   open('report.xls', 'rb'),
                   filename='report.xls',
                   content_type='application/vnd.ms-excel')

    await session.post(url, data=data)

### Streaming uploads
aiohttp supports multiple types of streaming uploads, which allows you to send large files without reading them into memory.

As a simple case, simply provide a file-like object for your body:

    with open('massive-body', 'rb') as f:
       await session.post('http://some.url/streamed', data=f)

Or you can provide an coroutine that yields bytes objects:

    @asyncio.coroutine
    def my_coroutine():
       chunk = yield from read_some_data_from_somewhere()
       if not chunk:
          return
       yield chunk

#### upload StreamReader object
Also it is possible to use a StreamReader object.
Lets say we want to upload a file from another request and calculate the file SHA1 hash:

       async def feed_stream(resp, stream):
           h = hashlib.sha256()

           while True:
               chunk = await resp.content.readany()
               if not chunk:
                   break
               h.update(chunk)
               stream.feed_data(chunk)

           return h.hexdigest()

       resp = session.get('http://httpbin.org/post')
       stream = StreamReader()
       loop.create_task(session.post('http://httpbin.org/post', data=stream))

       file_hash = await feed_stream(resp, stream)

Because the response content attribute is a StreamReader, you can chain get and post requests together (aka HTTP pipelining):

    r = await session.get('http://python.org')
    await session.post('http://httpbin.org/post', data=r.content)

# Headers

    headers = {'content-type': 'application/json'}
    await session.post(url, data=json.dumps(payload), headers=headers)

# Cookie

## send Cookies
To send your own cookies to the server, you can use the cookies parameter of ClientSession constructor:

    url = 'http://httpbin.org/cookies'
    cookies = {'cookies_are': 'working'}
    async with aiohttp.ClientSession(cookies=cookies) as session:
        async with session.get(url) as resp:
            assert await resp.json() == { "cookies": {"cookies_are": "working"}}

## update cookie
vim /usr/local/lib/python3.5/site-packages/aiohttp/cookiejar.py +80

    session.cookie_jar.update_cookies(cookies, response_url=None)
    session.cookie_jar.update_cookies({'a':'bbbbbb'}, response_url="http://qq.com");
        Update cookies returned by server in Set-Cookie header.
        cookies – a collections.abc.Mapping (e.g. dict, SimpleCookie) or iterable of pairs with cookies returned by server’s response.

    session.cookie_jar.clear()
    session.cookie_jar.__dict__['_cookies']
        defaultdict(<class 'http.cookies.SimpleCookie'>, {'qq.com': <SimpleCookie: a='bbbbbb' cookies_are='working'>})
    session.cookie_jar.__dict__['_cookies']['qq.com']['a'].value
        bbbb
    session.cookie_jar.__dict__['_cookies']['qq.com']['a'].key
        a

Note:

    session.cookie_jar.update_cookies({'a':'bbbbbb'}, response_url="http://qq.com");# support qq.com only
    session.cookie_jar.update_cookies({'a':'bbbbbb'}, response_url="http://.qq.com");# support *.qq.com
    session.cookie_jar.update_cookies({'a':'bbbbbb'}, response_url="qq.com");       # support *.qq.com

## iterate
These cookies may be iterated over:

    for cookie in session.cookie_jar:
        print(cookie.key)
        print(cookie.value)
        print(cookie["domain"])

## response
    async with aiohttp.ClientSession(cookies=cookies) as session:
        async with session.get(url) as resp:
            await resp.json()


# proxy
Proxy support

    async with aiohttp.ClientSession() as session:
        async with session.get("http://python.org", proxy="http://127.0.0.1:8888") as resp:
            print(resp.status)

it also supports proxy authorization:

    async with aiohttp.ClientSession() as session:
        proxy_auth = aiohttp.BasicAuth('user', 'pass')
        async with session.get("http://python.org", proxy="http://some.proxy.com", proxy_auth=proxy_auth) as resp:
            print(resp.status)

Authentication credentials can be passed in proxy URL:

    session.get("http://python.org", proxy="http://user:pass@some.proxy.com:8888"

## ssl
for aiohttp:

    # for request
    connector = aiohttp.TCPConnector(verify_ssl=False)
    aiohttp.request('get', url, connector=connector)

    # for session
    aiohttp.ClientSession(connector=aiohttp.TCPConnector(verify_ssl=False))

for requests:

    session.post(url, verify=False)
        verify:
            True
            False
            Path to a CA_BUNDLE file for Requests to use to validate the certificates.