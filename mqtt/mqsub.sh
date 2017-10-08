#!/bin/sh
export LD_LIBRARY_PATH=/var/etc/persistent/mqtt

while test $# -gt 0; do
        case "$1" in
                -h|--help)
                        echo ""
                        echo "Ubiquiti Networks mPower MQTT listener"
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

listen(){
    /var/etc/persistent/mqtt/mosquitto_sub -h $mqtthost -v -t $topic/+/POWER | while read line; do
        topic=`echo $line| cut -d" " -f1`
        inputVal=`echo $line| cut -d" " -f2`
        
        port=`echo $topic | sed 's|.*/\([1-6]\)/POWER$|\1|'`
        
        if [ "$inputVal" == "ON" ] ; then
			val=1
		else
            val=0
        fi
        
        `echo $val > /proc/power/relay$port`
    done
}

ctrl_c() {
  echo "Exiting..."
}

trap ctrl_c INT
listen