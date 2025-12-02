# Corrupted Filesystem Kubernetes Mount

A Kubernetes setup to load and mount corrupted ext4 filesystem images from the [e2fsprogs test suite](https://github.com/tytso/e2fsprogs/tree/master/tests) for debugging/testing purposes (e.g., with tools like `e2fsck` or `debugfs`). Uses a custom Docker image to load the image, a Job to write to a block-mode PVC, a script to switch to filesystem-mode, and a Pod for inspection.

## Prerequisites
- Local Kubernetes cluster (e.g., Minikube, Kind).
- Docker for building/pushing images.
- `kubectl` installed and configured.
- StorageClass with `reclaimPolicy: Retain`.

## Usage
1. **Select the corrupted**
   - Adjust the [job/load-corrupted-image-job](deployment/prepare-pv-job.yaml) to select image with the corruption to test.
   - The default is `/test.img` which is a clean test.
   - For example, to test the bad directory set `spec.templates.spec.containers[0].args` to `/e2fsprogs-master/tests/f_baddir/image`

2. **Run a test**
   - Running a test means to prepare a PVC/PV in block mode, load the corrupted fs, and switch to filesystem mode.
   - Because a lot of the PVC/PV fields are immutable a `make test` will run all the steps involved.

## Notes
- Volume mode switching reuses data via `Retain` policy.
- Risky for corrupted FS (kernel issues); test isolated.
- Adjust paths/files for different `.img`.
- Cleanup: Delete PVC/PV, Pods, Jobs, and host dirs.

For issues, check logs or adjust for your cluster.