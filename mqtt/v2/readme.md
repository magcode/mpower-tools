# About
This adds MQTT features to Ubiquiti Networks mPower devices.
This is version 2, which aims to comply with [homie MQTT convention](https://github.com/marvinroger/homie).

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
/var/etc/persistent/mqtt/v2/mqrunv2.sh -host <IP or hostname of MQTT Broker> -t <chosen MQTT topic> [-r <refresh in seconds>]
```



# Published data

The mPower device will publish messages to different topics.
Example:

```

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
You can control the sockets by sending `0` or `1` to the topic `<topic chosen above>/port<number of socket>/relay`

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
/var/etc/persistent/mqtt/mqpub.sh -host <IP or hostname of MQTT Broker> -t <chosen MQTT topic> [-r <refresh in seconds>] &
/var/etc/persistent/mqtt/mqsub.sh -host <IP or hostname of MQTT Broker> -t <chosen MQTT topic> &
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
Switch switchMPLR1 "mPower livingroom socket 1" { mqtt=">[mosquitto:home/mpowerlr/1/POWER:command:*:default],<[mosquitto:home/mpowerlr/sensors:state:JSONPATH($.sensors[0].relayoh)]" }
Number MPLR1Power "mPower livingroom socket 1 power [%.1f W]" { mqtt="<[mosquitto:home/mpowerlr/sensors:state:JSONPATH($.sensors[0].power)]" }
```