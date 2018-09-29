#!/bin/sh

LOCALDIR="/var/etc/persistent/mqtt"
LOCALSCRIPTDIR=$LOCALDIR/client
BASEURL="https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt"

echo "Installing mPower MQTT v2 ..."
wget --no-check-certificate -q $BASEURL/libmosquitto.so.1?raw=true -O $LOCALDIR/libmosquitto.so.1
wget --no-check-certificate -q $BASEURL/mosquitto_pub?raw=true -O $LOCALDIR/mosquitto_pub
wget --no-check-certificate -q $BASEURL/mosquitto_sub?raw=true -O $LOCALDIR/mosquitto_sub
mkdir -p $LOCALSCRIPTDIR
# clean directory, but leave *.cfg files untouched
find $LOCALSCRIPTDIR ! -name '*.cfg' -type f -exec rm -f '{}' \;
wget --no-check-certificate -q $BASEURL/client/mqrun.sh -O $LOCALSCRIPTDIR/mqrun.sh
wget --no-check-certificate -q $BASEURL/client/mqpub-static.sh -O $LOCALSCRIPTDIR/mqpub-static.sh
wget --no-check-certificate -q $BASEURL/client/mqpub.sh -O $LOCALSCRIPTDIR/mqpub.sh
wget --no-check-certificate -q $BASEURL/client/mqsub.sh -O $LOCALSCRIPTDIR/mqsub.sh
wget --no-check-certificate -q $BASEURL/client/mqstop.sh -O $LOCALSCRIPTDIR/mqstop.sh

if [ ! -f $LOCALSCRIPTDIR/mpower-pub.cfg ]; then
    wget --no-check-certificate -q $BASEURL/client/mpower-pub.cfg -O $LOCALSCRIPTDIR/mpower-pub.cfg
fi

if [ ! -f $LOCALSCRIPTDIR/mqtt.cfg ]; then
    wget --no-check-certificate -q $BASEURL/client/mqtt.cfg -O $LOCALSCRIPTDIR/mqtt.cfg
fi

if [ ! -f $LOCALSCRIPTDIR/led.cfg ]; then
    wget --no-check-certificate -q $BASEURL/client/led.cfg -O $LOCALSCRIPTDIR/led.cfg
fi

chmod 755 $LOCALDIR/mosquitto_pub
chmod 755 $LOCALDIR/mosquitto_sub
chmod 755 $LOCALSCRIPTDIR/mqrun.sh
chmod 755 $LOCALSCRIPTDIR/mqpub-static.sh
chmod 755 $LOCALSCRIPTDIR/mqpub.sh
chmod 755 $LOCALSCRIPTDIR/mqsub.sh
chmod 755 $LOCALSCRIPTDIR/mqstop.sh

poststart=/etc/persistent/rc.poststart
startscript="sleep 10; $LOCALSCRIPTDIR/mqrun.sh"
 
if [ ! -f $poststart ]; then
    echo "$poststart not found, creating it ..."
    touch $poststart
    echo "#!/bin/sh" >> $poststart
    chmod 755 $poststart
fi
 
if grep -q "$startscript" "$poststart"; then
   echo "Found $poststart entry. File will not be changed"
else
   echo "Adding start command to $poststart"
   echo -e "$startscript" >> $poststart
fi
 
echo "Done!"
echo "Please configure mqtt.cfg"
echo "Please configure mpower-pub.cfg"
echo "run 'save' command if done."