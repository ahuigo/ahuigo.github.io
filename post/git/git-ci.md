---
layout: page
title:
category: blog
description:
---
# Preface

# private git
可以多个备份嘛:
1. coding.net
2. gitlab
2. bitbucket

# deploy 系统
http://walle-web.io/
Waffle is an automated project management tool powered by your GitHub issues & pull requests.

# gitlab

## install
> https://github.com/WebEntity/Installation-guide-for-GitLab-on-OS-X#8-install-gitlab

	git clone https://github.com/gitlabhq/gitlabhq.git gitlab

## wiki pgae

	setting ->
	Lightweight issue tracking system for this project
	Merge Requests
	Submit changes to be merged upstream.
	Wiki , pages for project documentation

## gitlab-ci
http://doc.gitlab.com/ci/quick_start/README.html
http://dockone.io/article/468

## jenkins with gitlab
http://www.jianshu.com/p/c69deb29720d

# Continuous integration(CI)
CI 测试包括
- 单元测试: 比如 PHPUnit, pyUnit(unittest module)
- 代码测试CI服务: travis-CI(基于单元测试导出), gitlab-CI, bamboo; What are the best hosted continuous integration services?
- 覆盖率测试: codecov vs Coveralls(有点老了) 

以php project 为例  :
https://segmentfault.com/a/1190000005090444#articleHeader8

## travis ci
A hosted continuous integration service for the open source community
Travis-CI所做的工作就是自动在虚拟机中运行.travis.yml中设定的内容进行单元测试，生成并导出报告。

https://travis-ci.org/profile/hilojack
http://docs.travis-ci.com/

## Icon Status

    [![Build Status](https://travis-ci.org/<Github_ID>/<Repo_Name>.svg?branch=master)](https://travis-ci.org/<Github_ID>/<Repo_Name>)
    [![Coverage Status](https://coveralls.io/repos/github/<Github_ID>/<Repo_Name>/badge.svg?branch=master)](https://coveralls.io/github/<Github_ID>/<Repo_Name>?branch=master)


## webhooks & services
Services / Add Packagist

## github ci tool
https://github.com/integrations/feature/build


## Hexo
Hexo 是静态网站生成工具, 类似的还有Hugo, Pugo ....
Travis-CI 在提交时触发`hexo generate`

## Bamboo
Travis Atlassian Bamboo
Bamboo is a continuous integration and deployment tool that ties automated builds, tests and releases together in a single workflow

## scrutinizer(quality)
https://scrutinizer-ci.com/

## Badge poser
https://poser.pugx.org/

## packagist.org
packagist.org

# Project Manager
pms、禅道PMS
