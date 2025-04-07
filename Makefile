# Makefile for WeChatTweak

# 构建的架构
ARCHS = arm64

# 设置目标平台为 iPhone，使用最新的 Clang 编译器
TARGET = iphone:clang:latest:latest

# 引入 THEOS 公共 makefile 配置
include $(THEOS)/makefiles/common.mk

# 定义 Tweak 名称
TWEAK_NAME = WeChatTweak

# Tweak 的源文件
WeChatTweak_FILES = WeChatTweak.mm \
                    Tweak/WeChatNotify.xm \
                    Tweak/SoundMapper.m
                    Tweak/fishhook.c

# Tweak 需要链接的框架
WeChatTweak_FRAMEWORKS = UIKit Foundation UserNotifications

# 私有框架，如果有需要，可以加入
WeChatTweak_PRIVATE_FRAMEWORKS = SpringBoardServices

# 使用的库（如果需要）
WeChatTweak_LIBRARIES = c++

# 引入 THEOS 的 tweak.mk 文件
include $(THEOS)/makefiles/tweak.mk
