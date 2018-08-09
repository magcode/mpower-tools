# Why do I need this?

You want to define that one or more ports of your mPower keeps OFF after reboot/power loss? Then this is for you.
Inpired by https://community.ubnt.com/t5/mFi/mPower-default-outlet-state-on-boot-no-controller/td-p/1315851

# What is this tool NOT doing

It does not revert the socket state as it was before the power loss.

# First time setup

```
wget --no-check-certificate -q https://raw.githubusercontent.com/magcode/mpower-tools/master/bootstate/install-bootstate.sh -O /etc/persistent/install-bootstate.sh;chmod 755 /etc/persistent/install-bootstate.sh;/etc/persistent/install-bootstate.sh
```

This will prepare a config file for you: `/var/etc/persistent/bootstate/bootstate.cfg`.
Edit this file and decide which ports shall be enabled or disabled when the device boots.
Once done call `/var/etc/persistent/bootstate/apply-bootstate.sh`.

# If you want to change the bootstate

Edit your config file ``.
Now call `/var/etc/persistent/bootstate/apply-bootstate.sh`
