#import "SoundMapper.h"

@implementation SoundMapper

static NSDictionary *_soundMappings;

+ (void)registerDefaultMappings {
    _soundMappings = @{
        @"default": @"custom_sound.caf",
        @"ping.aiff": @"dingdong.caf"
    };
}

+ (NSString *)mapSoundName:(NSString *)original {
    return _soundMappings[original] ?: original;
}

+ (BOOL)validateSoundFile:(NSString *)soundName {
    NSString *path = [[NSBundle mainBundle] pathForResource:[soundName stringByDeletingPathExtension]
                                                     ofType:[soundName pathExtension]];
    return path != nil;
}

@end
