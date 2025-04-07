#import "SoundMapper.h"

@implementation SoundMapper

static NSDictionary *soundMappings;

+ (void)registerDefaultMappings {
    soundMappings = @{
        @"building": @"buildingBlock.mp3",
        @"default": @"custom_default.caf",
        // 添加其他映射规则
    };
}

+ (NSString *)mapSoundName:(NSString *)original {
    NSString *mapped = soundMappings[original];
    return mapped ?: original; // 保留原始值未找到映射
}

@end
