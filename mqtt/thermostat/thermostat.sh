#!/bin/sh

log() {
	logger -s -t "thermostat" "$*"    
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

log "Starting thermostat with $channels channels"
log "listening to topics: $topics"

# turn off all relays
for i in `seq 1 $channels`;
do
	echo 0 > /proc/power/relay$i
done		
		
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
            
			eval hyster=\$hyster$i
            eval targetTemp=\$targetTemp$i
            eval actTemp=\$actTemp$i
            eval currentMode=\$currentMode$i
            eval roomName=\$roomName$i
			
            withHysterLow=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1-n2}')
            withHysterHigh=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1+n2}')
            belowHystLow=$(awk -vn1="$actTemp" -vn2="$withHysterLow" 'BEGIN{print (n1<n2)?1:0 }')
            aboveHystHigh=$(awk -vn1="$actTemp" -vn2="$withHysterHigh" 'BEGIN{print (n1>n2)?1:0 }')
			belowHystHigh=$(awk -vn1="$actTemp" -vn2="$withHysterHigh" 'BEGIN{print (n1<=n2)?1:0 }')
            
            debug=""
			
			# currently not heating
			if [ "$currentMode" -eq 0 ];then
				if [ "$belowHystLow" -eq 1 ];then
                    debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Too cold, start heating." "$i" "$roomName" "$actTemp" "$targetTemp"`
                    eval currentMode$i=1
                    echo 1 > /proc/power/relay$i
				else
					debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Warm enough, keep heating off." "$i" "$roomName" "$actTemp" "$targetTemp"`
				fi
			# currently heating
			elif [ "$currentMode" -eq 1 ];then
				if [ "$aboveHystHigh" -eq 1 ];then
					debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Warm enough, stop heating." "$i" "$roomName" "$actTemp" "$targetTemp"`
                    eval currentMode$i=0
                    echo 0 > /proc/power/relay$i
				elif [ "$belowHystHigh" -eq 1 ];then
					debug=`printf "Channel %s (%s) - ActTemp: %s TargetTemp: %s Too cold, continue heating." "$i" "$roomName" "$actTemp" "$targetTemp"`
				fi
			fi
			$BIN_PATH/mosquitto_pub -h $mqtthost -t $debugTopic -m "$debug"
        done
    done
}

listen