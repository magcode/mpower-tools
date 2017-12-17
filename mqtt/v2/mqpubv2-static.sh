#!/bin/sh
# homie spec (incomplete)
echo "2.1.0" | $PUBBIN -h $mqtthost -t $topic/\$homie -s -r
echo $devicename | $PUBBIN -h $mqtthost -t $topic/\$name -s -r
echo $version | $PUBBIN -h $mqtthost -t $topic/\$fw/\$version -s -r

echo "mPower MQTT" | $PUBBIN -h $mqtthost -t $topic/\$fw/\$name -s -r
echo $version | $PUBBIN -h $mqtthost -t $topic/\$fw/\$version -s -r

IPADDR=`ifconfig ath0 | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }'`
echo $IPADDR | $PUBBIN -h $mqtthost -t $topic/\$localip -s -r

NODES=`seq $PORTS | sed 's/\([0-9]\)/port\1/' |  tr '\n' , | sed 's/.$//'`
echo $NODES | $PUBBIN -h $mqtthost -t $topic/\$nodes -s -r

UPTIME=`awk '{print $1}' /proc/uptime`
echo $UPTIME | $PUBBIN -h $mqtthost -t $topic/\$stats/uptime -s -r

# node infos
for i in $(seq $PORTS)
do
    echo "true" | $PUBBIN -h $mqtthost -t $topic/port$i/relay/\$settable -s -r
done