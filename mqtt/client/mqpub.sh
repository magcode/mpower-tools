#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

# read config file
source $BIN_PATH/client/mpower-pub.cfg
export PUBBIN=$BIN_PATH/mosquitto_pub

# identify type of mpower
export PORTS=`cat /etc/board.inc | grep feature_power | sed -e 's/.*\([0-9]\+\);/\1/'`

log "Found $((PORTS)) ports."
log "Publishing to $mqtthost with topic $topic"

REFRESHCOUNTER=$refresh
FASTUPDATE=0


export relay=$relay
export power=$power
export energy=$energy
export voltage=$voltage
export lock=$lock

$BIN_PATH/client/mqpub-static.sh
while sleep 1; 
do 
	# refresh logic: either we need fast updates, or we count down until it's time
	TMPFASTUPDATE=`cat $tmpfile`
	#echo "TMPFILE = " $TMPFASTUPDATE
    if [ -n "${TMPFASTUPDATE}" ]
	then
		FASTUPDATE=$TMPFASTUPDATE
		: > $tmpfile
	fi

	if [ $FASTUPDATE -ne 0 ]
	then
		# fast update required, we do updates every second until the requested number of fast updates is done
		FASTUPDATE=$((FASTUPDATE-1))
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
		fi
	fi

    if [ $relay -eq 1 ]
    then
        # relay state
        for i in $(seq $PORTS)
        do
            relay_val=`cat /proc/power/relay$((i))`
            if [ $relay_val -ne 1 ]
            then
              relay_val=0
            fi
            $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/relay -m "$relay_val" -r
        done
    fi
    
    if [ $power -eq 1 ]
    then
        # current power
        for i in $(seq $PORTS)
        do
            power_val=`cat /proc/power/active_pwr$((i))`
            power_val=`printf "%.1f" $power_val`
            $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/power -m "$power_val" -r
        done
    fi

    if [ $energy -eq 1 ]
    then
        # energy consumption 
        for i in $(seq $PORTS)
        do
            energy_val=`cat /proc/power/cf_count$((i))`
            energy_val=$(awk -vn1="$energy_val" -vn2="0.3125" 'BEGIN{print n1*n2}')
            energy_val=`printf "%.0f" $energy_val`
            $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/energy -m "$energy_val" -r
        done
    fi
    
    if [ $voltage -eq 1 ]
    then
        # energy consumption 
        for i in $(seq $PORTS)
        do
            voltage_val=`cat /proc/power/v_rms$((i))`
            voltage_val=`printf "%.1f" $voltage_val`
            $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/voltage -m "$voltage_val" -r
        done
    fi
    
    if [ $lock -eq 1 ]
    then
        # lock
        for i in $(seq $PORTS)
        do
            port_val=`cat /proc/power/lock$((i))`
            $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/lock -m "$port_val" -r
        done
    fi
done