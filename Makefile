TARGET := iphone:7.1
ARCHS := armv7 arm64

include theos/makefiles/common.mk

# tweak
TWEAK_NAME = SSLKillSwitch
SSLKillSwitch_FILES = Tweak.xm

SSLKillSwitch_FRAMEWORKS = UIKit Security
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

# application
APPLICATION_NAME = SSLKillSwitchSettings
SSLKillSwitchSettings_FILES = application.m

SSLKillSwitchSettings_FRAMEWORKS = UIKit CoreGraphics
SSLKillSwitchSettings_PRIVATE_FRAMEWORKS = Preferences
SSLKillSwitchSettings_LIBRARIES = applist

include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall -9 SpringBoard"

clean::
	rm -f *.deb
