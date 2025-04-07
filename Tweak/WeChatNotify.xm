// --- 导入所需头文件 ---
// 导入 UIKit 以确保识别 UIApplication、UIDevice 等类型
#import <UIKit/UIKit.h>
// 导入 UserNotifications 以确保识别 UNNotificationRequest、UNNotificationSound 等类型
#import <UserNotifications/UserNotifications.h>
// 导入自定义的 SoundMapper，用于音频映射与验证
#import "SoundMapper.h"

// --- Hook: AppDelegate ---
// 利用 Logos 重写 AppDelegate 的 didFinishLaunchingWithOptions: 方法
// 主要用于在应用启动时初始化 SoundMapper 并输出日志
%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    %orig; // 调用原始实现

    // 仅执行一次的初始化操作：注册默认的音频映射
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [SoundMapper registerDefaultMappings];
    });

    // 输出日志，显示插件已加载及当前设备的 SDK 版本
    NSLog(@"[WeChatTweak] 插件已加载 | SDK版本: %@", [[UIDevice currentDevice] systemVersion]);
    return YES;
}

%end

// --- Hook: NotificationServiceExtension ---
// 利用 Logos 重写 NotificationServiceExtension 的 didReceiveNotificationRequest:withContentHandler: 方法
// 主要用于拦截通知并替换提示音
%hook NotificationServiceExtension

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request 
                   withContentHandler:(void (^)(UNNotificationContent *))contentHandler {

    // --- 提取原始提示音 ---
    // 如果 request.content.sound 为 NSString 类型则直接使用，否则使用默认提示音 "default"
    NSString *originalSound = nil;
    if ([request.content.sound isKindOfClass:[NSString class]]) {
        originalSound = (NSString *)request.content.sound;
    } else {
        originalSound = @"default";
    }
    
    // --- 应用音频映射 ---
    // 使用 SoundMapper 映射原始提示音
    NSString *mappedSound = [SoundMapper mapSoundName:originalSound];
    // 如果映射后的声音文件验证失败，则回退到原始提示音
    if (![SoundMapper validateSoundFile:mappedSound]) {
        mappedSound = originalSound;
    }
    
    // --- 构造处理通知内容的 block ---
    // 将用于处理通知内容的 block 存储到局部变量，避免 Logos 预处理器解析复杂 block 时出错
    void (^handlerBlock)(UNNotificationContent *content) = ^(UNNotificationContent *content) {
        @autoreleasepool {
            // 创建通知内容的可变副本
            UNMutableNotificationContent *modifiedContent = [content mutableCopy];
            // 如果映射后的提示音存在，则更新通知的声音并输出日志
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
    // 传入 request 与我们构造的 handlerBlock，完成对通知内容的修改
    %orig(request, handlerBlock);
}

%end
