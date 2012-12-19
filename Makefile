TARGET = iphone:5.1
include theos/makefiles/common.mk

TWEAK_NAME = SSLKillSwitch
SSLKillSwitch_FILES = Tweak.xm HookedNSURLConnectionDelegate.m

SSLKillSwitch_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
