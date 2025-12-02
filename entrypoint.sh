#!/bin/sh
echo "Starting to load image /image_f_baddir.img to /dev/block-device"
dd if=/image_f_baddir.img of=/dev/block-device bs=1M
echo "Image loaded successfully"
