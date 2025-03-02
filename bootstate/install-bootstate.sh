#!/bin/sh
#

TARGET="$1"
if [ -z "$TARGET" ]; then
    echo "Usage: $0 <TARGET>"
    exit 1
fi

echo "Installing mPower bootstate ... to $TARGET"

WORK_DIR=`mktemp -d -p "$DIR"`
SSH_PARAMS="-o PubkeyAcceptedKeyTypes=+ssh-rsa -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss -o Ciphers=+aes256-cbc -o StrictHostKeyChecking=accept-new"   
SCP_PARAMS="$SSH_PARAMS"

scriptdir=/var/etc/persistent/bootstate
applyscript="$scriptdir/apply-bootstate.sh"

ssh $SSH_PARAMS ubnt@$TARGET "mkdir -p $scriptdir"
wget -q https://raw.githubusercontent.com/magcode/mpower-tools/master/bootstate/apply-bootstate.sh -O $WORK_DIR/apply-bootstate.sh
scp $SCP_PARAMS $WORK_DIR/apply-bootstate.sh ubnt@$TARGET:$scriptdir
ssh $SSH_PARAMS ubnt@$TARGET "chmod 755 $applyscript"

config="$scriptdir/bootstate.cfg"



if ssh $SSH_PARAMS ubnt@$TARGET "test -f '$config'" 2>/dev/null; then
    echo "$config exists, not touching"
else
    PORTS=`ssh $SSH_PARAMS ubnt@$TARGET "cat /etc/board.inc | grep feature_power | sed -e 's/.*\([0-9]\+\);/\1/'" 2>/dev/null`
    echo "Found $PORTS ports"

    ssh $SSH_PARAMS ubnt@$TARGET "touch $config"
    for i in $(seq $PORTS)
    do
        ssh $SSH_PARAMS ubnt@$TARGET "echo 'vpower.$i.relay=on' >> $config"
    done
    echo "Config file created: $config"
fi



poststart=/etc/persistent/rc.poststart
poststartscript="sleep 60; $applyscript"


# create poststart file if not exists

if ssh $SSH_PARAMS ubnt@$TARGET "test -f '$poststart'" 2>/dev/null; then
    echo "$poststart exists already"
else
    echo "$poststart not found, creating it ..."
    ssh $SSH_PARAMS ubnt@$TARGET "echo '#!/bin/sh' >> $poststart"
    ssh $SSH_PARAMS ubnt@$TARGET "chmod 755 $poststart"
fi

# add entry to poststart file if not exists
if ssh $SSH_PARAMS ubnt@$TARGET "grep -q '$poststartscript' '$poststart'" 2>/dev/null; then
    echo "Found startscript entry. File will not be changed"
else
    echo "Adding start command to $poststart"
    ssh $SSH_PARAMS ubnt@$TARGET "echo -e '$poststartscript' >> $poststart"
fi

ssh $SSH_PARAMS ubnt@$TARGET "cfgmtd -w -p /etc/"

echo "Adapt your settings in '$config' and call '$applyscript' afterwards."
