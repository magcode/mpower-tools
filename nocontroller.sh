#!/bin/sh
#

sed 's/pkill -9 mcad/exit 0\n        pkill -9 mcad/;s/pkill -9 wpa_supplicant/exit 0\n        pkill -9 wpa_supplicant/' /usr/etc/syswrapper.sh > /etc/persistent/syswrapper.sh
chmod 755 /etc/persistent/syswrapper.sh
wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/rc.poststart -O /etc/persistent/rc.poststart
chmod 755 /etc/persistent/rc.poststart