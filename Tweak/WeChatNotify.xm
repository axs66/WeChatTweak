#import "SoundMapper.h"
#import <UserNotifications/UserNotifications.h>

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    
    // 初始化音频映射配置
    [SoundMapper registerDefaultMappings];
    
    // 调试日志（增加安全校验）
    if (launchOptions) {
        NSLog(@"[WeChatTweak] App launched with options: %@", launchOptions);
    } else {
        NSLog(@"[WeChatTweak] App launched without options");
    }
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
    
    // 关键修复点：补全方法调用括号
    %orig(request, ^(UNNotificationContent *content) {  // ← 第35行补全括号
        UNMutableNotificationContent *modifiedContent = [content mutableCopy];
        
        // 设置自定义提示音
        if (mappedSound) {
            modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
            NSLog(@"[WeChatTweak] 提示音已修改: %@ -> %@", originalSound, mappedSound);
        }
        
        contentHandler([modifiedContent copy]);
    });  // ← 补全方法调用闭合括号
}

%end
