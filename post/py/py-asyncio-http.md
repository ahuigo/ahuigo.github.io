---
title: Python 异步tcp
date: 2019-02-06
---
有很多库支持async tcp:
1. asyncio 只是异步的tcp 框架
2. aiohttp 提供了对async http 的完整支持

# asyncio
tcp 访问实例: https://docs.python.org/3/library/asyncio-stream.html


    import asyncio

    async def tcp_echo_client(message):
        reader, writer = await asyncio.open_connection(
            '127.0.0.1', 8888)

        print(f'Send: {message!r}')
        writer.write(message.encode())

        data = await reader.read(100)
        print(f'Received: {data.decode()!r}')

        print('Close the connection')
        writer.close()

    asyncio.run(tcp_echo_client('Hello World!')) # `run()` is void function

server:

    import asyncio
    async def handle_echo(reader, writer):
        data = await reader.read(100)
        message = data.decode()
        addr = writer.get_extra_info('peername')

        print(f"Received {message!r} from {addr!r}")

        print(f"Send: {message!r}")
        writer.write(data)
        await writer.drain()

        print("Close the connection")
        writer.close()

    async def main():
        server = await asyncio.start_server( handle_echo, '127.0.0.1', 8888)

        addr = server.sockets[0].getsockname()
        print(f'Serving on {addr}')

        async with server:
            await server.serve_forever()

    asyncio.run(main())
