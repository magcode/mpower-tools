#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

# read config file
source $BIN_PATH/v2/mpower-pub.cfg
export PUBBIN=$BIN_PATH/mosquitto_pub

# identify type of mpower
export PORTS=`cat /etc/board.inc | grep feature_power | sed -e 's/.*\([0-9]\+\);/\1/'`

log "Found $((PORTS)) ports."
log "Publishing to $mqtthost with topic $topic"

REFRESHCOUNTER=$refresh
FASTUPDATE=0

$BIN_PATH/v2/mqpub2-static.sh
while sleep 1; 
do 
	# refresh logic: either we need fast updates, or we count down until it's time
	TMPFASTUPDATE=`cat $tmpfile`
	#echo "TMPFILE = " $TMPFASTUPDATE
    if [ -n "${TMPFASTUPDATE}" ]
	then
    	echo "fast update request: " $TMPFASTUPDATE
		FASTUPDATE=$TMPFASTUPDATE
		: > $tmpfile
	fi

	if [ $FASTUPDATE -ne 0 ]
	then
		# fast update required, we do updates every second until the requested number of fast updates is done
		FASTUPDATE=$((FASTUPDATE-1))
		#echo "fast update"
	else
		# normal updates, decrement refresh counter until it is time
		if [ $REFRESHCOUNTER -ne 0 ]
		then
			# not yet, keep counting
			REFRESHCOUNTER=$((REFRESHCOUNTER-1))
			continue
		else
			# time to update
			REFRESHCOUNTER=$refresh
			#echo "normal update"
		fi
	fi

    if [ $relay -eq 1 ]
    then
        # relay state
        for i in $(seq $PORTS)
        do
            relay_val=`cat /proc/power/relay$((i))`
            echo $relay_val | $PUBBIN -h $mqtthost -t $topic/port$i/relay -s -r
        done
    fi
    
    if [ $power -eq 1 ]
    then
        # current power
        for i in $(seq $PORTS)
        do
            power_val=`cat /proc/power/active_pwr$((i))`
            power_val=`printf "%.1f" $power_val`
            echo $power_val | $PUBBIN -h $mqtthost -t $topic/port$i/power -s -r
        done
    fi

    if [ $energy -eq 1 ]
    then
        # energy consumption 
        for i in $(seq $PORTS)
        do
            energy_val=`cat /proc/power/cf_count$((i))`
            energy_val=$(awk -vn1="$energy_val" -vn2="0.1325" 'BEGIN{print n1*n2}')
            energy_val=`printf "%.0f" $energy_val`
            echo $energy_val | $PUBBIN -h $mqtthost -t $topic/port$i/energy -s -r
        done
    fi
    
    if [ $voltage -eq 1 ]
    then
        # energy consumption 
        for i in $(seq $PORTS)
        do
            voltage_val=`cat /proc/power/v_rms$((i))`
            voltage_val=`printf "%.1f" $voltage_val`
            echo $voltage_val | $PUBBIN -h $mqtthost -t $topic/port$i/voltage -s -r
        done
    fi
done