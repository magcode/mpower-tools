#!/bin/sh
export LD_LIBRARY_PATH=/var/etc/persistent/mqtt
actTempTopic="home/max/plain/3/1/ACTUAL_TEMPERATURE"
targetTempTopic="home/max/plain/3/1/SET_TEMPERATURE"
debugTopic="home/heating/bathroom/debug"

actTemp=0.0
targetTemp=0.0
hyster=0.2
host=192.168.155.20
mode=0

listen(){
    /var/etc/persistent/mqtt/mosquitto_sub -h $host -v -t $actTempTopic -t $targetTempTopic | while read line; do
        topic=`echo $line| cut -d" " -f1`
        val=`echo $line| cut -d" " -f2`
        
        if [ "$topic" == "$actTempTopic" ] ; then
			actTemp=$val
		fi

        if [ "$topic" == "$targetTempTopic" ] ; then
			targetTemp=$val
		fi
        
        withHyster1=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1-n2}')
        withHyster2=$(awk -vn1="$targetTemp" -vn2="$hyster" 'BEGIN{print n1+n2}')
        result1=$(awk -vn1="$actTemp" -vn2="$withHyster1" 'BEGIN{print (n1<n2)?1:0 }')
        result2=$(awk -vn1="$actTemp" -vn2="$withHyster2" 'BEGIN{print (n1>n2)?1:0 }')
        
        # echo "ActTemp: $actTemp";
        # echo "TargetTemp: $targetTemp";
        # echo "withHyster1: $withHyster1";
        # echo "withHyster2: $withHyster2";
                
        debug=""
        if [ "$result1" -eq 1 ];then
            if [ "$mode" -eq 0 ];then
                debug=$(printf "ActTemp: %s TargetTemp: %s Too cold, start heating." "$actTemp" "$targetTemp")
                mode=1
            else
                debug=$(printf "ActTemp: %s TargetTemp: %s Too cold, continue heating." "$actTemp" "$targetTemp")                       
            fi
        elif [ "$result2" -eq 1 ];then
            if [ "$mode" -eq 1 ];then
                debug=$(printf "ActTemp: %s TargetTemp: %s Warm enough, stop heating." "$actTemp" "$targetTemp")
                mode=0
            else
                debug=$(printf "ActTemp: %s TargetTemp: %s Warm enough, keep heating off." "$actTemp" "$targetTemp")         
            fi            
        fi
        # echo $debug
        /var/etc/persistent/mqtt/mosquitto_pub -h $host -t $debugTopic -m "$debug"
    done
}

ctrl_c() {
  echo "Exiting..."
}

trap ctrl_c INT
listen