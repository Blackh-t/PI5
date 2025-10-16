#!/bin/bash

cd /home/yoshi/git/PI5/dev/webhook
BUILD_OUTPUT=$(cargo build --release 2>&1)
echo "$BUILD_OUTPUT"

cd
