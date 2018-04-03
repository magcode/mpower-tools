# About
This adds MQTT features to Ubiquiti Networks mPower devices.
This is version 2, which aims to comply with [homie MQTT convention](https://github.com/marvinroger/homie). The implementation of the convention is not complete yet.

# Warning
Use at your own risk!

# Installation
Use a SSH client and connect to your mPower device.
Enter the following commands

```
mkdir /var/etc/persistent/mqtt
wget --no-check-certificate -q https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/client/install-client.sh -O /var/etc/persistent/mqtt/install-client.sh;chmod 755 /var/etc/persistent/mqtt/install-client.sh;/var/etc/persistent/mqtt/install-client.sh

save
reboot
```

# Starting
```
/var/etc/persistent/mqtt/client/mqrun.sh
```
The script also starts automatically approx 3 minutes after booting the device (using rc.poststart).

# Stoping
```
/var/etc/persistent/mqtt/client/mqstop.sh
```

# Configuration
## MQTT
Edit the file `/var/etc/persistent/mqtt/client/mqtt.cfg` and configure your server, topic and refresh time. Setting topic, refresh, mqttusername and mqttpassword is not mandatory. Defaults are 
`topic=homie/[name of the mpower]` and `refresh=60` seconds

```
mqtthost=192.168.0.1
#refresh=60
#topic=my/topic
#mqttusername=myMqttUserName
#mqttpassword=myMqttPassword
```
## Configuring transmitted node attributes
You can suppress certain attributes (such as voltage) by editing the file `mpower-pub.cfg`. Set value to `0` if you dont need the data.

```
#enable (1) or disable (0) properties here
relay=1
power=1
energy=1
lock=1
voltage=0
```

# Published data

The mPower device will publish messages every 60 seconds to different topics. Example:

```
homie/mpower-1/port1/relay=0
homie/mpower-1/port2/relay=1
homie/mpower-1/port3/relay=0
homie/mpower-1/port1/power=0.0
homie/mpower-1/port2/power=7.2
homie/mpower-1/port3/power=0.0
homie/mpower-1/port1/energy=0
homie/mpower-1/port2/energy=4
homie/mpower-1/port3/energy=8
homie/mpower-1/port1/voltage=0.0
homie/mpower-1/port2/voltage=234.9
homie/mpower-1/port3/voltage=0.0
```

Additionally - currently only at the start of the script - the device will also report:

```
homie/mpower-1/$homie=2.1.0
homie/mpower-1/$name=mpower-1
homie/mpower-1/$fw/version=MF.v2.1.11-mq-0.2
homie/mpower-1/$fw/name=mPower=MQTT
homie/mpower-1/$localip=192.168.1.26
homie/mpower-1/$nodes=port1,port2,port3
homie/mpower-1/$stats/uptime=2589629.67
homie/mpower-1/port1/relay/$settable=true
homie/mpower-1/port2/relay/$settable=true
homie/mpower-1/port3/relay/$settable=true
homie/mpower-1/port1/lock/$settable=true
homie/mpower-1/port2/lock/$settable=true
homie/mpower-1/port3/lock/$settable=true
```

# Control sockets via MQTT
You can control the sockets by sending `0` or `1` to the topic `<topic chosen above>/port<number of socket>/relay/set`

You can lock the sockets by sending `0` or `1` to the topic `<topic chosen above>/port<number of socket>/lock/set`

# logfile
The tool logs into standard messages log.
```
tail -f /var/log/messages
```

# Integrating into openHAB

This is an example how to define openHAB items:

```
Switch switchmp "My mpower switch" { mqtt=">[mosquitto:homie/mpower1/port1/relay/set:command:ON:1],>[mosquitto:homie/mpower1/port1/relay/set:command:OFF:0],<[mosquitto:homie/mpower1/port1/relay:state:MAP(mpowerrelay.map)]"}
Number energymp "Energy consumption [%d Wh]" { mqtt="<[mosquitto:homie/mpower1/port1/energy:state:default]" }
Number powermp "Current power [%.1f W]" { mqtt="<[mosquitto:homie/mpower1/port1/power:state:default]" }

```

You need a `mpowerrelay.map` file:
```
0=OFF
1=ON
```