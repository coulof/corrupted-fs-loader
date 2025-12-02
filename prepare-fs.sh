#!/bin/bash
TEST_NAME="f_baddir"
curl -LO https://github.com/tytso/e2fsprogs/raw/refs/heads/master/tests/f_baddir/image.gz

gunzip image.gz
mv image image_f_baddir.img