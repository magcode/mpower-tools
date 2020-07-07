#!/bin/sh
#
log() {
	logger -s -t "bootstate" "$*"
}

config=/var/etc/persistent/bootstate/bootstate.cfg
vpower=/etc/persistent/cfg/vpower_cfg

cat $config > $vpower
log "Applied bootstate"
cfgmtd -w -p /etc/
