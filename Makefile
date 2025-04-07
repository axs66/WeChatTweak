# Makefile for WeChatTweak
# -------------------------
# 构建的架构：此处指定为 arm64（适用于大部分 iOS 设备）
ARCHS = arm64

# 设置目标平台为 iPhone，使用最新的 Clang 编译器
TARGET = iphone:clang:latest:latest

# 引入 THEOS 公共 makefile 配置
include $(THEOS)/makefiles/common.mk

# 定义 Tweak 的名称（生成的动态库将使用此名称）
TWEAK_NAME = WeChatTweak

# 列出 Tweak 的源文件
# 这些文件将被编译成最终的动态库
WeChatTweak_FILES = Tweak/WeChatTweak.mm \
                    Tweak/WeChatNotify.xm \
                    Tweak/SoundMapper.m
# 追加 fishhook.c 文件（用于符号重绑定功能）
WeChatTweak_FILES += Tweak/fishhook.c

# 指定 Tweak 需要链接的系统框架
WeChatTweak_FRAMEWORKS = UIKit Foundation UserNotifications

# 私有框架（如果需要使用私有 API，可在此处添加）
# 目前 SpringBoardServices 框架可能在你的环境中不存在，所以暂时注释掉
# WeChatTweak_PRIVATE_FRAMEWORKS = SpringBoardServices

# 指定需要链接的库
WeChatTweak_LIBRARIES = c++

# 引入 THEOS 的 tweak.mk 文件，用于定义构建规则
include $(THEOS)/makefiles/tweak.mk
