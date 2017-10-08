#!/bin/sh
export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
refresh=60

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo ""
                        echo "Ubiquiti Networks mPower MQTT publisher"
                        echo " "
                        echo "options:"
                        echo "-h, --help                show brief help"
                        echo "-host=HOSTNAME            MQTT host"
                        echo "-t=TOPIC                  MQTT topic"
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


while sleep $refresh; 
do 
    /sbin/cgi /usr/www/mfi/sensors.cgi | tail -n +3 | sed  -e 's/"relay":1/"relay":1,"relayoh":"ON"/g' -e 's/"relay":0/"relay":0,"relayoh":"OFF"/g' | /var/etc/persistent/mqtt/mosquitto_pub -h $mqtthost -t $topic/sensors -s
done