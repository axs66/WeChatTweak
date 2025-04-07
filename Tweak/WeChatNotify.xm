#import "SoundMapper.h"
#import <UserNotifications/UserNotifications.h>

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;

    // 初始化音频映射配置（线程安全）
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SoundMapper registerDefaultMappings];
    });

    // 增强型调试日志
    NSLog(@"[WeChatTweak] 插件已加载 | 版本: 1.2.3 | SDK: %@", [[UIDevice currentDevice] systemVersion]);
    return YES;
}

%end
