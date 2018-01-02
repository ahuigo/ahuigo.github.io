import concurrent.futures, urllib.request
URLS = ['http://baidu.com','https://www.sogou.com/']
def load_url(url,timeout):
    with urllib.request.urlopen(url, timeout=timeout) as conn:
        return conn.read()

with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
    future_to_url = {executor.submit(load_url, url, 60): url for url in URLS}
    for future in concurrent.futures.as_completed(future_to_url):
        url=future_to_url[future]
        data = future.result()
        print(url, data.decode())
