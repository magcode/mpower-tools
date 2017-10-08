# About
This adds MQTT features to Ubiquiti Networks mPower devices.

# Warning
Use at your own risk!

# Installation
Use an SSH client and connect to your mPower device.
Enter the following commands

```
mkdir /etc/persistent/mqtt
wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/mqtt/install.sh -O /etc/persistent/mqtt/install.sh;chmod 755 /etc/persistent/mqtt/install.sh;/etc/persistent/mqtt/install.sh

save
reboot
```

# Receive status information

In order to start the MQTT publisher the following process needs to run on the mPower device:

```
/var/etc/persistent/mqtt/mqsub.sh -host <IP or hostname of MQTT Broker> -t <choosen MQTT topic> [-r <refresh in seconds>]
```

Once started the mPower device will publish a message to the topic `<choosen MQTT topic>/sensors` with a JSON payload each 60 seconds (60 seconds is the default).

```
{"sensors":[{"port":1,"output":0,"power":0.0,"enabled":1,"current":0.0,"voltage":0.0,"powerfactor":0.0,"relay":0,"relayoh":"OFF","lock":0,"thismonth":0},{"port":2,"output":0,"power":0.0,"enabled":1,"current":0.0,"voltage":0.0,"powerfactor":0.0,"relay":0,"relayoh":"OFF","lock":0,"thismonth":0},{"port":3,"output":0,"power":0.0,"enabled":1,"current":0.0,"voltage":0.0,"powerfactor":0.0,"relay":0,"relayoh":"OFF","lock":0,"thismonth":0},{"port":4,"output":0,"power":0.0,"enabled":1,"current":0.0,"voltage":0.0,"powerfactor":0.0,"relay":0,"relayoh":"OFF","lock":0,"thismonth":0},{"port":5,"output":0,"power":0.0,"enabled":1,"current":0.0,"voltage":0.0,"powerfactor":0.0,"relay":0,"relayoh":"OFF","lock":0,"thismonth":0},{"port":6,"output":0,"power":0.0,"enabled":1,"current":0.0,"voltage":0.0,"powerfactor":0.0,"relay":0,"relayoh":"OFF","lock":0,"thismonth":0}],"status":"success"}
```

# Control sockets via MQTT

In order to start the MQTT listener the following process needs to run on the mPower device:

```
/var/etc/persistent/mqtt/mqsub.sh -host <IP or hostname of MQTT Broker> -t <choosen MQTT topic>
```

Once it is started you can control the sockets by publishing the payload "ON" or "OFF" to the following topic:

```
<topic choosen above>/<number of socket>/<POWER>
```

# Integrating into OpenHAB:

```
Switch switchMPLR1 "mPower livingroom socket 1" { mqtt=">[mosquitto:home/mpowerlr/1/POWER:command:*:default],<[mosquitto:home/mpowerlr/sensors:state:JSONPATH($.sensors[0].relayoh)]" }
Number MPLR1Power "mPower livingroom socket 1 power [%.1f W]" { mqtt="<[mosquitto:home/mpowerlr/sensors:state:JSONPATH($.sensors[0].power)]" }
```