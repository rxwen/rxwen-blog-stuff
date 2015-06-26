opkg update
# for usb devices 
opkg install kmod-usb-storage 
# for fstab mount and ext4 file system
opkg install block-mount kmod-fs-ext4
# to use ext disk for software storage
# mount /dev/sda1 /overlay
# for ntfs file system
opkg install ntfs-3g samba luci-app-samba

opkg install pdnsd

# download shadowsocks from: https://github.com/shadowsocks/openwrt-shadowsocks
# update /etc/shadowsocks/config.json accordingly

/etc/init.d/pdnsd enable
/etc/init.d/shadowsocks enable
