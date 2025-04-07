# 基本环境配置
ARCHS = arm64 arm64e          # 适配 Apple A12+ 芯片设备
TARGET = iphone:clang:latest:15.0  # 目标iOS 15.0+系统
INSTALL_TARGET_PROCESSES = WeChat # 目标注入进程

# 工程配置
FINALPACKAGE = 1              # 生成完整DEB包
DEBUG = 0                     # 发布模式
GO_EASY_ON_ME = 1             # 忽略部分编译警告

# 文件包含配置
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatTweak      # 插件名称

# 源码文件配置
WeChatTweak_FILES = \
  Tweak/WeChatNotify.xm \
  Tweak/SoundMapper.m \
  Tweak/WeChatTweak.mm

# 头文件路径
WeChatTweak_HEADER_FILES = \
  Tweak/SoundMapper.h \
  Tweak/WeChatTweak.h

# 资源文件配置
WeChatTweak_RESOURCE_BUNDLES = WeChatTweak
WeChatTweak_RESOURCE_DIRS = Resources/

# 编译参数
WeChatTweak_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
WeChatTweak_LDFLAGS = -Wl,-segalign,4000
TweakName_FILES = Tweak/WeChatNotify.xm Tweak/SoundMapper.m Tweak/WeChatTweak.mm Tweak/fishhook.c

# 框架依赖
WeChatTweak_FRAMEWORKS = UIKit UserNotifications
WeChatTweak_PRIVATE_FRAMEWORKS = AppSupport ChatKit
WeChatTweak_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
WeChatTweak_LDFLAGS = -Wl,-segalign,4000

# 签名配置 (适用于越狱环境)
WeChatTweak_CODESIGN_FLAGS = -Sentitlements.plist

include $(THEOS_MAKE_PATH)/tweak.mk

# 自定义安装任务
after-install::
  # 重载插件
  install.exec "killall -9 WeChat || :"
