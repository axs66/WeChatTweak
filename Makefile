ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak
WeChatTweak_FILES = Tweak.xm
WeChatTweak_FRAMEWORKS = Foundation UIKit UserNotifications # 添加必要的框架

include $(THEOS_MAKE_PATH)/tweak.mk
