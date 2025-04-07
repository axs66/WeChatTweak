// --- 导入所需头文件 ---
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "SoundMapper.h"

// --- Hook: AppDelegate ---
%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig;

    // 仅执行一次的初始化操作：注册默认的音频映射
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SoundMapper registerDefaultMappings];
    });

    NSLog(@"[WeChatTweak] 插件已加载 | SDK版本: %@", [[UIDevice currentDevice] systemVersion]);
    return YES;
}

%end

// --- Hook: NotificationServiceExtension ---
// 主要用于拦截通知并替换提示音，同时打印通知的详细信息
%hook NotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request 
                   withContentHandler:(void (^)(UNNotificationContent *))contentHandler {

    // --- 提取原始提示音 ---
    NSString *originalSound = nil;
    if ([request.content.sound isKindOfClass:[NSString class]]) {
        originalSound = (NSString *)request.content.sound;
    } else {
        originalSound = @"default";
    }
    
    // --- 应用音频映射 ---
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound];
    if (![SoundMapper validateSoundFile:mappedSound]) {
        mappedSound = originalSound;
    }

    // --- 打印通知详情 ---
    NSLog(@"[WeChatTweak] 收到通知详情：");
    NSLog(@"标题: %@", request.content.title ?: @"无标题");
    NSLog(@"正文: %@", request.content.body ?: @"无正文");
    NSLog(@"声音: %@", originalSound);
    NSLog(@"自定义声音: %@", mappedSound);

    // --- 处理通知内容的 block ---
    void (^handlerBlock)(UNNotificationContent *content) = ^(UNNotificationContent *content) {
        @autoreleasepool {
            // 创建通知内容的可变副本
            UNMutableNotificationContent *modifiedContent = [content mutableCopy];
            // 如果映射后的提示音存在，则更新通知的声音
            if (mappedSound) {
                modifiedContent.sound = [UNNotificationSound soundNamed:mappedSound];
                NSLog(@"[WeChatTweak] 通知声音已替换: %@ -> %@", originalSound, mappedSound);
            }

            // 调用 contentHandler 传递处理后的通知内容
            if ([modifiedContent respondsToSelector:@selector(copy)]) {
                contentHandler([modifiedContent copy]);
            } else {
                contentHandler(content);
            }
        }
    };

    // --- 调用原始方法 ---
    %orig(request, handlerBlock);
}

%end
