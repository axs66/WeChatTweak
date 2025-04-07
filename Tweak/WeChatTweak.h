#import <Foundation/Foundation.h>

// 声明插件配置管理类
@interface WTConfigManager : NSObject
+ (BOOL)isAntiRevokeEnabled;  // 防撤回开关
+ (BOOL)isMultiInstanceEnabled;  // 多开开关
@end

// Hook 方法声明
@interface NSObject (WeChatTweak)
- (void)tweak_onRevokeMessage:(id)msg;  // 拦截消息撤回
- (void)tweak_launchNewInstance;  // 启动新微信实例
@end
