---
title: Shell make
date: 2019-05-06
private:
---
# Shell make
    $ make test FLAG=debug

然后

    FLAG?=default_value
    test:
        echo $(FLAG)


image example

    version?=0.0.2
    image:
        echoraw $(version)
        docker image build -t slim_nginx:$(version) .
        docker tag slim_nginx:$(version) registry.docker.com/slim_nginx/slim_nginx:$(version)

    push:
        docker push registry.docker.com/slim_nginx/slim_nginx:$(version)

    test:
        echo $(version)

