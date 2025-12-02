#!/bin/sh
echo "Starting to load image $1 to /dev/block-device"
dd if=/$1 of=/dev/block-device bs=1M
echo "Image loaded successfully"
