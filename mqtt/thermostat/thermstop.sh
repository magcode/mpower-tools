#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}
clientID="MPTHERM"
log "killing old instances"
killall thermostat.sh
pkill -f mosquitto_sub.*$clientID