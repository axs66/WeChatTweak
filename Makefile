ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak
WeChatTweak_FILES = Tweak.xm
WeChatTweak_FRAMEWORKS = Foundation UserNotifications
WeChatTweak_PLIST_FILES = WeChatTweak.plist

# 资源文件安装路径
WeChatTweak_INSTALL_PATH = /Library/Application Support/WeChatTweak

include $(THEOS_MAKE_PATH)/tweak.mk
