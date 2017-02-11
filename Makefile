TARGET = iphone:latest:8.0

PACKAGE_VERSION = 0.0.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ScreenshotFS
ScreenshotFS_FILES = Switch.xm
ScreenshotFS_FRAMEWORKS = UIKit
ScreenshotFS_LIBRARIES = flipswitch
ScreenshotFS_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk