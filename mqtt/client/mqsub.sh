#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

log "MQTT listening..."
$BIN_PATH/mosquitto_sub -I $clientID -h $mqtthost -v -t $topic/+/+/set | while read line; do
    rxtopic=`echo $line| cut -d" " -f1`
    inputVal=`echo $line| cut -d" " -f2`
    
    port=`echo $rxtopic | sed 's|.*/port\([1-8]\)/[a-z]*/set$|\1|'`
    property=`echo $rxtopic | sed 's|.*/port[1-8]/\([a-z]*\)/set$|\1|'`
    
    if [ "$property" == "lock" ] || [ "$property" == "relay" ]
    then
    
        if [ "$inputVal" == "1" ]
        then
            val=1
        elif [ "$inputVal" == "0" ]
        then
            val=0
        else
            continue
        fi
        log "MQTT request received. $property control for port" $port "with value" $inputVal
        `echo $val > /proc/power/$property$port`
        echo 5 > $tmpfile
    fi        
done