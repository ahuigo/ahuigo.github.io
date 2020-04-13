version?=0.1.0
base_image=artifactory.ahuigo.works/ahuiporj
image_name=ahuiproj
test:
	echoraw registry.ahuigo.works/hd_map/$(image_name):$(version)

image:
	echoraw $(version)
	docker image build -t $(image_name):$(version) . -f dockerfile-alpine
	#docker tag $(image_name):$(version) registry.ahuigo.works/hd_map/$(image_name):$(version)
push:
	docker push $(image_name):$(version)
run:
	docker run --rm -p 8005:8000 -p 3000:3000 $(image_name):$(version)
