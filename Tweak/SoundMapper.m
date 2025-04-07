#import "SoundMapper.h"

@implementation SoundMapper

static NSDictionary<NSString *, NSString *> *_soundMappings;

+ (void)registerDefaultMappings {
    _soundMappings = @{
        @"default": @"custom_notify.caf",
        @"msg": @"new_message.mp3",
        @"system": @"system_alert.wav"
    };
}

+ (NSString *)mapSoundName:(NSString *)originalName {
    return _soundMappings[originalName] ?: originalName;
}

@end
