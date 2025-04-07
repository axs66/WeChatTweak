#import "WeChatTweak.h"
#import <objc/runtime.h>
#import <objc/message.h>

// 如果你要用 fishhook，可以保留，否则可以删除 fishhook 的引用
//#import "fishhook.h"

// 替换微信原始方法
static void (*original_onRevokeMessage)(id, SEL, id);
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    if (![WTConfigManager isAntiRevokeEnabled]) {
        original_onRevokeMessage(self, _cmd, msg);  // 调用原撤回逻辑
        return;
    }
    // 自定义逻辑：阻止撤回并高亮显示
    NSLog(@"[WeChatTweak] 拦截撤回消息: %@", msg);
}

// 初始化 Hook
__attribute__((constructor)) static void tweak_init() {
    Class cls = objc_getClass("MessageService");
    if (cls && class_getInstanceMethod(cls, @selector(onRevokeMessage:))) {
        Method origMethod = class_getInstanceMethod(cls, @selector(onRevokeMessage:));
        
        // 保留原方法实现地址
        original_onRevokeMessage = (void *)method_getImplementation(origMethod);
        
        // 替换为新方法
        method_setImplementation(origMethod, (IMP)new_onRevokeMessage);
        
        NSLog(@"[WeChatTweak] onRevokeMessage: Hook 成功");
    } else {
        NSLog(@"[WeChatTweak] ❌ 找不到 MessageService 或 onRevokeMessage: 方法");
    }
}
