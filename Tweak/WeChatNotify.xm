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

%hook NotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request 
                   withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    
    // 原始声音处理
    NSString *originalSound = request.content.sound;
    
    // 应用自定义映射规则
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound] ?: originalSound;
    
    // 严格符合规范的%orig调用格式
    %orig(request, ^(UNNotificationContent *content) {  // ← 第37行起始
        @autoreleasepool {
            UNMutableNotificationContent *modifiedContent = [content mutableCopy];
            modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
            contentHandler([modifiedContent copy]);  // ← 确保所有括号闭合
        }
    });  // ← 第43行：严格闭合所有括号
}

%end
