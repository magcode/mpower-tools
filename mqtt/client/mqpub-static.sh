#!/bin/sh
# homie spec (incomplete)
$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$homie -m "2.1.0" -r
$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$name -m "$devicename" -r
$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$fw/version -m "$version" -r

$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$fw/name -m "mPower MQTT" -r

IPADDR=`ifconfig ath0 | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }'`
$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$localip -m "$IPADDR" -r

NODES=`seq $PORTS | sed 's/\([0-9]\)/port\1/' |  tr '\n' , | sed 's/.$//'`
$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$nodes -m "$NODES" -r

UPTIME=`awk '{print $1}' /proc/uptime`
$PUBBIN -h $mqtthost $auth $cafile -t $topic/\$stats/uptime -m "$UPTIME" -r

properties=relay

if [ $energy -eq 1 ]
then
    properties=$properties,energy
fi

if [ $power -eq 1 ]
then
    properties=$properties,power
fi

if [ $voltage -eq 1 ]
then
    properties=$properties,voltage
fi

if [ $lock -eq 1 ]
then
    properties=$properties,lock
fi
# node infos
for i in $(seq $PORTS)
do
    $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/\$name -m "Port $i" -r
    $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/\$type -m "power switch" -r
    $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/\$properties -m "$properties" -r
    $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/relay/\$settable -m "true" -r
done

if [ $lock -eq 1 ]
then
    for i in $(seq $PORTS)
    do
        $PUBBIN -h $mqtthost $auth $cafile -t $topic/port$i/lock/\$settable -m "true" -r
    done
fi