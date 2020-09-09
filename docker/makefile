version?=0.1.0
image_name=alpine1
f?=dockerfile-alpine
test:
	echoraw registry.ahuigo.works/hd_map/$(image_name):$(version)
image:
	echoraw $(version)
	docker image build -t $(image_name) . -f ${f}
	#docker tag $(image_name):$(version) registry.ahuigo.works/hd_map/$(image_name):$(version)
push:
	docker push $(image_name)
run:
	docker run --rm --name $(image_name) $(image_name)
run1:
	docker run --rm -p 8005:8000 -p 3000:3000 $(image_name):$(version)


jre-test-build:
	docker build -t jre-test -f dockerfile-jre-test .
jre-test:
	docker run --rm --entrypoint="/bin/sh" --name jre-test jre-test

