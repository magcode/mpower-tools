#!/bin/sh
export LD_LIBRARY_PATH=/var/etc/persistent
actTempTopic="home/max/plain/3/1/ACTUAL_TEMPERATURE"
targetTempTopic="home/max/plain/3/1/SET_TEMPERATURE"
actTemp=0.0
targetTemp=0.0
host=192.168.155.20

listen(){
    /var/etc/persistent/mosquitto_sub -h $host -v -t $actTempTopic -t $targetTempTopic | while read line; do
        topic=`echo $line| cut -d" " -f1`
        val=`echo $line| cut -d" " -f2`
        
        if [ "$topic" == "$actTempTopic" ] ; then
			actTemp=$val
		fi

        if [ "$topic" == "$targetTempTopic" ] ; then
			targetTemp=$val
		fi
        
        echo "ActTemp: $actTemp";
        echo "TargetTemp: $targetTemp";
    done
}

ctrl_c() {
  echo "Exiting..."
}

trap ctrl_c INT
listen