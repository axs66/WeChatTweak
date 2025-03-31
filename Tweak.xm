// 1. 必须导入的核心头文件
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

// 2. Hook 微信的推送类（确认实际类名是否为 WCNotificationCenter）
%hook WCNotificationCenter

- (void)playSound:(id)arg1 {
    %orig; // 先调用原始实现
    
    // 3. 类型安全检查
    if (!arg1 || ![arg1 respondsToSelector:@selector(valueForKey:)]) return;
    
    // 4. 获取 soundName
    NSString *soundName = [arg1 valueForKey:@"soundName"];
    if (![soundName isKindOfClass:[NSString class]]) return;
    
    // 5. 移植声音修改逻辑
    NSString *newSoundName = nil;
    if ([soundName hasSuffix:@"mp"]) {
        newSoundName = [soundName stringByAppendingString:@"3"];
    } else if ([soundName isEqualToString:@"building"]) {
        newSoundName = @"buildingBlock.mp3";
    }
    
    // 6. 更新通知声音
    if (newSoundName) {
        UNNotificationSound *customSound = [UNNotificationSound soundNamed:newSoundName];
        if ([arg1 respondsToSelector:@selector(setValue:forKey:)]) {
            [arg1 setValue:customSound forKey:@"sound"];
        }
    }
    
    // 7. 移植每日横幅逻辑
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    NSString *savedDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"todayDate"];
    
    if (![todayStr isEqualToString:savedDate]) {
        if ([arg1 respondsToSelector:@selector(setValue:forKey:)]) {
            [arg1 setValue:@"xxxxxx.com更多有趣插件" forKey:@"subtitle"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:todayStr forKey:@"todayDate"];
    }
}
%end

// 8. 构造函数（可选）
%ctor {
    NSLog(@"[WeChatTweak] Loaded successfully!");
}
