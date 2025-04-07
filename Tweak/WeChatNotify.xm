#import "SoundMapper.h"

%hook AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    NSLog(@"App launched with options: %@", launchOptions);
    return YES;
}  // 添加闭合花括号
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
