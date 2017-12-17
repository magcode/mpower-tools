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
                        echo "-t=TOPIC                  MQTT topic"
                        echo "-r=REFRESH                refresh in seconds (defaults to 60)"
                        
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

if [ -z "$topic" ]; then
    echo "no topic specified"
    exit 0
fi

# make sure the MQTT fast update request file exists
tmpfile=$(mktemp /tmp/mqtmp.XXXXXXXXXX)
echo 0 > $tmpfile

# make our settings available to the subscripts
export mqtthost
export topic
export refresh
export tmpfile
export version

log "killing old instances"

killall mqpub2.sh

log "starting pub and sub scripts"

$BIN_PATH/v2/mqpub2.sh &