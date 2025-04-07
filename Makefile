ARCHS = arm64 arm64e          # 适配Apple芯片
TARGET = iphone:latest:13.0   # 最低支持iOS 13
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak

WeChatTweak_FILES = Tweak/WeChatNotify.xm Tweak/SoundMapper.m
WeChatTweak_CFLAGS = -fobjc-arc
WeChatTweak_EXTRA_FRAMEWORKS = UserNotifications
WeChatTweak_RESOURCE_BUNDLES = Tweak/Resources/WeChatTweak.bundle

include $(THEOS_MAKE_PATH)/tweak.mk
