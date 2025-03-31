%hook WCNotificationCenter // Hook微信的推送类（需确认实际类名）

- (void)playSound:(id)arg1 {
    %orig; // 先执行原始方法
    
    // 1. 获取soundName（假设arg1是通知对象）
    NSString *soundName = [arg1 valueForKey:@"soundName"];
    if (![soundName isKindOfClass:[NSString class]]) return;
    
    // 2. 移植声音修改逻辑
    NSString *newSoundName = nil;
    if ([soundName hasSuffix:@"mp"]) {
        newSoundName = [soundName stringByAppendingString:@"3"];
    } else if ([soundName isEqualToString:@"building"]) {
        newSoundName = @"buildingBlock.mp3";
    }
    
    // 3. 更新声音
    if (newSoundName) {
        UNNotificationSound *customSound = [UNNotificationSound soundNamed:newSoundName];
        [arg1 setValue:customSound forKey:@"sound"];
    }
    
    // 4. 移植每日横幅逻辑
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    NSString *savedDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"todayDate"];
    
    if (![todayStr isEqualToString:savedDate]) {
        [arg1 setValue:@"xxxxxx.com更多有趣插件" forKey:@"subtitle"];
        [[NSUserDefaults standardUserDefaults] setObject:todayStr forKey:@"todayDate"];
    }
}
%end
