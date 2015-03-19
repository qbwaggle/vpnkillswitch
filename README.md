### VPNKillSwitch

This was originially developed with Raspberry Pi 2 Model B, but should work fine with other Debian installations.

I have tested it on Debian 7.x and it works.

VPNKillSwitch is a service that runs a script every 30 seconds to determine if (1) OpenVPN client is still connected, (2) if an internet connection is active, and (3) if the IPTables firewall rules are configured properly such that if VPN connection is lost, no data is sent or received. If any of the 3 tests fails, then the script will attempt to reconnect the client to the VPN and reconfigure the IPTables firewall rules.

The Wiki will provide better instruction.
