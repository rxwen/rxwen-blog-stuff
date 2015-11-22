To mount additional usb devices to file system, add below contents to /etc/rc.local

'''
if [ -b /dev/sda2 ]; then
  mkdir -p /mnt/ext
  mount -t ext4 /dev/sda2 /mnt/ext
  mount -t ext4 /dev/sda2 /overlay
fi
'''

Make sure required file systems are installed via opkg


## Installation for normal openwrt router

- run setup.sh

## Installation for dir-505 openwrt router

- refer to readme_for_dir-505.md
