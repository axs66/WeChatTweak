TARGET := iphone:clang:latest:10.0
INSTALL_TARGET_PROCESSES = WeChat

TWEAK_NAME = WeChatTweak

WeChatTweak_FILES = Tweak/WeChatTweak.mm Tweak/WeChatNotify.xm Tweak/SoundMapper.m
WeChatTweak_FILES += Tweak/fishhook.c
WeChatTweak_FRAMEWORKS = Foundation UIKit UserNotifications
WeChatTweak_PRIVATE_FRAMEWORKS = AppSupport
WeChatTweak_LDFLAGS += -lobjc -lc++
WeChatTweak_CFLAGS += -std=c++17

include $(THEOS_MAKE_PATH)/tweak.mk
