# Makefile to build and push the container
REGISTRY ?= quay.io
IMAGE ?= coulof/corrupted-fs-loader
TAG ?= latest
DOCKER ?= podman

REPO := $(REGISTRY)/$(IMAGE)
FULL := $(REPO):$(TAG)

.PHONY: all build push login clean info

all: build push

build:
	$(DOCKER) build -t $(FULL) .

push:
	$(DOCKER) push $(FULL)

login:
	@echo "Run: $(DOCKER) login $(REGISTRY)"

clean:
	-@$(DOCKER) rmi $(FULL) || true

info:
	@echo "Registry: $(REGISTRY)"
	@echo "Image:    $(IMAGE)"
	@echo "Tag:      $(TAG)"
	@echo "Full:     $(FULL)"