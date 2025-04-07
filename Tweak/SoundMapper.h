#import <Foundation/Foundation.h>

@interface SoundMapper : NSObject

+ (void)registerDefaultMappings;
+ (NSString *)mapSoundName:(NSString *)original;
+ (BOOL)validateSoundFile:(NSString *)soundName;

@end
