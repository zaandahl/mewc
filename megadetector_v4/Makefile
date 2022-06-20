# https://blog.container-solutions.com/tagging-docker-images-the-right-way
FILE := megadetector_v4
NAME := zaandahl/${FILE}
TAG    := $(shell git log -1 --pretty=%h)
IMG    := ${NAME}:${TAG}
LATEST := ${NAME}:latest

build:
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}

all: build

push:
	@docker push ${NAME}

export:
	docker save ${LATEST} > $(FILE).tar

load:
	docker load < $(FILE).tar

.PHONY: all build