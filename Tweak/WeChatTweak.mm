#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// 保存原始函数指针
static void (*original_onRevokeMessage)(id, SEL, id);
static void (*original_CreateNewInstance)(void);

// 自定义消息撤回拦截逻辑
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    if (![NSClassFromString(@"WTConfigManager") isAntiRevokeEnabled]) {
        original_onRevokeMessage(self, _cmd, msg);  // 调用原撤回逻辑
        return;
    }
    // 自定义逻辑：阻止撤回并高亮显示
    NSLog(@"拦截撤回消息: %@", msg);
}

// 自定义微信多开逻辑
static void tweak_launchNewInstance(void) {
    // iOS 环境下启动应用的正确方式（替代了 deprecated 方法）
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"wechat://"]
                                         options:@{}
                               completionHandler:nil];
}

// 使用 Method Swizzling 交换方法
void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    // 如果 class 没有实现原方法，则添加新的实现
    if (!originalMethod) {
        method_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    } else {
        // 否则交换实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// 初始化 Hook（通过 constructor 注解保证函数在启动时调用）
__attribute__((constructor)) static void tweak_init() {
    // 初始化时直接调用 new_onRevokeMessage 和 tweak_launchNewInstance，确保它们被使用
    new_onRevokeMessage(nil, nil, nil);
    tweak_launchNewInstance();

    // 替换消息撤回方法
    Class cls = objc_getClass("MessageService");
    swizzleMethod(cls, @selector(onRevokeMessage:), @selector(tweak_onRevokeMessage:));

    // 替换微信启动方法
    Class wechatClass = objc_getClass("WeChatClass");
    swizzleMethod(wechatClass, @selector(CreateNewInstance), @selector(tweak_launchNewInstance));
}
