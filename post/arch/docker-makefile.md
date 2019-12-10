---
title: docker makefile
date: 2019-11-07
private: 
---
# docker makefile
version?=0.3.0
image:
	echoraw $(version)
	#docker build -t blog:$(version) .
	docker image build -t blog:$(version) .
	docker tag blog:$(version) registry.ahuigo.com/ahuigo/blog:$(version)

push:
	docker push registry.ahuigo.com/ahuigo/blog:$(version)


test-docker:
	echo $(version)
	docker run --rm --dns=100.127.255.5 -e ENV_MODE=dev -v `pwd`/packages:/tmp/data registry.ahuigo.com/ahuigo/blog:${version}