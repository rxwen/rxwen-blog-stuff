the default wan interface for dir-505 is eth1, so when we want to use pdnsd as dns cache, do remeber to change the interface=eth0 to interface=eth1 in pdnsd.conf file.
and the dns for dnsmasq doesn't work, so it's a better idea to forward dns query to pdnsd by adding 'server=127.0.0.1#1053' in dnsmasq.conf
