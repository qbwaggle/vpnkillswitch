#!/bin/bash

# This script will UNINSTALL OpenVPN
# and the vpnkillswitch service

# Stop the services
service openvpn stop
service vpnkillswitch stop

# Remove OpenVPN and configuration files
apt-get purge openvpn

# Remove vpnkillswitch from init scripts
service vpnkillswitch uninstall

# Clean-up files
rm -r /usr/vpnkillswitch
rm /etc/openvpn/*
