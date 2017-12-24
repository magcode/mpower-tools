#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
export BIN_PATH=/etc/persistent/mqtt
export devicename=$(cat /tmp/system.cfg | grep resolv.host.1.name | sed 's/.*=\(.*\)/\1/')
export topic=homie/$devicename

refresh=60
version=$(cat /etc/version)-mq-0.2

source $BIN_PATH/client/mqtt.cfg

if [ -z "$mqtthost" ]; then
    echo "no host specified"
    exit 0
fi

# lets stop any process from former start attempts
log "killing old instances"
killall mqpub.sh
killall mqsub.sh
pkill -f mosquitto_sub.*relay/set

# make sure the MQTT fast update request file exists
rm /tmp/mqtmp.*
tmpfile=$(mktemp /tmp/mqtmp.XXXXXXXXXX)
log "Using temp file "$tmpfile
echo 0 > $tmpfile

# make our settings available to the subscripts
export mqtthost
export refresh
export tmpfile
export version
export clientID="MPMQCLIENT"

log "starting pub and sub scripts"
$BIN_PATH/client/mqpub.sh &
$BIN_PATH/client/mqsub.sh &