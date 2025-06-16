---
title: mcp
date: 2025-05-19
private: true
---
# mcp inspector
https://modelcontextprotocol.io/docs/tools/inspector

## js inspector

    npx @modelcontextprotocol/inspector <command>
    npx @modelcontextprotocol/inspector index.js arg1 ...
    npx @modelcontextprotocol/inspector node path/to/server/index.js args...

## python inspector
> https://github.com/modelcontextprotocol/python-sdk?tab=readme-ov-file#quickstart

### use mcp cli
The fastest way to test and debug your server is with the MCP Inspector:

    mcp dev server.py

    # Add dependencies
    mcp dev server.py --with pandas --with numpy

    # Mount local code
    mcp dev server.py --with-editable .

# write mcp
- MCP Server Development Protocol
https://docs.cline.bot/mcp/mcp-server-development-protocol