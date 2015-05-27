#### Start Unified Remote server on startup with this service.

##### To download & install urserver:
```
sudo wget https://www.unifiedremote.com/static/builds/server/linux-rpi/420/urserver-3.2.4.420.deb
sudo dpkg -i urserver-3.2.4.420.deb
```

##### To start urserver at boot:
```
wget https://raw.githubusercontent.com/qbwaggle/rpi_scripts/master/urserver/urserver.sh
chmod 755 urserver.sh
cp urserver.sh /etc/init.d/urserver
update-rc.d urserver defaults
```
