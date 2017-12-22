#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
export BIN_PATH=/etc/persistent/mqtt

refresh=60
version=$(cat /etc/version)-therm-2.0

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo ""
                        echo "Ubiquiti Networks mPower Thermostat version $version"
                        echo " "
                        echo "options:"
                        echo "-h, --help                show brief help"
                        echo "-host=HOSTNAME            MQTT host"
                        
                        exit 0
                        ;;
                -host)
                        shift
                        if test $# -gt 0; then
                                mqtthost=$1
                        else
                                echo "no host specified"
                                exit 1
                        fi
                        shift
                        ;;
                *)
                        break
                        ;;
        esac
done

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