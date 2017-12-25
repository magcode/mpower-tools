#!/bin/sh

log() {
	logger -s -t "thermostat" "$*"
}

export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
export BIN_PATH=/etc/persistent/mqtt

source $BIN_PATH/thermostat/mqtt.cfg

if [ -z "$mqtthost" ]; then
    echo "no host specified"
    exit 0
fi

# make our settings available to the subscripts
export mqtthost
export clientID="MPTHERM"

# lets stop any process from former start attempts
log "killing old instances"
killall thermostat.sh
pkill -f mosquitto_sub.*$clientID

log "starting sub script"
$BIN_PATH/thermostat/thermostat.sh &