#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}
source $BIN_PATH/client/led.cfg

# initially set the LED. If configured it can be switched along with the relay later
if [ -n "$afterboot" ];
then
  echo $afterboot > /proc/led/status  
fi
# it should not blink
echo 0 > /proc/led/freq

log "MQTT listening..."
$BIN_PATH/mosquitto_sub -I $clientID -h $mqtthost $auth -v -t $topic/+/+/set \
--will-topic $topic/$online --will-retain --will-qos 1 --will-payload 'false' \
| while read line; do
    rxtopic=`echo $line| cut -d" " -f1`
    inputVal=`echo $line| cut -d" " -f2`
    
    port=`echo $rxtopic | sed 's|.*/port\([1-8]\)/[a-z]*/set$|\1|'`
    property=`echo $rxtopic | sed 's|.*/port[1-8]/\([a-z]*\)/set$|\1|'`
    
    if [ "$property" == "lock" ] || [ "$property" == "relay" ]
    then
    
        if [ "$inputVal" == "1" ]
        then
            val=1
            # led handling
            if [ -n "$relay_on" ]
            then
              echo $relay_on > /proc/led/status
            fi
        elif [ "$inputVal" == "0" ]
        then
            val=0
        else
            continue
        fi
        log "MQTT request received. $property control for port" $port "with value" $inputVal
        `echo $val > /proc/power/$property$port`
        echo 5 > $tmpfile
        
        # led handling for relay_off
        if [ -n "$relay_off" ]
        then
          all_relay_val=0
          for i in $(seq $PORTS)
          do
              relay_val=`cat /proc/power/relay$((i))`
              if [ $relay_val -eq 1 ]
              then
                all_relay_val=1
              fi
          done
          # only set LED if all ports are OFF
          if [ $all_relay_val -eq 0 ]
          then
            echo $relay_off > /proc/led/status
          fi
        fi
    fi        
done
