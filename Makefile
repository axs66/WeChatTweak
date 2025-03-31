THEOS_PACKAGE_DIR_NAME = debs
TARGET = iphone:clang:latest:13.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = hbbpushfixer

hbbpushfixer_FILES = Tweak.xm
hbbpushfixer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
