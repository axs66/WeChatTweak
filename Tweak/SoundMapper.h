#import <Foundation/Foundation.h>

@interface SoundMapper : NSObject
+ (void)registerDefaultMappings;
+ (nullable NSString *)mapSoundName:(nonnull NSString *)originalName;
+ (BOOL)validateSoundFile:(nullable NSString *)fileName;
@end
