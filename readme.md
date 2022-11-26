# About
This project provides some tools for Ubiquiti Networks mPower devices.

[nocontroller](nocontroller) Disables the controller connection attempts.

[MQTT client](mqtt/client) Provides a MQTT client.

[bootstate](bootstate) Define which sockets are enabled during boot.

[Thermostat](mqtt/thermostat) A simple thermostat script.

# General notice

Due to the ancient SSH daemon on the plugs modern SSH clients will not connect. You can pass the command
line flag `-oKexAlgorithms=+diffie-hellman-group1-sha1` to allow your client to connect. An example would look
like:

`ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -c 3des-cbc  -oHostKeyAlgorithms=+ssh-rsa,ssh-dss ubnt@192.168.2.20`
