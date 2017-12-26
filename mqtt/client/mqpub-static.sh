#!/bin/sh
# homie spec (incomplete)
$PUBBIN -h $mqtthost -t $topic/\$homie -m "2.1.0" -r
$PUBBIN -h $mqtthost -t $topic/\$name -m "$devicename" -r
$PUBBIN -h $mqtthost -t $topic/\$fw/version -m "$version" -r

$PUBBIN -h $mqtthost -t $topic/\$fw/name -m "mPower MQTT" -r

IPADDR=`ifconfig ath0 | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }'`
$PUBBIN -h $mqtthost -t $topic/\$localip -m "$IPADDR" -r

NODES=`seq $PORTS | sed 's/\([0-9]\)/port\1/' |  tr '\n' , | sed 's/.$//'`
$PUBBIN -h $mqtthost -t $topic/\$nodes -m "$NODES" -r

UPTIME=`awk '{print $1}' /proc/uptime`
$PUBBIN -h $mqtthost -t $topic/\$stats/uptime -m "$UPTIME" -r

# node infos
for i in $(seq $PORTS)
do
    $PUBBIN -h $mqtthost -t $topic/port$i/relay/\$settable -m "true" -r
done

if [ $lock -eq 1 ]
then
    for i in $(seq $PORTS)
    do
        $PUBBIN -h $mqtthost -t $topic/port$i/lock/\$settable -m "true" -r
    done
fi