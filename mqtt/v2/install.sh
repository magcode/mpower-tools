#!/bin/sh
#
LOCALDIR="/var/etc/persistent/mqtt"
LOCALSCRIPTDIR=$LOCALDIR/v2
BASEURL="https://github.com/magcode/mpower-tools/blob/master/mqtt"

echo "Installing mPower MQTT v2..."
wget --no-check-certificate -q $BASEURL/libmosquitto.so.1?raw=true -O $LOCALDIR/libmosquitto.so.1
wget --no-check-certificate -q $BASEURL/mosquitto_pub?raw=true -O $LOCALDIR/mosquitto_pub
wget --no-check-certificate -q $BASEURL/mosquitto_sub?raw=true -O $LOCALDIR/mosquitto_sub
rm $LOCALDIR/*
wget --no-check-certificate -q $BASEURL/v2/mqrun.sh -O $LOCALSCRIPTDIR/mqrun.sh
wget --no-check-certificate -q $BASEURL/v2/mqpub2-static.sh -O $LOCALSCRIPTDIR/mqpub2-static.sh
wget --no-check-certificate -q $BASEURL/v2/mqpub2.sh -O $LOCALSCRIPTDIR/mqpub2.sh
wget --no-check-certificate -q $BASEURL/v2/mpower-pub.cfg -O $LOCALSCRIPTDIR/mpower-pub.cfg

#wget --no-check-certificate -q https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/mqsub.sh -O /var/etc/persistent/mqtt/mqsub.sh

chmod 755 /var/etc/persistent/mqtt/mosquitto_pub
chmod 755 /var/etc/persistent/mqtt/mosquitto_sub
chmod 755 $LOCALSCRIPTDIR/mqrun.sh
chmod 755 $LOCALSCRIPTDIR/mqpub2-static.sh
chmod 755 $LOCALSCRIPTDIR/mqpub2.sh
chmod 755 $LOCALSCRIPTDIR/mpower-pub.cfg
echo "Done!"