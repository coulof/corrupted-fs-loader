#!/bin/bash

# Variables (customize these)
PVC_NAME="corrupted-fs-pvc"

OLD_VOL_MODE="Block"    # Current mode (e.g., "Block")
NEW_VOL_MODE="Filesystem"  # Target mode (e.g., "Filesystem")

PV_NAME=$(kubectl get pvc $PVC_NAME -o jsonpath='{.spec.volumeName}')

echo "Starting volumeMode switch from $OLD_VOL_MODE to $NEW_VOL_MODE for PV: $PV_NAME, PVC: $PVC_NAME"

# Step 1: Backup current PVC and PV YAMLs
kubectl get pvc $PVC_NAME -o yaml | kubectl-neat > pvc_backup.yaml
kubectl get pv $PV_NAME -o yaml | kubectl-neat |  yq 'del(.spec.claimRef) | .spec.volumeMode = "Filesystem"' > pv_backup.yaml

echo "Backups saved: pvc_backup.yaml, pv_backup.yaml"

# Step 2: Edit the YAMLs to substitute volumeMode (and path if needed)
sed -i "s/volumeMode: $OLD_VOL_MODE/volumeMode: $NEW_VOL_MODE/g" pvc_backup.yaml

echo "YAMLs updated with new volumeMode and path"

# Step 3: Delete the PVC and PV (order matters: PVC first to unbind, then PV)
kubectl delete pvc $PVC_NAME --ignore-not-found=true
kubectl wait --for=delete pvc/$PVC_NAME --timeout=60s
kubectl delete pv $PV_NAME --ignore-not-found=true
kubectl wait --for=delete pv/$PV_NAME --timeout=60s
echo "PVC and PV deleted"

# Step 4: Create them again with the edited YAMLs (PV first, then PVC for binding)
kubectl apply -f pv_backup.yaml
kubectl apply -f pvc_backup.yaml
kubectl wait --for=jsonpath='{.status.phase}'=Bound pv/$PV_NAME --timeout=60s
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/$PVC_NAME --timeout=60s
echo "PVC and PV recreated and bound with new volumeMode: $NEW_VOL_MODE"

# Cleanup hints
echo "Cleanup: rm pvc_backup.yaml pv_backup.yaml"
echo "Now create a Pod to mount the PVC $PVC_NAME in volumeMode: $NEW_VOL_MODE)"