#import "SoundMapper.h"

%hook AppDelegate

// 注入微信启动初始化
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    
    // 初始化音频映射规则
    [SoundMapper registerDefaultMappings];
    return YES;
}

%end

%hook UNNotificationServiceExtension

// 处理推送通知
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *))contentHandler {
    // 原始声音处理
    NSString *originalSound = request.content.sound;
    
    // 应用自定义映射规则
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound];
    
    %orig(request, ^(UNNotificationContent *content){
        // 修改后的声音设置
        UNMutableNotificationContent *modifiedContent = [content mutableCopy];
        modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
        contentHandler(modifiedContent);
    });
}

%end
