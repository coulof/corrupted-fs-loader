#!/bin/bash
kubectl create -f deployment/prepare-pv-job.yaml
# wait for the pod to complete
kubectl wait --for=condition=complete --timeout=30m job/load-corrupted-image-job