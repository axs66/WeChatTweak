#import "SoundMapper.h"
#import <UserNotifications/UserNotifications.h>

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    
    // 初始化音频映射配置
    [SoundMapper registerDefaultMappings];
    
    // 调试日志
    NSLog(@"[WeChatTweak] App launched with options: %@", launchOptions);
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
    
    %orig(request, ^(UNNotificationContent *content) {
        // 修改通知内容
        UNMutableNotificationContent *modifiedContent = [content mutableCopy];
        
        // 设置自定义提示音
        if (mappedSound) {
            modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
            
            // 调试日志
            NSLog(@"[WeChatTweak] Modified sound from %@ to %@", 
                  originalSound, 
                  mappedSound);
        }
        
        contentHandler(modifiedContent);
    });
}

%end
