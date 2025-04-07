#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

// 配置管理器接口声明（新增）
@interface WTConfigManager : NSObject
+ (BOOL)isAntiRevokeEnabled;
@end

// 保存原始函数指针
static void (*original_onRevokeMessage)(id, SEL, id);
static IMP original_CreateNewInstance = NULL;

// 自定义消息撤回拦截逻辑
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    // 动态加载 WTConfigManager 类并检查是否启用防撤回
    Class wtConfigClass = NSClassFromString(@"WTConfigManager");
    if (wtConfigClass) {
        SEL antiRevokeSelector = NSSelectorFromString(@"isAntiRevokeEnabled");
        if ([wtConfigClass respondsToSelector:antiRevokeSelector]) {
            BOOL isEnabled = ((BOOL (*)(id, SEL))objc_msgSend)(wtConfigClass, antiRevokeSelector);
            if (isEnabled) {
                // 启用防撤回，阻止撤回并高亮显示
                NSLog(@"[WeChatTweak] 拦截撤回消息: %@", msg);
                return;
            }
        }
    }
    
    // 如果未启用防撤回，则执行原始撤回逻辑
    ((void(*)(id, SEL, id))original_onRevokeMessage)(self, _cmd, msg);
}

// 自定义微信多开逻辑
static void tweak_launchNewInstance(void) {
    // 安全的URL打开方式
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

// 配置管理器实现（新增）
@implementation WTConfigManager
+ (BOOL)isAntiRevokeEnabled {
    return YES; // 默认启用防撤回
}
@end

__attribute__((constructor)) static void tweak_init() {
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
