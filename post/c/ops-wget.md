---
layout: page
title:	wget
category: blog
description:
---
# ftp

    wget -r --user="user@login" --password="password" ftp://server.com/
    wget -r ftp://user:pass@server.com/

# continue

	wget -c url

# ipv6

	wget -4 url
	-4
	 --inet4-only
	-6
	 --inet6-only

# output

## output file

	-O file
	-O -
		specify output file as stdin
	-o logfile
		log all messages to logfile
	-r
		Recursive download.(全站, 不需要-p)
	-p
		This option causes Wget to download all the files that are necessary to properly display a given HTML page.
		This includes such things as inlined images, sounds, and ref-erenced stylesheets.

Example: Dump Site

	wget --random-wait -r -p -e robots=off -U mozilla http://pcottle.github.io/learnGitBranching/
	-q , --quiet
	-v, --verbose
		Makes the  fetching more verbose

## header

    wget --header='User-Agent: Chrome/68.0.97' ahuigo.com -O index

## output log

	-o log_file
		logs the output

## dump header

	-D file
		dump header to file
	-D-
		dump to output

# limit

### wait time
	--random-wait to let wget chose a random number of seconds to wait, avoid get into black list.

### limit rate
	--limit-rate=20k limits the rate at which it downloads files.
