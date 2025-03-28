#
#  DYYY
#
#  Copyright (c) 2024 huami. All rights reserved.
#  Channel: @huamidev
#  Created on: 2024/10/04
#

TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

# export THEOS=/Users/huami/theos
# export THEOS_PACKAGE_SCHEME=roothide
export DEBUG = 0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WCEnhance

WCEnhance_FILES = WCEnhance.xm
WCEnhanceCFLAGS = -fobjc-arc -Wno-error
WCEnhance_LOGOS_DEFAULT_GENERATOR = internal

export THEOS_STRICT_LOGOS=0
export ERROR_ON_WARNINGS=0
export LOGOS_DEFAULT_GENERATOR=internal

include $(THEOS_MAKE_PATH)/tweak.mk
