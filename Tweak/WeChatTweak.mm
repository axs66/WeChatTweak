#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

// 配置管理器接口声明
@interface WTConfigManager : NSObject
+ (BOOL)isAntiRevokeEnabled;
@end

// 配置管理器实现
@implementation WTConfigManager

+ (BOOL)isAntiRevokeEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enableAntiRevoke"];
}

@end

// 保存原始函数指针
static void (*original_onRevokeMessage)(id, SEL, id);

// 自定义消息撤回拦截逻辑
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    Class wtConfigClass = NSClassFromString(@"WTConfigManager");
    if (wtConfigClass) {
        SEL antiRevokeSelector = NSSelectorFromString(@"isAntiRevokeEnabled");
        if ([wtConfigClass respondsToSelector:antiRevokeSelector]) {
            BOOL isEnabled = ((BOOL (*)(id, SEL))objc_msgSend)(wtConfigClass, antiRevokeSelector);
            if (isEnabled) {
                NSLog(@"[WeChatTweak] 拦截撤回消息: %@", msg);
                return;
            }
        }
    }
    
    // 执行原始撤回逻辑
    ((void(*)(id, SEL, id))original_onRevokeMessage)(self, _cmd, msg);
}

// 自定义微信多开逻辑
static void tweak_launchNewInstance(void) {
    NSURL *url = [NSURL URLWithString:@"wechat://"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

// 更安全的 Method Swizzling 实现
void swizzleMethod(Class cls, SEL originalSel, SEL swizzledSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    
    BOOL didAddMethod = class_addMethod(cls,
                                        originalSel,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(cls,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

__attribute__((constructor)) static void tweak_init() {
    // 确保在 NSUserDefaults 中有默认设置
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"enableAntiRevoke"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"enableAntiRevoke"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // 替换消息撤回方法
    Class messageServiceCls = objc_getClass("MessageService");
    swizzleMethod(messageServiceCls,
                 @selector(onRevokeMessage:),
                 @selector(tweak_onRevokeMessage:));
    
    // 替换微信启动方法（修正类名）
    Class wechatCls = objc_getClass("WeChat");
    swizzleMethod(wechatCls,
                 @selector(CreateNewInstance),
                 @selector(tweak_launchNewInstance));
    
    // 手动调用 `new_onRevokeMessage` 和 `tweak_launchNewInstance`，确保它们不被视为未使用
    new_onRevokeMessage(nil, nil, nil);  // 仅用于消除警告
    tweak_launchNewInstance();  // 仅用于消除警告
}
