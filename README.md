iOS SSL Kill Switch
https://github.com/nabla-c0d3/ios-ssl-kill-switch

MobileSubstrate extension to disable certificate validation at run-time in order 
to facilitate black-box testing of iOS Apps. 


Installation
============

iOS SSL Kill Switch was tested on iOS 4.3 or 5.1.

### Dependencies
Using Cydia make sure the following packages are installed:
- dpkg
- MobileSubstrate
- PreferenceLoader

### How to install

Download the Debian package and copy it to the device and install it:  

    dpkg -i <package>.deb

Respring the device:

    killall -HUP SpringBoard

There should be a new meny in the device's Settings where you can enable the extension.
Finally, start / restart the App you want to test.

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