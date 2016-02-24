# use http://mirrors.ustc.edu.cn/openwrt/ instead of http://downloads.openwrt.org in opkg cfg (/etc/opkg/) to improve speed
opkg update
# for usb devices 
opkg install kmod-usb-storage 
# for fstab mount and ext4 file system
opkg install block-mount kmod-fs-ext4
# to use ext disk for software storage
# mount /dev/sda1 /overlay
# for ntfs file system
opkg install ntfs-3g samba luci-app-samba

opkg install iptables-mod-nat-extra

opkg install pdnsd
# or consider using dnscrypt-proxy, edit /etc/config/dnscrypt-proxy after installation

opkg install libpolarssl
# download shadowsocks from: https://github.com/shadowsocks/openwrt-shadowsocks
# update /etc/shadowsocks/config.json accordingly

/etc/init.d/pdnsd enable
/etc/init.d/shadowsocks enable
