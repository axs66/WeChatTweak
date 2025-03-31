#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

%hook WeChatNotification

- (void)pushNotification:(id)arg1 {
    NSLog(@"[hbbpushfixer] WeChat push notification intercepted: %@", arg1);
    %orig;
}

%end
