#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"    
}

# read config
source $BIN_PATH/thermostat/thermostat.cfg

# init vars
for i in `seq 1 $channels`;
do
   eval actTemp$i=0.0
   eval targetTemp$i=0.0
   eval currentMode$i=0
   eval current=\$actTempTopic$i
   topics="$topics -t $current"
   eval current=\$targetTempTopic$i
   topics="$topics -t $current"
done

log "Starting thermostat with $channels channels and hysteresis=$hyster"
log "listening to topics: $topics"

listen(){
    $BIN_PATH/mosquitto_sub -I $clientID -h $mqtthost -v $topics | while read line; do
        topic=`echo $line| cut -d" " -f1`
        val=`echo $line| cut -d" " -f2`
        
        for i in `seq 1 $channels`;
        do
            eval current=\$actTempTopic$i
            if [ "$topic" ==  $current ]; then
                eval actTemp$i=$val
            fi
            
            eval current=\$targetTempTopic$i
            if [ "$topic" ==  $current ]; then
                eval targetTemp$i=$val
            fi
            
            eval targetTemp=\$targetTemp$i
            eval actTemp=\$actTemp$i
            eval currentMode=\$currentMode$i
            
            withHyster1=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1-n2}')
            withHyster2=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1+n2}')
            result1=$(awk -vn1="$actTemp" -vn2="$withHyster1" 'BEGIN{print (n1<n2)?1:0 }')
            result2=$(awk -vn1="$actTemp" -vn2="$withHyster2" 'BEGIN{print (n1>n2)?1:0 }')
            
            debug=""
            if [ "$result1" -eq 1 ];then
                if [ "$currentMode" -eq 0 ];then
                    debug=`printf "Channel %s - ActTemp: %s TargetTemp: %s Too cold, start heating." "$i" "$actTemp" "$targetTemp"`
                    eval currentMode$i=1
                    #echo 1 > /proc/power/relay1
                else
                    debug=`printf "Channel %s - ActTemp: %s TargetTemp: %s Too cold, continue heating." "$i" "$actTemp" "$targetTemp"`
                fi
                $BIN_PATH/mosquitto_pub -h $mqtthost -t $debugTopic -m "$debug"
            elif [ "$result2" -eq 1 ];then
                if [ "$currentMode" -eq 1 ];then
                    debug=`printf "Channel %s - ActTemp: %s TargetTemp: %s Warm enough, stop heating." "$i" "$actTemp" "$targetTemp"`
                    eval currentMode$i=0
                    #echo 0 > /proc/power/relay1
                else
                    debug=`printf "Channel %s - ActTemp: %s TargetTemp: %s Warm enough, keep heating off." "$i" "$actTemp" "$targetTemp"`
                fi
                $BIN_PATH/mosquitto_pub -h $mqtthost -t $debugTopic -m "$debug"
            fi
        done
    done
}

listen