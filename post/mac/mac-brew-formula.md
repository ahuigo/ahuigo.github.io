---
layout: page
title:	brew dev
category: blog
description: 
---
# Prepare
了解Homebrew概念

    Keg：安装好的脚本、软件等；
    Cellar：所有用 Homebrew 安装在本地的脚本、软件组成的集合；
    Formula：定义如何下载、编译和安装脚本或软件的 Ruby 脚本；
    Tap：Formula 仓库

生成Formula

	cd $(brew --repo ahuigo/ahui)
    brew create https://github.com/ahuigo/arun/archive/refs/tags/master.tar.gz --tap ahuigo/homebrew-ahui

## proxy(via socks5)
    export ALL_PROXY=socks5://127.0.0.1:1080

# Write formula
brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb

	require 'formula'

	class Sshpass < Formula
	  url 'http://sourceforge.net/projects/sshpass/files/sshpass/1.05/sshpass-1.05.tar.gz'
	  homepage 'http://sourceforge.net/projects/sshpass'
	  sha256 'c3f78752a68a0c3f62efb3332cceea0c8a1f04f7cf6b46e00ec0c3000bc8483e'

	  def install
		system "./configure", "--disable-debug", "--disable-dependency-tracking",
							  "--prefix=#{prefix}"
		system "make install"
	  end

	  def test
		system "sshpass"
	  end
	end

## sha256

    $ shasum -a 256 test.tgz

## binary package
https://github.com/v2ray/homebrew-v2ray/blob/master/Formula/v2ray-core.rb

利用bin.install, etc.install copy

    def install
        # ENV.deparallelize  # if your formula fails when building in parallel

        # system "tar -Jvxf otfcc-mac64-0.2.3.tgz"
        bin.install "otfccbuild"
        bin.install "otfccdump"

        (etc/"v2ray").mkpath
        etc.install "config.json" => "v2ray/config.json"
    end



## depends on

    class Foo < Formula
        depends_on "pkg-config"
        depends_on "jpeg"
        depends_on "readline" => :recommended
        depends_on "gtk+" => :optional
        depends_on "httpd" => [:build, :test]
        depends_on :x11 => :optional
        depends_on :xcode => "9.3"
    end

# Use Formula
> refer to : https://segmentfault.com/a/1190000012826983

repo可以省略`homebrew-`

    brew tap <user/repo>
    brew untap <user/repo>

    brew install vim  # installs from homebrew/core
    brew install username/repo/vim  # installs from your custom repo

## tap example
https://github.com/v2ray/homebrew-v2ray/blob/master/Formula/v2ray-core.rb

    brew tap v2ray/v2ray
    brew install v2ray-core

or

    brew install v2ray/v2ray/v2ray-core

https://github.com/ahuigo/homebrew-ahui/blob/master/langdao-dict.rb

     brew install ahuigo/ahui/langdao-dict
     brew install --verbose --debug ahuigo/ahui/langdao-dict

## OS 环境
参考： https://github.com/jkawamoto/homebrew-fgo/blob/master/fgo.rb

    require 'rbconfig'
    class Fgo < Formula
      if Hardware::CPU.is_64_bit?
        case RbConfig::CONFIG['host_os']
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        when /darwin|mac os/
          url "https://github.com/jkawamoto/fgo/releases/download/v0.3.4/fgo_v0.3.4_darwin_amd64.zip"
        when /linux/
          url "https://github.com/jkawamoto/fgo/releases/download/v0.3.4/fgo_v0.3.4_linux_amd64.tar.gz"
        when /solaris|bsd/
          :unix
        else
          :unknown
        end
      else


# install
## install golang
参考：https://gist.github.com/miguelmota/33489af6d1655188869f3698020354c3

## install dir
dir:

    brew --repo
        /usr/local/Homebrew
    brew --cache
        ~/Library/Caches/Homebrew/downloads
