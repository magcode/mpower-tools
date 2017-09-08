Use an SSH client and connect to your mPower device.
Enter the following commands

```
wget --no-check-certificate https://raw.githubusercontent.com/magcode/mpower-tools/master/nocontroller.sh -O /etc/persistent/nocontroller.sh;chmod 755 /etc/persistent/nocontroller.sh;/etc/persistent/nocontroller.sh
save
reboot
```

The device will reboot.

You can check if the installation was successful:

Directly after the device is online again, connect with SSH and call

```
tail -f /var/log/messages
```

You will see some log messages like this

```
Sep  8 18:17:34 mpower-beamer user.err syslog: ace_reporter.reporter_fail(): server unreachable
Sep  8 18:17:34 mpower-beamer user.err syslog: ace_reporter.reporter_fail(): initial contact failed #4, url=http://mfi:6080/inform, rc=1
```

Approx. 3 minutes after booting those messages should stop.