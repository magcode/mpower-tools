#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}
clientID="MPMQCLIENT"
log "killing old instances"
killall mqpub.sh
killall mqsub.sh
pkill -f mosquitto_sub.*$clientID