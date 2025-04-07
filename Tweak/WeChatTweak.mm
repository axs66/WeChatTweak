#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// 替换微信原始方法
static void (*original_onRevokeMessage)(id, SEL, id);
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    // 获取 WTConfigManager 并检查是否启用反撤回功能
    id configManagerClass = NSClassFromString(@"WTConfigManager");
    SEL isAntiRevokeSelector = NSSelectorFromString(@"isAntiRevokeEnabled");
    if ([configManagerClass respondsToSelector:isAntiRevokeSelector]) {
        if (![configManagerClass performSelector:isAntiRevokeSelector]) {
            original_onRevokeMessage(self, _cmd, msg);  // 调用原撤回逻辑
            return;
        }
    } else {
        original_onRevokeMessage(self, _cmd, msg);  // 如果没有该方法，则执行原逻辑
        return;
    }
    
    // 自定义逻辑：阻止撤回并高亮显示
    NSLog(@"拦截撤回消息: %@", msg);
}

// 多开逻辑
static void tweak_launchNewInstance(void) {
    // iOS 上的启动方式
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:@"wechat://"] options:@{} completionHandler:nil];
}

// 初始化 Hook
__attribute__((constructor)) static void tweak_init() {
    // 替换消息撤回方法
    Class cls = objc_getClass("MessageService");
    method_exchangeImplementations(
        class_getInstanceMethod(cls, @selector(onRevokeMessage:)),
        class_getInstanceMethod(cls, @selector(tweak_onRevokeMessage:))
    );
    
    // 替换多开方法
    Class weChatClass = objc_getClass("WeChatClass");
    method_exchangeImplementations(
        class_getInstanceMethod(weChatClass, @selector(createNewInstance)),
        class_getInstanceMethod(weChatClass, @selector(tweak_launchNewInstance))
    );
}
