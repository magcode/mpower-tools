#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
export BIN_PATH=/etc/persistent/mqtt

refresh=60
version=$(cat /etc/version)-mq-0.2

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo ""
                        echo "Ubiquiti Networks mPower MQTT version $version"
                        echo " "
                        echo "options:"
                        echo "-h, --help                show brief help"
                        echo "-host=HOSTNAME            MQTT host"
                        echo "-t=TOPIC                  OPTIONAL: MQTT topic (defaults to homie/[device-name]"
                        echo "-r=REFRESH                OPTIONAL: refresh in seconds (defaults to 60)"
                        
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
                -t)
                        shift
                        if test $# -gt 0; then
                                topic=$1
                        else
                                echo "no topic specified"
                                exit 1
                        fi
                        shift
                        ;;
                -r)
                        shift
                        if test $# -gt 0; then
                                refresh=$1
                        else
                                echo "no refresh time specified"
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

# lets stop any process from former start attempts
log "killing old instances"
killall mqpubv2.sh
killall mqsubv2.sh
pkill -f mosquitto_sub.*relay/set

# make sure the MQTT fast update request file exists
rm /tmp/mqtmp.*
tmpfile=$(mktemp /tmp/mqtmp.XXXXXXXXXX)
log "Using temp file "$tmpfile
echo 0 > $tmpfile

# make our settings available to the subscripts
export mqtthost
export devicename=$(cat /tmp/system.cfg | grep resolv.host.1.name | sed 's/.*=\(.*\)/\1/')
export topic=homie/$devicename
export refresh
export tmpfile
export version

log "starting pub and sub scripts"
$BIN_PATH/v2/mqpubv2.sh &
$BIN_PATH/v2/mqsubv2.sh &