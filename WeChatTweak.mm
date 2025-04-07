#import "WeChatTweak.h"
#import <objc/runtime.h>
#import "fishhook.h"

// 替换微信原始方法
static void (*original_onRevokeMessage)(id, SEL, id);
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    if (![WTConfigManager isAntiRevokeEnabled]) {
        original_onRevokeMessage(self, _cmd, msg);  // 调用原撤回逻辑
        return;
    }
    // 自定义逻辑：阻止撤回并高亮显示
    NSLog(@"拦截撤回消息: %@", msg);
}

// 多开逻辑
static void tweak_launchNewInstance(id self, SEL _cmd) {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace launchApplication:@"/Applications/WeChat.app"];
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
    rebind_symbols((struct rebinding[1]){
        {"_Z15CreateNewInstancev", (void*)tweak_launchNewInstance, (void**)&original_CreateNewInstance}
    }, 1);
}
