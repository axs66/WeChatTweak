#import <Foundation/Foundation.h>

@interface SoundMapper : NSObject

+ (void)registerDefaultMappings;
+ (NSString *)mapSoundName:(NSString *)originalName;

@end
