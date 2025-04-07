#import "SoundMapper.h"
#import <UIKit/UIKit.h>

static NSDictionary<NSString *, NSString *> *_soundMappings;
static NSBundle *_resourceBundle;

@implementation SoundMapper

+ (void)initialize {
    if (self == [SoundMapper class]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"WeChatTweak" ofType:@"bundle"];
        _resourceBundle = [NSBundle bundleWithPath:bundlePath];
        [self registerDefaultMappings];
    }
}

+ (void)registerDefaultMappings {
    _soundMappings = @{
        @"default": @"custom_notify",
        @"msg": @"new_message",
        @"system": @"system_alert"
    };
}

+ (NSString *)mapSoundName:(NSString *)originalName {
    return _soundMappings[originalName] ?: originalName;
}

+ (BOOL)validateSoundFile:(NSString *)fileName {
    if (!fileName) return NO;
    return ([_resourceBundle pathForResource:fileName ofType:nil inDirectory:@"Sounds"] != nil);
}

@end
