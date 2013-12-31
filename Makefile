TARGET := iphone:7.0
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = SSLKillSwitch
SSLKillSwitch_FILES = Tweak.xm

SSLKillSwitch_FRAMEWORKS = UIKit Security
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
