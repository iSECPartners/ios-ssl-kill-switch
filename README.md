iOS SSL Kill Switch
===================

Blackbox tool to disable SSL certificate validation - including certificate
pinning - within iOS Apps.


Description
-----------

Once installed on a jailbroken device, iOS SSL Kill Switch patches low-level
SSL functions within the Secure Transport API, including _SSLSetSessionOption()_
and _SSLHandshake()_ in order to override and disable the system's default
certificate validation as well as any kind of custom certificate validation
(such as certificate pinning).

It was successfully tested against various Apps implementing certificate
pinning including the Apple App Store. iOS SSL Kill Switch was initially
released at Black Hat Vegas 2012.

For more technical details on how it works, see
http://nabla-c0d3.github.io/blog/2013/08/20/ios-ssl-kill-switch-v0-dot-5-released/


WARNING: THIS TWEAK WILL MAKE YOUR DEVICE INSECURE
---------------------------------------------------

Installing this tweak allows anyone on the same network as the device to
easily perform man-in-the-middle attacks against *any* SSL or HTTPS
connection. This means that it is trivial to get access to emails, websites
viewed in Safari and any other data downloaded by any App running on the
device.


Installation
------------

Users should first download the latest pre-compiled Debian package available in
the release section of the project page at:
https://github.com/iSECPartners/ios-ssl-kill-switch/releases

The tool was tested on iOS7 running on an iPhone 5S.

### Dependencies

iOS SSL Kill Switch will only run on a jailbroken device. Using Cydia, make
sure the following packages are installed:
- dpkg
- MobileSubstrate
- PreferenceLoader

### How to install

Download and copy the Debian package to the device; install it:

    dpkg -i <package>.deb

Respring the device:

    killall -HUP SpringBoard

There should be a new menu in the device's Settings where you can
enable the extension.

Finally, kill and restart the App you want to test.

### How to uninstall

    dpkg -r com.isecpartners.nabla.sslkillswitch


Intercepting the App Store's traffic
------------------------------------

Additional instructions are available here:
http://nabla-c0d3.github.io/blog/2013/08/20/intercepting-the-app-stores-traffic-on-ios/


Build
-----

Most users should just download and install the Debian package.
The build requires the Theos suite to be installed;
see http://www.iphonedevwiki.net/index.php/Theos/Getting_Started .
You first have to create a symlink to your theos installation:

    ln -s /opt/theos/ theos

Make sure dpkg is installed. If you have Homebrew, use:

    brew install dpkg

Then, the package can be built using:

    make package


Changelog
---------

* v0.6: Added support for iOS 7.
* v0.5: Complete rewrite in order to add support for proxy-ing Apple's App Store application.
* v0.4: Added hooks for SecTrustEvaluate().
* v0.3: Bug fixes and support for iOS 6.
* v0.2: Initial release.


License
-------

MIT - See LICENSE.txt


Author
------

Alban Diquet - https://github.com/nabla-c0d3
