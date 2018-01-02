---
layout: page
title:	
category: blog
description: 
---
# Preface

# svn diff
	Index: templates/h5/page/page_index.tpl
	===================================================================
	--- templates/h5/page/page_index.tpl	(revision 113582)
	+++ templates/h5/page/page_index.tpl	(working copy)
	@@ -59,9 +61,9 @@
	 </script>
	 {if $showMoreMenu}
		 <script id="moreTpl" type="text/template">
	-    {*<a href="javascript:location.reload();" data-action="-100"><span><i class="icon refresh"></i>刷新</span></a>
	+    <a href="javascript:location.reload();" data-action="-100"><span><i class="icon refresh"></i>刷新</span></a>
		 <a href="/searchs"><span><i class="icon search"></i>搜索</span></a>
	-    <a href="/" data-action="-2"><span><i class="icon home"></i>首页</span></a>*}
	+    <a href="/" data-action="-2"><span><i class="icon home"></i>首页</span></a>
		 {if $page.page_type eq '05' && $user.relation != -1}
			 <a href="javascript:;" data-action="2"><span>@{$user.ta}</span></a>
			 {*{if $user.relation eq 2 || $user.relation eq 3}

# diff
[diff](http://www.ruanyifeng.com/blog/2012/08/how_to_read_diff.html)

	$ diff -u old new
	diff -u a.c b.c
	--- a.c	2014-05-09 18:09:15.000000000 +0800
	+++ b.c	2014-05-09 18:10:59.000000000 +0800
	@@ -1 +1 @@
	-teste
	+ss


## svn 中的diff-cmd

	 svn diff --diff-cmd='diff' -x '-u'
	 Index: a.c
	 ===================================================================
	 --- a.c	(revision 1)
	 +++ a.c	(working copy)
	 @@ -0,0 +1 @@
	 +teste

	svn diff --diff-cmd='diff' -x '-i'
	Index: a.c
	===================================================================
	0a1
	> teste

# gid diff

	--- a.c    (revision 1)
	+++ a.c    (working copy)
	@@ -0,0 +1 @@
   	+teste
