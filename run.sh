#!/bin/bash

# Script to ensure VPN is running with kill switch

restartVPN()
{
echo "Restarting VPN..."

# Stop deluge-daemon
# service deluge-daemon stop

iptables -F
service openvpn restart
sleep 5

echo "Reconfiguring kill switch..."

# Get WAN IP
WAN_IP=$(wget -q -O - http://ipecho.net/plain)

# Configure IPTable rules
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -d 255.255.255.255 -j  ACCEPT
iptables -A INPUT -s 255.255.255.255 -j ACCEPT
iptables -A INPUT -s 10.0.0.0/16 -d 10.0.0.0/16 -j ACCEPT
iptables -A OUTPUT -s 10.0.0.0/16 -d 10.0.0.0/16 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
iptables -A OUTPUT -o eth0 ! -d $WAN_IP -j DROP

# Start deluge-daemon
# service deluge-daemon start
}

VPN=$(service openvpn status)
PING=$(ping -c 1 google.com)

while [ true ]
do

VPN=$(service openvpn status)
PING=$(ping -c 1 google.com)
WAN_IP=$(wget -q -O - http://ipecho.net/plain)
IPT=$(iptables -L)

if [[ "$VPN" == *"is running"* ]]
then
	echo "VPN is running"
	if [[ "$PING" == *"1 received"* ]]
	then
		echo "Internet OK"
		if [[ "$IPT" == *"$WAN_IP"* ]]
		then
			echo "IPTables OK"
		else
			echo "IPTables not configured properly"
			restartVPN
		fi
	else
		echo "Internet down... Need to restart VPN"
		restartVPN
	fi
else
	echo "VPN is NOT running"
	restartVPN
fi
sleep 30
done
