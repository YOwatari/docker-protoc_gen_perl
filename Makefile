.PHONY: build push

PERL_VERSION     := 5.28.0
PROTOBUF_VERSION := 3.5.1

DOCKER_IMAGE_NAME := yowatari/protoc_gen_perl:$(PERL_VERSION)

# see https://metacpan.org/pod/distribution/Google-ProtocolBuffers-Dynamic/scripts/protoc-gen-perl-gpd
run: person.proto
	mkdir -p lib
	docker run --rm -v $(CURDIR):/tmp -w /tmp $(DOCKER_IMAGE_NAME) --perl-gpd_out=package=Humans.Person:lib $<

build: Dockerfile
	docker build \
    --build-arg PERL_VERSION=$(PERL_VERSION) \
    --build-arg PROTOBUF_VERSION=$(PROTOBUF_VERSION) \
    -t $(DOCKER_IMAGE_NAME) .

push: build
	docker push $(DOCKER_IMAGE_NAME)

