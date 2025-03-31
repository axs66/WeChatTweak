ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak
WeChatTweak_FILES = Tweak.xm
WeChatTweak_FRAMEWORKS = Foundation UIKit UserNotifications # 关键：添加所需框架
WeChatTweak_PRIVATE_FRAMEWORKS = UserNotifications # 如果是私有框架

include $(THEOS_MAKE_PATH)/tweak.mk
