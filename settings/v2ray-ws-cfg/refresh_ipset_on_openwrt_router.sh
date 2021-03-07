#!/bin/sh

#curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /root/chnroute.txt
#curl http://www.ipdeny.com/ipblocks/data/countries/cn.zone > /root/chnroute.txt
#echo "add apple ip range"
## https://support.apple.com/en-us/HT210060
#echo "17.0.0.0/8" >> /root/chnroute.txt
# nslookup seattle.showmethemoney.top | grep "Address 1" | awk '{ print $3 }'
# nslookup sv.showmethemoney.top | grep "Address 1" | awk '{ print $3 }'

ipset destroy chnroute
#ipset -N chnroute hash:net maxelem 65536

for ip in $(cat '/root/chnroute.txt'); do
    ipset add chnroute $ip
done

/etc/init.d/firewall restart
