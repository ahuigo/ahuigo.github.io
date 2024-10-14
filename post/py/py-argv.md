---
layout: page
title: py-argv
category: blog
description: 
date: 2018-09-28
---
# Preface
- click
click 之于argparse/argv, 相当于requests 之于urllib

命令行程序开发

	asciimatics：跨平台，全屏终端包（即鼠标/键盘输入和彩色，定位文本输出），完整的复杂动画和特殊效果的高级API。官网
	cement：Python 的命令行程序框架。官网
	click：一个通过组合的方式来创建精美命令行界面的包。官网
	cliff：一个用于创建命令行程序的框架，可以创建具有多层命令的命令行程序。官网
	clint：Python 命令行程序工具。官网
	colorama：跨平台彩色终端文本。官网
	docopt：Python 风格的命令行参数解析器。官网
	Gooey：一条命令，将命令行程序变成一个 GUI 程序。官网
	python-prompt-toolkit：一个用于构建强大的交互式命令行程序的库。官网
	Pythonpy：在命令行中直接执行任何Python指令。官网

生产力工具

    aws-cli：Amazon Web Services 的通用命令行界面。官网
    bashplotlib：在终端中进行基本绘图。官网
    caniusepython3：判断是哪个项目妨碍你你移植到 Python 3。官网
    cookiecutter：从 cookiecutters（项目模板）创建项目的一个命令行工具。官网
    doitlive：一个用来在终端中进行现场演示的工具。官网
    howdoi：通过命令行获取即时的编程问题解答。官网
    httpie：一个命令行HTTP 客户端，cURL 的替代品，易用性更好。官网
    PathPicker：从bash输出中选出文件。官网
    percol：向UNIX shell 传统管道概念中加入交互式选择功能。官网
    SAWS：一个加强版的 AWS 命令行。官网
    thefuck：修正你之前的命令行指令。官网
    mycli：一个 MySQL 命令行客户端，具有自动补全和语法高亮功能。官网
    pgcli：Postgres 命令行工具，具有自动补全和语法高亮功能。官网
    try：一个从来没有更简单的命令行工具，用来试用python库。官网
    ```

# sys.argv

	from sys import argv
	script, arg1, arg2 = argv

# argparse

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--name", default="ahui", help="your name")
    args=parser.parse_args()

## with pytest
    import argparse
    def parse_args(args):
        parser = argparse.ArgumentParser(...)
        parser.add_argument("-n", "--name", default="ahui", help="your name")
        return parser.parse_args(args)

    def test_parser(self):
        parser = parse_args(['-l', '-m'])
    
    

## description and help

    parser = argparse.ArgumentParser(description="calculate X to the power of Y")
    parger.add_argument('-r', '--run', help="running")

## enum args
    from enum import Enum
    class Color(Enum):
        red = 'red'
        blue = 'blue'
        green = 'green'

        def __str__(self):
            return self.value

    parser.add_argument('--color', type=Color, choices=list(Color))
    parser.add_argument('--color', type=str, choices=('red','blue'))

## unknown args
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--name", default="ahui", help="your name")
    parser.add_argument('integers', nargs='+',)
    #args = parser.parse_args()
    args, unknown = parser.parse_known_args(["-unknown",'other'])
    print(args, unknown)

## file arg

    parser = argparse.ArgumentParser()
    parser.add_argument('--raw', type=argparse.FileType('wb', 0))
    parser.add_argument('in', type=argparse.FileType('r'))
    parser.add_argument('out', type=argparse.FileType('w', encoding='UTF-8'))
    # test
    parser.parse_args(['--raw', 'raw.dat', "in.txt",'out.txt'])

## positional args

    parser.add_argument("p1")
    parser.add_argument("p2")
    args = parser.parse_args()
    // python3 a.py foo bar
    // args = namespace{p1:foo, p2:bar}; 
    args.p1

multiple args:

    # N [N ...]
    # args = {'integers':...}
    parser.add_argument('integers', metavar='N', type=int, nargs='+',)

## optional arg

    parser.add_argument("-n", "--name", default="ahui", help="your name")
    parser.add_argument("-n", dest="name", default="ahui", help="your name")
    parser.add_argument("-p", type=int)

## required arg

    parser.add_argument("-p", required=True)

## bool arg
action="store_true" is bool

    parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_true")
    parser.add_argument("-v", "--verbose", help="increase output verbosity",
                    action="store_false")

# click 
## help?
    @click.command(no_args_is_help=True)

echo help:

    ctx = click.get_current_context()
    click.echo(ctx.get_help())
    ctx.exit()

## option
option 的先后，也args name的先后无关

    import click
    @click.command()
    @click.option('-count', default=1, help='Number of greetings')
    @click.option('-name', prompt='Your name', help='The person to greet')
	@click.argument('more_params', nargs=-1)
    def hello(name, count, more_params): # 没有位置先后
        """This script prints hello NAME COUNT times."""
		click.echo('Hello %s! count=%s' % (name, count));
		print(more_params)

    if __name__ == '__main__':
        hello()

click.command 装饰使hello 能接收cli args:

    p a.py 1 2 3 -name 'ahui'

### bool:

    @click.command()
    @click.option('-h', is_flag=True, help='Print help usage')
    @click.argument('args', nargs=-1)
    def main(args, **kw):
        """
        Usage: 
            xlparser [options] <src_file> [<out_file>]\n
                options:\n
                    -h       For help.\n
        """
        if 'h' in kw:
            ctx = click.get_current_context()
            click.echo(ctx.get_help())
            ctx.exit()


### required
toto:

    @click.option('-count', required=True, prompt='Number of greetings')

### count

    @click.option('-v', '--verbose', count=True)
    def log(verbose):
        click.echo('Verbosity: %s' % verbose)

### multi value

    @click.option('--item', type=(unicode, int))
    def putitem(item):
        click.echo('name=%s id=%d' % item)
    $ putitem --item peter 1338
    name=peter id=1338

    @click.option('--pos', nargs=2, type=float)
    def findme(pos):

## multi argument(顺序参数)

	@click.command()
	@click.argument('src', nargs=-1) ;# multiple
	@click.argument('dst', nargs=1)
	def copy(src, dst):
		for fn in src:
			click.echo('move %s to folder %s' % (fn, dst))

And what it looks like:

	$ copy foo.txt bar.txt my_folder
	move foo.txt to folder my_folder
	move bar.txt to folder my_folder

## file argument
Example:

	@click.command()
	@click.argument('input', type=click.File('rb'))
	@click.argument('output', type=click.File('wb'))
	def inout(input, output):
		while True:
			chunk = input.read(1024)
			if not chunk:
				break
			output.write(chunk)

And what it does:

	$ inout - hello.txt
	hello
	^D
	$ inout hello.txt -
	hello