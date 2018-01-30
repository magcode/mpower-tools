#!/bin/sh

log() {
	logger -s -t "thermostat" "$*"
}
clientID="MPTHERM"
log "killing old instances"
killall thermostat.sh
pkill -f mosquitto_sub.*$clientID