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
wget --no-check-certificate -q https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/v2/installv2.sh -O /var/etc/persistent/mqtt/installv2.sh;chmod 755 /var/etc/persistent/mqtt/installv2.sh;/var/etc/persistent/mqtt/installv2.sh

save
reboot
```

# Starting
```
/var/etc/persistent/mqtt/v2/mqrunv2.sh -host <IP or hostname of MQTT Broker> [-t <chosen MQTT topic>] [-r <refresh in seconds>]
```

Default topic is `homie/[name of the mpower]`.

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
```

# Configuring transmitted node attributes
You can suppress certain attributes (such as voltage) by editing the file `mpower-pub.cfg`. Set value to `0` if you dont need the data.

```
#enable (1) or disable (0) properties here
relay=1
power=1
energy=1
voltage=0
```

# Control sockets via MQTT
You can control the sockets by sending `0` or `1` to the topic `<topic chosen above>/port<number of socket>/relay/set`

# logfile
The tool logs into standard messages log.
```
tail -f /var/log/messages
```

# Automatic start
You might want to start both processes described above automatically once the mPower starts.
For that create (or update!) the file `/var/etc/persistent/rc.poststart`. Don't forget the "&" at the end of lines.

```
#!/bin/sh
#
/var/etc/persistent/mqtt/v2/mqrunv2.sh -host <IP or hostname of MQTT Broker> [-t <chosen MQTT topic>] [-r <refresh in seconds>] &
```

Do not forget to make `rc.poststart` executable and save your changes after editing `rc.poststart`:
```
chmod 755 /var/etc/persistent/mqtt/rc.poststart
save
```

You can test now by rebooting the device (using `reboot`). Approx. 3 minutes after the mPower is up again, MQTT should be funtional.
If you don't like to reboot just type

```
/var/etc/persistent/mqtt/rc.poststart
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