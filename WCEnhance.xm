#import <UIKit/UIKit.h>

@interface WCTableViewCellLeftConfig : NSObject
@property(copy, nonatomic) NSString *title; // @synthesize title=_title;
@end

@interface WCC2CImageScrollView : UIView
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture;
@end

@interface CExtendInfoOfImg : NSObject
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(_Bool)arg3;
- (void)setImage:(id)arg1 withData:(id)arg2 isOriginImage:(BOOL)arg3;
@end

%hook WCTableViewCellLeftConfig

- (NSString *)title {
	NSString *r = %orig;
	
	if (r == nil) {
		return nil;
	}
	if ([r isEqualToString:@"订单与卡包"]) {
		return @"卡包";
	}
	if ([r isEqualToString:@"支付与服务"]) {
		return @"服务";
	}
	
	return r;
}

%end

%hook UIButton

- (void)setAccessibilityLabel:(NSString *)accessibilityLabel {
	%orig;

	if ([accessibilityLabel isEqualToString:@"我的⼆维码"]) {

		self.hidden = YES;
	}
}

%end

%hook WCC2CImageScrollView

- (void)layoutSubviews {
	%orig;
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	
	if ([version compare:@"8.0.55" options:NSNumericSearch] != NSOrderedAscending) {
		BOOL hasGesture = NO;
		for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
			if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
				hasGesture = YES;
				break;
			}
		}
		
		if (!hasGesture) {
			UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
			[self addGestureRecognizer:tap];
		}
	}
	
	NSArray *subviews = [self.subviews copy];
	for (UIView *subview in subviews) {
		if ([subview class] == [UIView class]) {
			[subview removeFromSuperview];
		}
	}
}

%new
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	CGPoint location = [gesture locationInView:self];
	CGFloat width = self.bounds.size.width;
	CGFloat edgeWidth = width * 0.2;
	
	if (location.x <= edgeWidth || location.x >= (width - edgeWidth)) {
		SEL closeSelector = NSSelectorFromString(@"onCloseBtnClick:");
		if ([self respondsToSelector:closeSelector]) {
			[self performSelector:closeSelector withObject:nil];
		}
	}
}

%end

%hook CExtendInfoOfImg
%new
- (void)setImage:(id)arg1 withData:(id)arg2 isLongOriginImage:(BOOL)arg3 {
	[self setImage:arg1 withData:arg2 isOriginImage:arg3];
}
%end
