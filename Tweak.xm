#import <Foundation/Foundation.h> // 必须添加！
#import <UIKit/UIKit.h> // 如果需要 UIKit

%hook WCNotificationCenter

- (void)playSound:(id)arg1 {
    %orig;
    
    // 确保 arg1 是 NSObject 子类
    if ([arg1 respondsToSelector:@selector(valueForKey:)]) {
        NSString *soundName = [arg1 valueForKey:@"soundName"];
        if ([soundName isKindOfClass:[NSString class]]) { // 类型检查
            if ([soundName hasSuffix:@"mp"]) {
                soundName = [soundName stringByAppendingString:@"3"];
            }
            // 其他逻辑...
        }
    }
}

%end
