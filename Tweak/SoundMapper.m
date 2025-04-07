#import "SoundMapper.h"
#import <UIKit/UIKit.h> // 添加 UIKit 框架引用

@implementation SoundMapper

static NSDictionary<NSString *, NSString *> *_soundMappings;
static NSBundle *_resourceBundle; // 添加资源包引用

+ (void)initialize {
    if (self == [SoundMapper class]) {
        // 初始化资源包路径
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"WeChatTweak" ofType:@"bundle"];
        _resourceBundle = [NSBundle bundleWithPath:bundlePath];
        
        [self registerDefaultMappings];
    }
}

+ (void)registerDefaultMappings {
    _soundMappings = @{
        // 键: 微信原始提示音名称
        // 值: 自定义声音文件名（无需包含路径）
        @"default": @"custom_notify",   // .caf 格式
        @"msg":     @"new_message",     // .mp3 格式
        @"system":  @"system_alert"     // .wav 格式
    };
}

+ (NSString *)mapSoundName:(NSString *)originalName {
    // 1. 获取映射后的基础文件名
    NSString *mappedName = _soundMappings[originalName] ?: originalName;
    
    // 2. 自动检测扩展名
    NSString *filePath = [self soundFilePathForName:mappedName];
    
    // 3. 验证文件实际存在性
    return filePath ? [mappedName stringByAppendingPathExtension:[filePath pathExtension]] : originalName;
}

#pragma mark - Private Methods

+ (NSString *)soundFilePathForName:(NSString *)name {
    // 支持的音频格式优先级
    NSArray<NSString *> *extensions = @[@"caf", @"mp3", @"wav", @"aiff"];
    
    for (NSString *ext in extensions) {
        NSString *path = [_resourceBundle pathForResource:name 
                                                   ofType:ext 
                                              inDirectory:@"Sounds"];
        if (path) {
            NSLog(@"[SoundMapper] 找到音频文件: %@", [path lastPathComponent]);
            return path;
        }
    }
    
    NSLog(@"[SoundMapper] 警告: 未找到 %@ 的音频文件", name);
    return nil;
}

@end
