#!/bin/sh

LOCALDIR="/var/etc/persistent/mqtt"
LOCALSCRIPTDIR=$LOCALDIR/v2
BASEURL="https://github.com/magcode/mpower-tools/blob/master/mqtt"

echo "Installing mPower MQTT v2 ..."
wget --no-check-certificate -q $BASEURL/libmosquitto.so.1?raw=true -O $LOCALDIR/libmosquitto.so.1
wget --no-check-certificate -q $BASEURL/mosquitto_pub?raw=true -O $LOCALDIR/mosquitto_pub
wget --no-check-certificate -q $BASEURL/mosquitto_sub?raw=true -O $LOCALDIR/mosquitto_sub
mkdir -p $LOCALSCRIPTDIR
rm $LOCALSCRIPTDIR/*
wget --no-check-certificate -q $BASEURL/v2/mqrunv2.sh -O $LOCALSCRIPTDIR/mqrunv2.sh
wget --no-check-certificate -q $BASEURL/v2/mqpubv2-static.sh -O $LOCALSCRIPTDIR/mqpubv2-static.sh
wget --no-check-certificate -q $BASEURL/v2/mqpubv2.sh -O $LOCALSCRIPTDIR/mqpubv2.sh
wget --no-check-certificate -q $BASEURL/v2/mpower-pub.cfg -O $LOCALSCRIPTDIR/mpower-pub.cfg

#wget --no-check-certificate -q https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/mqsub.sh -O /var/etc/persistent/mqtt/mqsub.sh

chmod 755 $LOCALDIR/mosquitto_pub
chmod 755 $LOCALDIR/mosquitto_sub
chmod 755 $LOCALSCRIPTDIR/mqrunv2.sh
chmod 755 $LOCALSCRIPTDIR/mqpubv2-static.sh
chmod 755 $LOCALSCRIPTDIR/mqpubv2.sh
chmod 755 $LOCALSCRIPTDIR/mpower-pub.cfg
echo "Done!"