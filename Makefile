include .env.local
.PHONY: release_prod release_stage

CONTAINER_NAME := mongodb-heartbeat
REGISTRY := 539110858215.dkr.ecr.ap-northeast-1.amazonaws.com
IMAGE := $(REGISTRY)/$(CONTAINER_NAME)

VER := 0.0.3
RELEASE_DIR := release
AWS_PROFILE ?= default
AWS_REGION := ap-northeast-1

SRC := $(shell find src -name \*.py)

release_prod: .build
	cd $(RELEASE_DIR) && ansible-playbook -i inventory/prod.yaml \
		-e REGISTRY=$(REGISTRY) -e CONTAINER_NAME=$(CONTAINER_NAME) -e IMAGE_TAG=$(VER) \
		-e AWS_REGION=$(AWS_REGION) \
		site.yaml

release_stage: .build
	cd $(RELEASE_DIR) && ansible-playbook -i inventory/stage.yaml \
		-e REGISTRY=$(REGISTRY) -e CONTAINER_NAME=$(CONTAINER_NAME) -e IMAGE_TAG=$(VER) \
		-e AWS_REGION=$(AWS_REGION) \
		site.yaml

.build: $(SRC) Dockerfile Makefile
	pipenv run ./build.sh $(CONTAINER_NAME):$(VER) $(REGISTRY) $(AWS_PROFILE)
	echo $(VER) > .build
