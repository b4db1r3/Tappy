TARGET := iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = tappysettings

tappysettings_FILES = TTSRootListController.m
tappysettings_FRAMEWORKS = UIKit
tappysettings_PRIVATE_FRAMEWORKS = Preferences
tappysettings_INSTALL_PATH = /Library/PreferenceBundles
tappysettings_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
