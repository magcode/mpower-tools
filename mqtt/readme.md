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
