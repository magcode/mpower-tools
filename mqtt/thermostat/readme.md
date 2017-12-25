# About
This is a simple thermostat implementation for mPower devices.
It requires a current and target temperature sent via MQTT.
It compares both and enables the relay if required.

# Warning
Use at your own risk!

# Installation
tbd

# Configuration
The file `mqtt.cfg' must be edited with the MQTT server information.
The file `thermostat.cfg` must be edited with the MQTT topic information.

# Starting

Run

```
/etc/persistent/mqtt/thermostat/thermrun.sh
```