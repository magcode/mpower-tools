#!/bin/sh

TARGET="$1"
if [ -z "$TARGET" ]; then
    echo "Usage: $0 <TARGET>"
    exit 1
fi

WORK_DIR=`mktemp -d -p "$DIR"`

LOCALDIR="/var/etc/persistent/mqtt"
LOCALSCRIPTDIR=$LOCALDIR/client
BASEURL="https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt"
SSH_PARAMS="-o PubkeyAcceptedKeyTypes=+ssh-rsa -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss -o Ciphers=+aes256-cbc -o StrictHostKeyChecking=accept-new"   
SCP_PARAMS="-O $SSH_PARAMS"

echo "Installing mPower MQTT v2 ... to $TARGET"
wget --no-check-certificate -q $BASEURL/libmosquitto.so.1?raw=true -O $WORK_DIR/libmosquitto.so.1
wget --no-check-certificate -q $BASEURL/mosquitto_pub?raw=true -O $WORK_DIR/mosquitto_pub
wget --no-check-certificate -q $BASEURL/mosquitto_sub?raw=true -O $WORK_DIR/mosquitto_sub


scp $SCP_PARAMS $WORK_DIR/libmosquitto.so.1 ubnt@$TARGET:$LOCALDIR
scp $SCP_PARAMS $WORK_DIR/mosquitto_pub ubnt@$TARGET:$LOCALDIR
scp $SCP_PARAMS $WORK_DIR/mosquitto_sub ubnt@$TARGET:$LOCALDIR

ssh $SSH_PARAMS ubnt@$TARGET "mkdir -p $LOCALSCRIPTDIR"
# clean directory, but leave *.cfg files untouched
ssh $SSH_PARAMS ubnt@$TARGET "find $LOCALSCRIPTDIR ! -name '*.cfg' -type f -exec rm -f '{}' \;"

wget --no-check-certificate -q $BASEURL/client/mqrun.sh -O $WORK_DIR/mqrun.sh
wget --no-check-certificate -q $BASEURL/client/mqpub-static.sh -O $WORK_DIR/mqpub-static.sh
wget --no-check-certificate -q $BASEURL/client/mqpub.sh -O $WORK_DIR/mqpub.sh
wget --no-check-certificate -q $BASEURL/client/mqsub.sh -O $WORK_DIR/mqsub.sh
wget --no-check-certificate -q $BASEURL/client/mqstop.sh -O $WORK_DIR/mqstop.sh

scp $SCP_PARAMS $WORK_DIR/mqrun.sh ubnt@$TARGET:$LOCALSCRIPTDIR
scp $SCP_PARAMS $WORK_DIR/mqpub-static.sh ubnt@$TARGET:$LOCALSCRIPTDIR
scp $SCP_PARAMS $WORK_DIR/mqpub.sh ubnt@$TARGET:$LOCALSCRIPTDIR
scp $SCP_PARAMS $WORK_DIR/mqsub.sh ubnt@$TARGET:$LOCALSCRIPTDIR
scp $SCP_PARAMS $WORK_DIR/mqstop.sh ubnt@$TARGET:$LOCALSCRIPTDIR


wget --no-check-certificate -q $BASEURL/client/mpower-pub.cfg -O $WORK_DIR/mpower-pub.cfg
wget --no-check-certificate -q $BASEURL/client/mqtt.cfg -O $WORK_DIR/mqtt.cfg
wget --no-check-certificate -q $BASEURL/client/led.cfg -O $WORK_DIR/led.cfg

if ssh $SSH_PARAMS ubnt@$TARGET "test -f '$LOCALSCRIPTDIR/mpower-pub.cfg'" 2>/dev/null; then
    echo "mpower-pub.cfg exists, not touching"
else
    scp $SCP_PARAMS $WORK_DIR/mpower-pub.cfg ubnt@$TARGET:$LOCALSCRIPTDIR
fi

if ssh $SSH_PARAMS ubnt@$TARGET "test -f '$LOCALSCRIPTDIR/led.cfg'" 2>/dev/null; then
    echo "led.cfg exists, not touching"
else
    scp $SCP_PARAMS $WORK_DIR/led.cfg ubnt@$TARGET:$LOCALSCRIPTDIR
fi

if ssh $SSH_PARAMS ubnt@$TARGET "test -f '$LOCALSCRIPTDIR/mqtt.cfg'" 2>/dev/null; then
    echo "mqtt.cfg exists, not touching"
else
    scp $SCP_PARAMS $WORK_DIR/mqtt.cfg ubnt@$TARGET:$LOCALSCRIPTDIR
fi

ssh $SSH_PARAMS ubnt@$TARGET "chmod 755 $LOCALDIR/mosquitto_pub $LOCALDIR/mosquitto_sub $LOCALSCRIPTDIR/mqrun.sh $LOCALSCRIPTDIR/mqpub-static.sh $LOCALSCRIPTDIR/mqpub.sh $LOCALSCRIPTDIR/mqsub.sh $LOCALSCRIPTDIR/mqstop.sh"


poststart=/etc/persistent/rc.poststart
startscript="sleep 10; $LOCALSCRIPTDIR/mqrun.sh"


# create poststart file if not exists

if ssh $SSH_PARAMS ubnt@$TARGET "test -f '$poststart'" 2>/dev/null; then
    echo "$poststart exists already"
else
    echo "$poststart not found, creating it ..."
    ssh $SSH_PARAMS ubnt@$TARGET "echo '#!/bin/sh' >> $poststart"
    ssh $SSH_PARAMS ubnt@$TARGET "chmod 755 $poststart"
fi

# add entry to poststart file if not exists
if ssh $SSH_PARAMS ubnt@$TARGET "grep -q '$startscript' '$poststart'" 2>/dev/null; then
    echo "Found startscript entry. File will not be changed"
else
    echo "Adding start command to $poststart"
    ssh $SSH_PARAMS ubnt@$TARGET "echo -e '$startscript' >> $poststart"
fi


echo "Done!"
echo "Please configure mqtt.cfg"
echo "Please configure mpower-pub.cfg"
echo "Please configure led.cfg"
echo "run 'save' command on $TARGET if you are done."