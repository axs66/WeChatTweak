ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak
WeChatTweak_FILES = Tweak.xm
WeChatTweak_FRAMEWORKS = Foundation UIKit UserNotifications
WeChatTweak_CFLAGS = -fobjc-arc  # 启用 ARC（如果代码需要）

# 指定 plist 文件路径
WeChatTweak_PLIST_FILES = WeChatTweak.plist

include $(THEOS_MAKE_PATH)/tweak.mk
