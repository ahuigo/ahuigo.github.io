from aiohttp import web
import json
async def aiohttp_handler(request):
    print('request.query')
    data = await request.post()
    # filename contains the name of the file in string format.
    d ={'data':data,
            'path':request.path,
            'query':request.query,
    }
    print(d)
    #filename = data['mp3'].filename

