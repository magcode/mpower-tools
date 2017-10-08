#!/bin/sh
#

mkdir /etc/persistent/mqtt
wget --no-check-certificate https://github.com/magcode/mpower-tools/blob/master/mqtt/libmosquitto.so.1?raw=true -O /etc/persistent/mqtt/libmosquitto.so.1
wget --no-check-certificate https://github.com/magcode/mpower-tools/blob/master/mqtt/mosquitto_pub?raw=true -O /etc/persistent/mqtt/mosquitto_pub
wget --no-check-certificate https://github.com/magcode/mpower-tools/blob/master/mqtt/mosquitto_sub?raw=true -O /etc/persistent/mqtt/mosquitto_sub
wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/mqpub.sh -O /etc/persistent/mqtt/mqpub.sh


chmod 755 /etc/persistent/mqtt/mosquitto_pub
chmod 755 /etc/persistent/mqtt/mosquitto_sub
chmod 755 /etc/persistent/mqtt/mqpub.sh
