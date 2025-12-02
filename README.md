# Corrupted Filesystem Kubernetes Mount

A Kubernetes setup to load and mount corrupted ext4 filesystem images from the [e2fsprogs test suite](https://github.com/tytso/e2fsprogs/tree/master/tests) for debugging/testing purposes (e.g., with tools like `e2fsck` or `debugfs`). Uses a custom Docker image to load the image, a Job to write to a block-mode PVC, a script to switch to filesystem-mode, and a Pod for inspection.

## Prerequisites
- Local Kubernetes cluster (e.g., Minikube, Kind).
- Docker for building/pushing images.
- `kubectl` installed and configured.
- StorageClass with `reclaimPolicy: Retain`.

## Usage
0. **Select the corrupted**
   - Adjust the `Dockerfile` for the test (default `f_baddir`)
1. **Build the Loader Image**:
   - Build and push: `make all`

2. **Deploy Block-Mode PVC/PV and Job**:
   - Apply the PVC/PV YAML (`kubectl apply -f pv-pvc-job.yaml`).
   - Wait for Job completion: `kubectl wait --for=condition=complete job/load-corrupted-image-job`.

3. **Switch to Filesystem Mode**:
   - Run the script `switch_pv_volume_mode.sh` (sets `OLD_VOL_MODE=Block`, `NEW_VOL_MODE=Filesystem`).
   - Ensure extracted data is in `/mnt/corrupted_extracted` (run extraction Job separately if needed).

4. **Mount in Pod**:
   - Apply Pod YAML to mount at `/mnt/corrupted` (e.g., `kubectl apply -f pod.yaml`).
   - Inspect: `kubectl exec -it sleep-corrupted-pod -- sh` and explore `/mnt/corrupted`.


## Notes
- Volume mode switching reuses data via `Retain` policy.
- Risky for corrupted FS (kernel issues); test isolated.
- Adjust paths/files for different `.img`.
- Cleanup: Delete PVC/PV, Pods, Jobs, and host dirs.

For issues, check logs or adjust for your cluster.