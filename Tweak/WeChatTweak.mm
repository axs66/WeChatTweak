#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "fishhook.h"

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
    // 启动新的 WeChat 实例
    [[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/WeChat.app"];
}

// 初始化 Hook（通过 constructor 注解保证函数在启动时调用）
__attribute__((constructor)) static void tweak_init() {
    // 确保函数被调用
    new_onRevokeMessage(nil, nil, nil);  // 调用 new_onRevokeMessage，虽然没有实际逻辑
    tweak_launchNewInstance();  // 调用 tweak_launchNewInstance，虽然没有实际逻辑

    // 替换消息撤回方法
    Class cls = objc_getClass("MessageService");
    method_exchangeImplementations(
        class_getInstanceMethod(cls, @selector(onRevokeMessage:)),
        class_getInstanceMethod(cls, @selector(tweak_onRevokeMessage:))
    );
    
    // 定义 rebinding 结构体，并且传递正确的指针
    struct rebinding {
        const char *name;
        void *replacement;
        void **replaced;
    };
    
    struct rebinding rebindings[] = {
        {"_Z15CreateNewInstancev", (void*)tweak_launchNewInstance, (void**)&original_CreateNewInstance}
    };

    // 传递 rebinding 数组的指针给 rebind_symbols
    rebind_symbols(rebindings, 1);
}
