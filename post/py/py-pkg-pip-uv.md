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

## 默认的源：
全局创建或编辑 ~/.config/uv/uv.toml 文件：

    [pip]
    index-url = "https://pypi.tuna.tsinghua.edu.cn/simple"
    # 或者使用其他镜像源，如：
    # index-url = "https://mirrors.aliyun.com/pypi/simple/"
    # index-url = "https://pypi.douban.com/simple/"


项目级:

    [tool.uv]
    index-url = "https://pypi.tuna.tsinghua.edu.cn/simple"
    extra-index-url = [
        "https://pypi.org/simple",
        "https://mirrors.aliyun.com/pypi/simple/"
    ]

以下优先级搜索包：
1. index-url 指定的主要源
2. extra-index-url 中的源（按配置顺序）

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
    uv pip install --upgrade pandas
    uv pip install --upgrade --all
    uv add --dev pytest

index 指定:

    # 指定pip --extra-index-url (和--index-url不同， extra可以是多个，不会替换默认的pypi index)
    uv add --index https://x.pypi/pypi-pl/simple pandas

为某包固定使用index

    [tool.uv.sources]
    torch = { index = "pytorch" }

    [[tool.uv.index]]
    name = "pytorch"
    url = "https://download.pytorch.org/whl/cpu"


## uv run启动程序
uv run 会自动启动虚拟环境(.venv/bin/python)

    uv run main.py
    uv run mcp
    uv run pytest
    uv run python

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
    python_functions = "test_*"

then:

    uv run pytest

## publish
    uv build
    uv build <SRC>

uv publish	发布包到 PyPI 或自定义索引(pypi 中的名字)

    uv publish
    uv publish --index https://test.pypi.org/legacy/

publish 到私有pypi：

    [[tool.uv.index]]
    name = "testpypi"          # 索引名称
    url = "https://test.pypi.org/simple/"  # 索引URL（用于搜索包）
    publish-url = "https://test.pypi.org/legacy/"  # 发布URL（必填）
    explicit = true           # 显式模式（可选）

测试包安装与导入:

    uv run --with <PACKAGE> --no-project -- python -c "import <PACKAGE>"	
        --no-project：避免从本地目录安装
    --refresh-package <PACKAGE>：清除缓存版本
# uvx 
## uvx 是什么？
类似 npm 的 npx，`uvx` 是 `uv` 提供的一个工具，用于在虚拟环境中临时运行命令，而无需将其安装到项目中。

## uvx 使用
> uvx虚拟环境存储在 uv 统一的缓存目录中，并被视为一次性使用，也就是说，运行uv cache clean该环境后将被删除。缓存该环境只是为了减少重复调用的开销。如果删除该环境，系统会自动创建一个新的环境。

### 运行一次性命令
使用 `uvx` 可以直接运行命令，而无需将其添加到项目依赖中。例如：

    #这会在虚拟环境中运行 `black` 格式化代码，而无需将 `black` 添加到 `pyproject.toml`。
    uvx black@22.3.0 .
    uvx create-mcp-server
    uvx httpx==0.6.0

如果命令行有额外的可选依赖：(可选依赖它不会自动安装)

    uvx "mcp[cli]"
    uvx "mcp[cli,other]"

### cli 命令编写
```
[tool.uv]
package = true

[project.scripts]
# 命令指向1:src/black/__init__.py 中的 patched_main()
# 命令指向2: src/black.py 中的 patched_main()
# 命令指向3: black.py 中的 patched_main()
# 执行：
#      - uv sync && uv run black
#      - PYTHONPATH=./src python ./src/black.py
black = "black:patched_main"

# 命令指向1: xlparser/cli.py
xlparser = "xlparser.cli:main [cli]"
```

如果有额外可选依赖cli, 这样写：

```toml
# uv run mcp
[project.scripts]
mcp = "mcp.cli:app [cli]"

[project.optional-dependencies]
cli = ["typer>=0.12.4", "python-dotenv>=1.0.0"]
```