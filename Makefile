TARGET := iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard
FINAL_PACKAGE=1
THEOS_PACKAGE_SCHEME=rootless
PACKAGE_VERSION = 1.5



include $(THEOS)/makefiles/common.mk

TWEAK_NAME = tappy

tappy_FILES = Tweak.x
tappy_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += tappysettings
include $(THEOS_MAKE_PATH)/aggregate.mk
