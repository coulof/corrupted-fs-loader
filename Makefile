# Makefile to build and push the container
REGISTRY ?= quay.io
IMAGE ?= coulof/corrupted-fs-loader
TAG ?= latest
DOCKER ?= podman
KUBECTL ?= kubectl
PVC_NAME ?= corrupted-fs-pvc

REPO := $(REGISTRY)/$(IMAGE)
FULL := $(REPO):$(TAG)

.PHONY: all build push login clean info test

all: build push

build:
	$(DOCKER) build -t $(FULL) .

push:
	$(DOCKER) push $(FULL)

login:
	@echo "Run: $(DOCKER) login $(REGISTRY)"

clean:
	-@$(DOCKER) rmi $(FULL) || true

test:
	$(KUBECTL) create -f deployment/prepare-pv-job.yaml
	$(KUBECTL) wait --for=condition=complete --timeout=30m job/load-corrupted-image-job
	$(KUBECTL) delete job/load-corrupted-image-job
	./switch_pv_volume_mode.sh
	$(KUBECTL) wait --for=jsonpath='{.status.phase}'=Bound pvc/$(PVC_NAME) --timeout=300s
	$(KUBECTL) create -f deployment/run-corrupted-fs.yaml

info:
	@echo "Registry: $(REGISTRY)"
	@echo "Image:    $(IMAGE)"
	@echo "Tag:      $(TAG)"
	@echo "Full:     $(FULL)"