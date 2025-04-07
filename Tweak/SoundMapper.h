#import <Foundation/Foundation.h>

@interface SoundMapper : NSObject

+ (void)registerDefaultMappings;
+ (nullable NSString *)mapSoundName:(nullable NSString *)originalName;

@end
