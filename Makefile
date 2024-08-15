.PHONY: release

CONTAINER_NAME := mongodb-heatbeat
REGISTRY := docker.home.sarlos.jp
IMAGE := $(REGISTRY)/$(CONTAINER_NAME)

VER := 0.0.1
RELEASE_DIR := release

SRC := $(shell find src -name \*.py)

release: .build
	cd $(RELEASE_DIR) && ansible-playbook -i inventory/prod.yaml \
		-e REGISTRY=$(REGISTRY) -e CONTAINER_NAME=$(CONTAINER_NAME) -e IMAGE_TAG=$(VER) \
		site.yaml

.build: $(SRC) Dockerfile Makefile
	docker buildx build --push --platform linux/amd64 -t $(IMAGE):$(VER) --progress plain .
	echo $(VER) > .build
