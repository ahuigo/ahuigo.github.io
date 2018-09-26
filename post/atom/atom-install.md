---
layout: page
title: Preface
category: blog
description: 
date: 2018-09-26
---
# Preface

# bug
PATH BUG
https://github.com/atom/atom/pull/11054

# amp(Atom Package Management)

## amp config
Show customized settings:

	apm config list

Show all default settings:

	npm config ls -l

Edit configuration file directly:

	apm config edit

## amp version

	$ apm --version
	apm  1.6.0
	npm  2.13.3
	node 0.10.40
	python 2.7.11
	git 2.5.4

## apm install

	apm install markdown-writer
    
## apm debug
    apm update --verbose
    apm install --verbose
    apm install --check

### apm install --check
Error:

    gyp ERR! install error 

Seems that node-gyp isn't following the 302 Redirect sent by atom.io.

    Windows temporary:
    set ATOM_NODE_URL=http://gh-contractor-zcbenz.s3.amazonaws.com/atom-shell/dist
    Windows permanently:
    setx ATOM_NODE_URL http://gh-contractor-zcbenz.s3.amazonaws.com/atom-shell/dist /M

    Linux
    export ATOM_NODE_URL=http://gh-contractor-zcbenz.s3.amazonaws.com/atom-shell/dist

### apm 404
在安装包时，可能会遇到G*F*W 问题：

	$ apm install markdown-writer
	Installing markdown-writer to /Users/hilojack/.atom/packages
    
	gyp info it worked if it ends with ok
	gyp info using node-gyp@2.0.2
	gyp info using node@0.10.40 | darwin | x64
	gyp http GET https://atom.io/download/atom-shell/v0.34.5/node-v0.34.5.tar.gz
	gyp http 404 https://atom.io/download/atom-shell/v0.34.5/node-v0.34.5.tar.gz
	gyp WARN install got an error, rolling back install
	gyp ERR! install error
	gyp ERR! stack Error: 404 response downloading https://atom.io/download/atom-shell/v0.34.5/node-v0.34.5.tar.gz

参考:
https://github.com/atom/apm/issues/174
https://github.com/atom/apm/issues/322

### 通过http代理

	$cat ~/.atom/.apmrc
	apm config set http_proxy  "http://127.0.0.1:8080"
	apm config set https_proxy  "http://127.0.0.1:8080"
	apm config set strict-ssl=false

	apm config set ftp-proxy ftp://proxy:8080
	apm config set proxy http://proxy:8080

或者

	export ATOM_NODE_URL=http://gh-contractor-zcbenz.s3.amazonaws.com/atom-shell/dist
	export ATOM_NODE_URL=https://gh-contractor-zcbenz.s3.amazonaws.com/atom-shell/dist

或者改源, ~/.atom/.apmrc

	registry=https://registry.npm.taobao.org/
	strict-ssl=false
    
### 通过socks5
~/.atom/.apmrc

    strict-ssl = false
    http_proxy = socks5://127.0.0.1:1997
    https_proxy = socks5://127.0.0.1:1997