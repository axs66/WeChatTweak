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
    
    NSString *originalSound = request.content.sound ?: @"default";
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound];
    if (![SoundMapper validateSoundFile:mappedSound]) {
        mappedSound = originalSound;
    }

    %orig(request, ^(UNNotificationContent *content) {
        @autoreleasepool {
            UNMutableNotificationContent *modifiedContent = [content mutableCopy];

            if (mappedSound) {
                modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
                NSLog(@"[WeChatTweak] 提示音修改成功 | 原始: %@ → 新: %@", originalSound, mappedSound);
            }

            if ([modifiedContent respondsToSelector:@selector(copy)]) {
                contentHandler([modifiedContent copy]);
            } else {
                contentHandler(content);
            }
        }
    });
}

%end

