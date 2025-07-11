---
title: python uv
date: 2025-05-06
private: true
---
# python uv
Python 包管理生态中存在多种工具，如 pip、pip-tools、poetry、conda 等，
uv 是 Astral 公司推出的一款基于 Rust 编写的 Python 包管理工具, 替代poetry/pip
## install
pip install uv

## 初始化新项目
    # init project
    uv init myproj
    cat myproj
        uv.lock
        pyproject.toml
        .python-version

## uv sync
uv sync会自动查找下载python 版本(创建虚拟环境)，以及项目pkg 依赖, 更新uv.lock

    uv sync

## 包管理
    uv add pandas
    uv remove pandas

## uv run启动程序
uv run 会自动启动虚拟环境(.venv/bin/python)

    uv run main.py
    uv run mcp
    uv run pytest


### working directory
change cmd's working directory:

    uv run --directory /path/to/app cmd/main.py

See --project to only change the project root directory.


### uv 启动pytest:
    uv add --dev pytest

pyproject.toml file by adding these settings:

    [tool.pytest.ini_options]
    testpaths = ["tests"]
    python_files = "test_*.py"
    python_functions = "test_*

# uvx 
## uvx 是什么？
类似 npm 的 npx，`uvx` 是 `uv` 提供的一个工具，用于在虚拟环境中临时运行命令，而无需将其安装到项目中。

## uvx 使用
### 运行一次性命令
使用 `uvx` 可以直接运行命令，而无需将其添加到项目依赖中。例如：

    #这会在虚拟环境中运行 `black` 格式化代码，而无需将 `black` 添加到 `pyproject.toml`。
    uvx black@22.3.0 .
    uvx create-mcp-server

如果命令行有额外的可选依赖：

    uvx "mcp[cli]"

### cli 命令编写
```
[project.scripts]
# 命令指向1:src/black/__init__.py 中的 patched_main()
# 命令指向2: src/black.py 中的 patched_main()
# 命令指向3: black.py 中的 patched_main()
black = "black:patched_main"

# 命令指向1: xlparser/cli.py
xlparser = "xlparser.cli:main [cli]"
```

如果有额外可选依赖cli
```
[project.scripts]
mcp = "mcp.cli:app [cli]"

[project.optional-dependencies]
cli = ["typer>=0.12.4", "python-dotenv>=1.0.0"]

```