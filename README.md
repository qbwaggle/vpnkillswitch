### VPNKillSwitch

VPNKillSwitch is a script that can be run on a schedule using cron (see below for my implementation). It determines if (1) OpenVPN client is still connected, (2) if an internet connection is active, and (3) if the IPTables firewall rules are configured properly such that if VPN connection is lost, no data is sent or received. If any of the 3 tests fails, then the script will attempt to reconnect the client to the VPN and reconfigure the IPTables firewall rules.

The Wiki provides better instructions on the aforementioned configuration.

### Running Script with Cron

In Debian 8.x edit the crontab file with the following command: `nano /etc/crontab`

Add the following line to the end of the file:

`*1/ * * * * root /usr/vpnkillswitch/vpnkillswitch.sh`

Change the path of `vpnkillswitch.sh` as needed.
