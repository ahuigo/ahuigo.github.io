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


以src/myproj 结构初始化项目:
> Note: `--lib` 比 `--package` 只多一个`src/myproj/py.typed`
> 有 py.typed 的第三方库，对外承诺它是一个支持类型检查的包(PEP561)

    uv init --package myproj
    uv init --lib myproj

### 旧项目添加uv支持

    uv init
    # 添加私有源到 pyproject.toml(如有需要)
    uv add -r requirements.txt
    uv sync
    source .venv/bin/activate

## uv sync
uv sync会自动查找下载python 版本(创建虚拟环境)，以及项目pkg 依赖, 更新uv.lock

    uv sync

## python 版本管理
方法1：pyproject.toml 中指定python版本: uv sync
```
    [project]
    requires-python = ">=3.12,<3.13"
```
方法2：使用 .python-version 文件指定版本: uv sync

    echo "3.12.4" > .python-version
    uv sync

方法3：命令行指定版本: uv venv

    uv venv --python python3.12 .venv
    uv venv --python 3.8 --clear
    source .venv/bin/activate
    python --version

## 包管理
https://docs.astral.sh/uv/concepts/projects/sync/#syncing-the-environment

`project.optional-dependencies` are part of your published package and can be installed by the end user via `pip install your-package[some-extra]` or `uv add "your-package[some-extra]" `

    uv add pandas
    uv add pandas --index https://artifactory.local/artifactory/pypi/simple --index-strategy unsafe-best-match
    uv remove pandas
    uv add --dev pytest

    # 添加开发依赖: [dependency-groups] (发布包时不会包含这些依赖)
    uv add --dev pytest black mypy # 等价于  uv add --group dev pytest black mypy
    uv sync # 开发时，默认初始化会安装 基本的依赖+dev 组
    uv sync --group dev # 安装基本依赖+dev组（等价上面的）
    uv sync --no-dev # 只安装基本的依赖
    uv sync --only-dev # 只安装dev组（不安装基本的依赖）

    # 添加可选依赖组 [project.optional-dependencies] (发布包时会包含这些依赖)
    uv add --optional test pytest-cov pytest # pyproject.toml 中生成test 分组 # test =["pytest-dov","pytest"]
    uv sync --extra test # 同步安装test 分组

    # 安装分组时，不删除其它分组的包的话，要加上 --inexact
    uv sync --group dev --inexact
    uv sync --extra test --inexact

### 全局源
~/.config/uv/uv.toml
```
[tool.uv]
index-strategy = "unsafe-first-match"
index-url = "https://artifactory.local/artifactory/pypi/simple"
extra-index-url = [
    "https://artifactory.local/artifactory/api/pypi/pypi-my/simple"
]
```

### 项目源pyproject.toml
```
[tool.uv]
index-url = "https://artifactory.local/pypi/simple"
extra-index-url = [
    "https://pypi.org/simple"  # 官方 PyPI 作为备用源
]

# 定义自定义索引
[[tool.uv.index]]
name = "pytorch"
url = "https://download.pytorch.org/whl/cpu"

[[tool.uv.index]]
name = "my-pypi"
url = "https://artifactory.local/pypi/simple"

# 配置特定包使用的源
[tool.uv.sources]
torch = { index = "pytorch" }
my-internal-package = { index = "my-pypi" }

```
### publish

先指定（可选）打包的文件：
```
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["my_pkg"]

[tool.hatch.build.targets.sdist]
include = [
    "/my_pkg",
    "/readme.md"
]
exclude = [
    "/.vscode",
    "/tests"
]
```



uv 不支持~/.pypirc, 只能使用以下方式
```
# 1 build
uv build

# 2. test build package
$ my_pkg=xlparser uv run --with $my_pkg --no-project -- python -c "import $my_pkg; print('Success!')"

# 3. publish
export UV_INDEX_URL="https://your-private-repo.com/simple"
export UV_PYPI_USERNAME="your_repo_user"
export UV_PYPI_PASSWORD="your_repo_password_or_token"
# 3种源指定方式
uv publish dist/* 
uv publish --publish-url xxx
uv publish --index xxx
```


| 方法 | 命令/设置 | 安全性 | 推荐场景 |
| :--- | :--- | :--- | :--- |
| **API 令牌 + 环境变量** | `export UV_PYPI_USERNAME="__token__"`<br>`export UV_PYPI_PASSWORD="pypi-..."`<br>`uv publish dist/*` | **最高** | **CI/CD, 自动化脚本, 日常开发** |
| **API 令牌 + 交互提示** | `uv publish dist/*`<br>*(然后手动输入)* | 很高 | 手动发布 |
| **用户名/密码 + 环境变量** | `export UV_PYPI_USERNAME="user"`<br>`export UV_PYPI_PASSWORD="pass"`<br>`uv publish dist/*` | 较高 | 传统方式，适用于不支持令牌的仓库 |
| **命令行参数** | `uv publish --repository-url ... --username ... --password ...` | **最低** | 快速测试，不应用于生产或共享环境 |

## 不需要 from src.xxx
默认情况下./src 才是包目录, uv run main.py 时, import语句会从src目录找module, 不需要写 from src.user

以下配置你不需要设置, 如果你想显式的指定,可以这样:
```
#################方法1: 使用 setuptools ##################
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

# 告诉 setuptools 在 'src' 目录中寻找包
[tool.setuptools.packages.find]
where = ["src"]

######### 方法2：使用 hatchling (Hatch 的构建后端) ########
# hatch 默认就支持 src 布局，通常无需额外配置。如果 src/<package_name> 存在，它会优先使用。
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

# Hatch 会自动检测 src 目录。 # 如果需要明确指定，可以这样做：
[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]
```

如果用想用项目根目录作为包目录,可以这样做
```
    [build-system]
    requires = ["setuptools", "wheel"]
    build-backend = "setuptools.build_meta"

    [tool.setuptools]
    py-modules = ["config"]
    packages = ["apps", "utils", "openapi"]
    # packages = ["."] # 这样好像也行

    [tool.pytest.ini_options]
    pythonpath = ["."]
```


## uv run启动程序
uv run 会自动启动虚拟环境(.venv/bin/python)

    uv run main.py
    uv run mcp
    uv run pytest


### working directory
方案1： change cmd's working directory:

    uv run --directory /path/to/app cmd/main.py
    See --project to only change the project root directory.

方案2： 按模块运行（推荐）

    在项目根目录执行：
    uv run -m web.task
    “-m web.task”会以模块方式运行，Python 会把当前工作目录（项目根）放到 sys.path，使得 import lib.lib 能被正确解析。

方案3：调整包结构与导入, 这种“src 布局”对打包和工具兼容性更好。

    $ uv init --lib
    $ tree .
    src/
        app/
            lib.py
            web/
                task.py
                route.py
    运行：uv run -m app.web.task
    导入：from app.lib import tidy 或在 web/task.py 里使用相对导入：from ..lib import tidy

传统做法（不建议）

    PYTHONPATH=. uv run web/task.py
    或
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))


### uv 启动pytest:
https://github.com/astral-sh/uv/issues/7260

    uv add --dev pytest
    uv run pytest --verbose

pyproject.toml file by adding these settings:

    [tool.pytest.ini_options]
    pythonpath = ["."]
    testpaths = ["tests"]
    python_files = "test_*.py"
    python_functions = "test_*

# uvx 
     pipx install uv

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
