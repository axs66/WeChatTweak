#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "fishhook.h"

// 撤回消息拦截
static void (*original_onRevokeMessage)(id, SEL, id) = NULL;
static void new_onRevokeMessage(id self, SEL _cmd, id msg) {
    if (![NSClassFromString(@"WTConfigManager") isAntiRevokeEnabled]) {
        original_onRevokeMessage(self, _cmd, msg);
        return;
    }
    NSLog(@"[WeChatTweak] 拦截撤回消息: %@", msg);
}

// 退群提醒逻辑（假设类名为 GroupManager）
static void (*original_removeMember)(id, SEL, id, id) = NULL;
static void new_removeMember(id self, SEL _cmd, id group, id user) {
    NSLog(@"[WeChatTweak] 成员 %@ 被移出群组 %@", user, group);
    original_removeMember(self, _cmd, group, user);
}

// 微信多开（fishhook 替换符号）
static void tweak_launchNewInstance(void) {
    NSLog(@"[WeChatTweak] 执行多开");
    [[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/WeChat.app"];
}

// fishhook 替换符号存储
static void (*original_CreateNewInstance)(void);

// 初始化
__attribute__((constructor)) static void tweak_init() {
    // Hook 撤回消息
    Class messageService = objc_getClass("MessageService");
    Method orig = class_getInstanceMethod(messageService, @selector(onRevokeMessage:));
    original_onRevokeMessage = reinterpret_cast<void (*)(id, SEL, id)>(method_getImplementation(orig));
    method_setImplementation(orig, (IMP)new_onRevokeMessage);

    // Hook 退群提醒（仅作示例，需确认真实类名/方法）
    Class groupMgr = objc_getClass("GroupManager");
    Method removeM = class_getInstanceMethod(groupMgr, @selector(removeMember:fromGroup:));
    original_removeMember = reinterpret_cast<void (*)(id, SEL, id, id)>(method_getImplementation(removeM));
    method_setImplementation(removeM, (IMP)new_removeMember);

    // 替换微信多开方法
    rebind_symbols((struct rebinding[1]){
        {"_Z15CreateNewInstancev", (void *)tweak_launchNewInstance, (void **)&original_CreateNewInstance}
    }, 1);
}
