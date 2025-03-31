ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
THEOS_DEVICE_IP = 127.0.0.1  # 替换为你的设备 IP
THEOS_DEVICE_PORT = 2222      # SSH 端口

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak
WeChatTweak_FILES = Tweak.xm
WeChatTweak_FRAMEWORKS = UserNotifications

include $(THEOS_MAKE_PATH)/tweak.mk
