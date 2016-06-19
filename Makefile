SDKVERSION = 7.0
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ScreenshotFS
ScreenshotFS_FILES = Switch.xm
ScreenshotFS_FRAMEWORKS = UIKit
ScreenshotFS_LIBRARIES = flipswitch
ScreenshotFS_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk