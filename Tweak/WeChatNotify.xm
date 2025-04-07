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
    %orig(request, ^(UNNotificationContent *content) {
        // 修改通知内容
        UNMutableNotificationContent *modifiedContent = [content mutableCopy];
        
        // 设置自定义提示音（增加文件存在性校验）
        if (mappedSound && [SoundMapper validateSoundFile:mappedSound]) {
            modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
            
            NSLog(@"[WeChatTweak] 提示音已修改: %@ -> %@", 
                  originalSound, 
                  mappedSound);
        } else {
            NSLog(@"[WeChatTweak] 使用默认提示音: %@", originalSound);
        }
        
        contentHandler([modifiedContent copy]); // 保证线程安全
    }); // 补全方法调用闭合括号
}

%end
