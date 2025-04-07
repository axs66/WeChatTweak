#import "SoundMapper.h"
#import <UserNotifications/UserNotifications.h>

// --- Hook: AppDelegate ---
// 重写 didFinishLaunchingWithOptions: 方法，在应用启动时注册 SoundMapper 并输出日志
%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;
    
    // 仅执行一次的初始化操作
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SoundMapper registerDefaultMappings];
    });
    
    NSLog(@"[WeChatTweak] 插件已加载 | SDK版本: %@", [[UIDevice currentDevice] systemVersion]);
    return YES;
}

%end

// --- Hook: NotificationServiceExtension ---
// 重写 didReceiveNotificationRequest:withContentHandler: 方法，修改通知内容（如替换提示音）
%hook NotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request 
                   withContentHandler:(void (^)(UNNotificationContent *content))contentHandler {
    
    // 获取原始声音，如果为空则使用 "default"
    NSString *originalSound = request.content.sound ?: @"default";
    // 应用自定义映射规则获取新提示音
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound];
    // 如果映射后的文件验证失败，则使用原始声音
    if (![SoundMapper validateSoundFile:mappedSound]) {
        mappedSound = originalSound;
    }
    
    // 将 block 存储到局部变量中，避免 Logos 预处理器解析括号错误
    void (^handlerBlock)(UNNotificationContent *content) = ^(UNNotificationContent *content) {
        @autoreleasepool {
            // 创建通知内容的可变副本
            UNMutableNotificationContent *modifiedContent = [content mutableCopy];
            // 如果有映射的新声音，则更新通知声音并记录日志
            if (mappedSound) {
                modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
                NSLog(@"[WeChatTweak] 通知声音已替换: %@ -> %@", originalSound, mappedSound);
            }
            // 调用 contentHandler，优先传入可复制的内容
            if ([modifiedContent respondsToSelector:@selector(copy)]) {
                contentHandler([modifiedContent copy]);
            } else {
                contentHandler(content);
            }
        }
    };
    
    // 调用原始方法，同时传入我们自定义的 block
    %orig(request, handlerBlock);
}

%end
