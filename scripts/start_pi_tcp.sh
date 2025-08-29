#!/usr/bin/env bash
set -euo pipefail
# 隞?TCP 8554 ?冽? 1280x720@30fps嚗??瘙矽??
libcamera-vid -t 0 --inline --codec h264 \
  --width 1280 --height 720 --framerate 30 \
  --listen -o tcp://0.0.0.0:8554
