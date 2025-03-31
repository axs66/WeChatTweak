#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

%hook WCNotificationCenter

- (void)playSound:(id)arg1 {
    %orig;
    
    // 1. 移植声音修改逻辑
    NSString *soundName = [arg1 valueForKey:@"soundName"];
    if ([soundName hasSuffix:@"mp"]) {
        soundName = [soundName stringByAppendingString:@"3"];
    }
    // ...（其他逻辑参考之前的回复）

    // 2. 移植每日横幅逻辑
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMdd";
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    NSString *savedDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"todayDate"];
    if (![todayStr isEqualToString:savedDate]) {
        [arg1 setValue:@"xxxxxx.com更多有趣插件" forKey:@"subtitle"];
        [[NSUserDefaults standardUserDefaults] setObject:todayStr forKey:@"todayDate"];
    }
}

%end
