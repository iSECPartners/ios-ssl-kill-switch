iOS SSL Kill Switch
https://github.com/nabla-c0d3/ios-ssl-kill-switch

MobileSubstrate extension to disable certificate validation at run-time in order 
to facilitate black-box testing of iOS Apps. 


Installation
============

- Tested on iOS 4.3 or 5.1

### Dependencies

- MobileSubstrate
- PreferenceLoader

### How to install

- Download the Debian package and copy it to the device
- Install the package:  

    dpkg -i <package>.deb

- Respring:  

    killall -HUP SpringBoard

- On the device, go into Settings->SSL Kill Switch and enable it
- Start / Restart the App you want to test

### How to uninstall

    dpkg -r com.nabla.sslkillswitch


TODO
====

- Disable certificate validation for NSStream and CFStream
- Force NSStream and CFStream to use the device's proxy settings


License
=======

MIT - See LICENSE.txt
Copyright 2012 Alban Diquet