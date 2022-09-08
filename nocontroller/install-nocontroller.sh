#!/bin/sh
#
echo "Installing nocontroller ..."

scriptdir=/var/etc/persistent/nocontroller

mkdir -p $scriptdir

# in case already installed, we need to unmount first
umount /usr/etc/syswrapper.sh
sed 's/pkill -9 mcad/exit 0\n        pkill -9 mcad/;s/pkill -9 wpa_supplicant/exit 0\n        pkill -9 wpa_supplicant/' /usr/etc/syswrapper.sh > $scriptdir/syswrapper.sh
chmod 755 $scriptdir/syswrapper.sh

startscript=$scriptdir/start.sh
poststart=/etc/persistent/rc.poststart

mv ~/start.sh $startscript
chmod 755 $startscript

if [ ! -f $poststart ]; then
    echo "$poststart not found, creating it ..."
    touch $poststart
    echo "#!/bin/sh" >> $poststart
    chmod 755 $poststart
fi

if grep -q "$startscript" "$poststart"; then
   echo "Found $poststart entry. File will not be changed"
else
   echo "Adding start command to $poststart as first line"
   awk "NR==1{print; print \"$startscript\"} NR!=1" $poststart > /tmp/poststart
   mv /tmp/poststart $poststart
fi
 
echo "Done!"
echo "run 'save' command if done."
