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
    
    // 原始声音处理（空值保护）
    NSString *originalSound = request.content.sound ?: @"default";
    
    // 应用自定义映射规则（带文件存在性验证）
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound];
    if (![SoundMapper validateSoundFile:mappedSound]) {
        mappedSound = originalSound;
    }
    
    // 严格符合Logos语法的%orig调用
    %orig(request, ^(UNNotificationContent *content) {  // ← 第35行起始
        @autoreleasepool {
            UNMutableNotificationContent *modifiedContent = [content mutableCopy];
            
            // 线程安全的声音设置
            if (mappedSound) {
                modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
                NSLog(@"[WeChatTweak] 提示音修改成功 | 原始: %@ → 新: %@", originalSound, mappedSound);
            }
            
            contentHandler([modifiedContent copy]);  // ← 第43行闭合
        }
    });  // ← 第45行：严格闭合所有括号
}

%end
