#  DYYY
#
#  Copyright (c) 2024 huami. All rights reserved.
#  Channel: @huamidev
#  Created on: 2024/10/04
#

TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

export THEOS ?= $(HOME)/theos
export DEBUG = 0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WCEnhance

WCEnhance_FILES = WCEnhance.xm
WCEnhance_CFLAGS = -fobjc-arc -Wno-error
WCEnhance_LOGOS_DEFAULT_GENERATOR = internal

export THEOS_STRICT_LOGOS=0
export ERROR_ON_WARNINGS=0
export LOGOS_DEFAULT_GENERATOR=internal

include $(THEOS_MAKE_PATH)/tweak.mk

# 确保可以正确打包 deb
after-install::
	install.exec "killall -9 WeChat"

SUBPROJECTS += WCEnhance
include $(THEOS_MAKE_PATH)/aggregate.mk
