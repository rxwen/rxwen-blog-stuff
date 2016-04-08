#!/bin/sh

if [ -b /dev/sda1 ]; then
  mkdir -p /mnt/data
  mount -t ext4 /dev/sda1 /mnt/data
  btsync --nodaemon --webui.listen 0.0.0.0:80
fi
