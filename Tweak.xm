// Tweak.xm（Objective-C + Logos 语法）
%hook WCNotificationCenter // 假设微信的推送类名是 WCNotificationCenter

- (void)playSound:(id)arg1 {
    %orig; // 调用原方法
    
    // 移植你的 Swift 逻辑到 Objective-C
    NSString *soundName = [arg1 valueForKey:@"soundName"];
    if ([soundName hasSuffix:@"mp"]) {
        soundName = [soundName stringByAppendingString:@"3"];
    }
    // 其他逻辑...
}

%end
