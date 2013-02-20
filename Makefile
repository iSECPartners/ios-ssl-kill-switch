TARGET = iphone:6.1

export ARCHS=armv7
export TARGET=iphone:latest:4.3

include theos/makefiles/common.mk

TWEAK_NAME = SSLKillSwitch
SSLKillSwitch_FILES = Tweak.xm HookedNSURLConnectionDelegate.m

SSLKillSwitch_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk
