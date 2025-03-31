ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak
WeChatTweak_FILES = Tweak.xm
WeChatTweak_FRAMEWORKS = Foundation UserNotifications
WeChatTweak_PLIST_FILES = WeChatTweak.plist

# 无根越狱专用路径配置
WeChatTweak_INSTALL_PATH = /var/jb/Library/Application Support/WeChatTweak

# 如果是Theos最新版，可直接用以下变量适配无根越狱
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS_MAKE_PATH)/tweak.mk
