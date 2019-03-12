# gunicorn aiohttp-server:app --bind localhost:3000 --worker-class aiohttp.worker.GunicornWebWorker
import json
import asyncio
import logging
from aiohttp import web
from functools import wraps

import os

logging.basicConfig(level=logging.INFO)
log = logging.getLogger()


def rest_handler(handler_func):
    """
    Allows handlers to return dict.
    Errors are handled and put in json format.
    """
    @wraps(handler_func)
    def wrapper(self, request):
        error_code = None
        try:
            res = yield from handler_func(self, request)
            result = dict(status='OK', result=res)
        except web.HTTPClientError as e:
            log.warning('Http error: %r %r', e.status_code, e.reason,
                        exc_info=True)
            error_code = e.status_code
            result = dict(error_code=error_code,
                          error_reason=e.reason,
                          status='FAILED')
        except Exception as e:
            log.warning('Server error', exc_info=True)
            error_code = 500
            result = dict(error_code=error_code,
                          error_reason='Unhandled exception',
                          status='FAILED')

        assert isinstance(result, dict)
        body = json.dumps(result).encode('utf-8')
        result = web.Response(body=body)
        result.headers['Content-Type'] = 'application/json'
        if error_code:
            result.set_status(error_code)
        return result

    return wrapper

class Rest:

    @asyncio.coroutine
    def index(self, request):
        return web.Response(body=b"Hello, world")

    @rest_handler
    @asyncio.coroutine
    def log(self, request):

        data = yield from request.post()


        # Get the Log Type to write to proper Mongo Collection / DB

        collection = db[dict(data)['col_name']]
        data_inserted = json.loads(json.dumps(dict(data)))
        # Data Inserted to Database here:
        response = collection.insert_one(data_inserted)

        # print(response.inserted_id)
        log.info('Message reveived %r', data_inserted)
        return ""


# def main():
rest = Rest()
app = web.Application()
app.router.add_route('GET', '/', rest.index)
app.router.add_route('POST', '/log', rest.log)
