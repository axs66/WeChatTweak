#import "SoundMapper.h"
#import <UserNotifications/UserNotifications.h>

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SoundMapper registerDefaultMappings];
    });

    NSLog(@"[WeChatTweak] 插件已加载 | SDK版本: %@", [[UIDevice currentDevice] systemVersion]);
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
                NSLog(@"[WeChatTweak] 通知声音已替换: %@ → %@", originalSound, mappedSound);
            }

            if ([modifiedContent respondsToSelector:@selector(copy)]) {
                contentHandler([modifiedContent copy]); // 修正闭合
            } else {
                contentHandler(content);
            }
        }
    });
}

%end
