#!/bin/bash

# Script to ensure VPN is running with kill switch functionality

DEBUG_MODE=true
DEBUG_PATH=/usr/vpnkillswitch/log.txt

restartVPN()
{
if [ "$DEBUG_MODE" = true ] ; then echo "Stopping Deluge..." >> $DEBUG_PATH ; fi
pkill deluged

if [ "$DEBUG_MODE" = true ] ; then echo "Restarting VPN..." >> $DEBUG_PATH ; fi
iptables -F
service openvpn restart
sleep 5

if [ "$DEBUG_MODE" = true ] ; then echo "Reconfiguring kill switch..." >> $DEBUG_PATH ; fi
# Get WAN IP
WAN_IP=$(wget -q -O - http://ipecho.net/plain)

# Configure IPTable rules
# Change eth0 to wlan0 (or whatever network interface is being used) for wireless
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

if [ "$DEBUG_MODE" = true ] ; then echo "Starting Deluge..." >> $DEBUG_PATH ; fi
deluged
}

VPN=$(service openvpn status)
PING=$(ping -c 1 google.com)
WAN_IP=$(wget -q -O - http://ipecho.net/plain)
IPT=$(iptables -L)

if [ "$DEBUG_MODE" = true ] ; then date >> $DEBUG_PATH ; fi

if [[ "$VPN" == *"is running"* ]]
then
	if [ "$DEBUG_MODE" = true ] ; then echo "VPN is running" >> $DEBUG_PATH ; fi
	if [[ "$PING" == *"1 received"* ]]
	then
		if [ "$DEBUG_MODE" = true ] ; then echo "Internet OK" >> $DEBUG_PATH ; fi
		if [[ "$IPT" == *"$WAN_IP"* ]]
		then
			if [ "$DEBUG_MODE" = true ] ; then echo "IPTables OK" >> $DEBUG_PATH ; fi
		else
			if [ "$DEBUG_MODE" = true ] ; then echo "IPTables not configured properly" >> $DEBUG_PATH ; fi
			restartVPN
		fi
	else
		if [ "$DEBUG_MODE" = true ] ; then echo "Internet down... Need to restart VPN" >> $DEBUG_PATH ; fi
		restartVPN
	fi
else
	if [ "$DEBUG_MODE" = true ] ; then echo "VPN is NOT running" >> $DEBUG_PATH ; fi
	restartVPN
fi
