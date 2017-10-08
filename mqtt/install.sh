#!/bin/sh
#

wget --no-check-certificate https://github.com/magcode/mpower-tools/blob/master/mqtt/libmosquitto.so.1?raw=true -O /var/etc/persistent/mqtt/libmosquitto.so.1
wget --no-check-certificate https://github.com/magcode/mpower-tools/blob/master/mqtt/mosquitto_pub?raw=true -O /var/etc/persistent/mqtt/mosquitto_pub
wget --no-check-certificate https://github.com/magcode/mpower-tools/blob/master/mqtt/mosquitto_sub?raw=true -O /var/etc/persistent/mqtt/mosquitto_sub
wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/mqpub.sh -O /var/etc/persistent/mqtt/mqpub.sh
wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/mqsub.sh -O /var/etc/persistent/mqtt/mqsub.sh

chmod 755 /var/etc/persistent/mqtt/mosquitto_pub
chmod 755 /var/etc/persistent/mqtt/mosquitto_sub
chmod 755 /var/etc/persistent/mqtt/mqpub.sh
chmod 755 /var/etc/persistent/mqtt/mqsub.sh