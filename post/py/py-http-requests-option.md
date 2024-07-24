---
title: Advanced python requests
date: 2020-04-24
private: true
---
# Advanced python requests
https://findwork.dev/blog/advanced-usage-python-requests-timeouts-retries-hooks/#retry-on-failure
## example
> pylib/net/http/request-form-multipart.py 

## timeout

    connect_timeout = 1 # 1s
    read_timeout = 10 # 10s
    r = requests.get('https://github.com', timeout=(connect_timeout, read_timeout))

    r = requests.get('https://github.com', timeout=10) # connect_timeout=read_timeout=10s


## session cookie
### save cookie

    import requests, pickle
    session = requests.session()

    with open('somefile', 'wb') as f:
        pickle.dump(session.cookies, f)

Loading is then:

    session = requests.session()  # or an existing session

    with open('somefile', 'rb') as f:
        session.cookies.update(pickle.load(f))

### set cookie

    import requests
    s = requests.session()
    # Note that domain keyword parameter is the only optional parameter here
    cookie_obj = requests.cookies.create_cookie(domain='www.domain.com',name='COOKIE_NAME',value='the cookie works')
    s.cookies.set_cookie(cookie_obj)

or:

    my_cookie = {
        "version":0,
        "name":'COOKIE_NAME',
        "value":'true',
        "port":None,
        # "port_specified":False,
        "domain":'www.mydomain.com',
        # "domain_specified":False,
        # "domain_initial_dot":False,
        "path":'/',
        # "path_specified":True,
        "secure":False,
        "expires":None,
        "rest":{},
        "rfc2109":False
    }

    s = requests.Session()
    s.cookies.set(**my_cookie)

### Adding a custom cookie to requests session

    >>> import requests
    >>> s = requests.session()
    >>> required_args = {
            'name':'COOKIE_NAME',
            'value':'the cookie works'
        }
    >>> optional_args = {
        'version':0,
        'port':None,
    #NOTE: If domain is a blank string or not supplied this creates a
    # "super cookie" that is supplied to all domains.
        'domain':'www.domain.com',
        'path':'/',
        'secure':False,
        'expires':None,
        'discard':True,
        'comment':None,
        'comment_url':None,
        'rest':{'HttpOnly': None},
        'rfc2109':False
    }
    >>> my_cookie = requests.cookies.create_cookie(**required_args,**optional_args)
    # Counter-intuitively, set_cookie _adds_ the cookie to your session object,
    #  keeping existing cookies in place
    >>> s.cookies.set_cookie(my_cookie)
    >>> s.cookies

### Bonus: Lets add a super cookie then delete it

    >>> my_super_cookie = requests.cookies.create_cookie('super','cookie')
    >>> s.cookies.set_cookie(my_super_cookie)

### delete cookie
delete by name

    >> s.cookies.set(name="id_token",value="hahah2", domain='httpbin.org')
    >> del s.cookies['id_token']

delete all

    >>> s.cookies.clear()
    >>> s.cookies.keys()
    []


## retry

    from requests.adapters import HTTPAdapter
    from requests.packages.urllib3.util.retry import Retry

    retry_strategy = Retry(
        total=3,
        status_forcelist=[429, 500, 502, 503, 504],
        method_whitelist=["HEAD", "GET", "OPTIONS"]
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    http = requests.Session()
    http.mount("https://", adapter)
    http.mount("http://", adapter)

    response = http.get("https://en.wikipedia.org/w/api.php")

retry+timeout

    retries = Retry(total=3, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504])
    http.mount("https://", TimeoutHTTPAdapter(max_retries=retries))