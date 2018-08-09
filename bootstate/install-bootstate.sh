#!/bin/sh
#
echo "Installing bootstate ..."

scriptdir=/var/etc/persistent/bootstate

mkdir -p $scriptdir
config="$scriptdir/bootstate.cfg"
applyscript="$scriptdir/apply-bootstate.sh"
poststartscript="sleep 60; $applyscript"
poststart=/etc/persistent/rc.poststart

wget --no-check-certificate -q https://raw.githubusercontent.com/magcode/mpower-tools/master/bootstate/apply-bootstate.sh -O $applyscript
chmod 775 $applyscript

if [ ! -f $config ]; then
    echo "$config not found, creating it ..."
    export PORTS=`cat /etc/board.inc | grep feature_power | sed -e 's/.*\([0-9]\+\);/\1/'`
    touch $config
    for i in $(seq $PORTS)
    do
        echo "vpower.$i.relay=on" >> $config
    done
fi

if [ ! -f $poststart ]; then
    echo "$poststart not found, creating it ..."
    touch $poststart
    echo "#!/bin/sh" >> $poststart
    chmod 755 $poststart
fi

if grep -q "$poststartscript" "$poststart"; then
   echo "Found $poststart entry. File will not be changed"
else
   echo "Adding start command to $poststart"
   echo "$poststartscript" >> $poststart
fi

echo "Done!"
cfgmtd -w -p /etc/
echo "Adapt your settings in '$config' and call '$applyscript' afterwards."