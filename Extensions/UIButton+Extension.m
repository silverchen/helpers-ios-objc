#import "UIButton+Extension.h"

#import <objc/runtime.h>

void _Swizzle(Class c, SEL orig, SEL new)
{
	Method origMethod = class_getInstanceMethod(c, orig);
	Method newMethod = class_getInstanceMethod(c, new);
	if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
		class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	else
		method_exchangeImplementations(origMethod, newMethod);
}

static char *const kDidAddObserverKey = "kDidAddObserver";
static char *const kBackgroundColorStateKey = "kBackgroundColorStateKey";
static char *const kBorderWidthStateKey = "kBorderWidthStateKey";
static char *const kBorderColorStateKey = "kBorderColorStateKey";
static char *const kTitleFontStateKey = "kTitleFontStateKey";

NSString *keyForState(UIControlState state) {
	switch (state) {
		case UIControlStateApplication:
			return @"UIControlStateApplication";
			break;
		case UIControlStateDisabled:
			return @"UIControlStateDisabled";
			break;
		case UIControlStateHighlighted:
			return @"UIControlStateHighlighted";
			break;
		case UIControlStateNormal:
			return @"UIControlStateNormal";
			break;
		case UIControlStateReserved:
			return @"UIControlStateReserved";
			break;
		case UIControlStateSelected:
			return @"UIControlStateSelected";
			break;
		default:
			return nil;
			break;
	}
}

@implementation UIButton (Extension)

+ (void) load {
	_Swizzle([self class], @selector(layoutSubviews),
			@selector(_myLayoutSubview));
	_Swizzle([self class], @selector(observeValueForKeyPath:ofObject:change:context:),
			@selector(_myObserveValueForKeyPath:ofObject:change:context:));
	_Swizzle([self class], NSSelectorFromString(@"dealloc"),
			@selector(_myDealloc));
}

static void *XXContext = &XXContext;

- (void) _registerStateChangeObserver {
	if(! [self _didRegisterObserver]) {
		[self addObserver:self
			   forKeyPath:@"selected"
				  options:NSKeyValueObservingOptionNew
				  context:XXContext];
		[self addObserver:self
			   forKeyPath:@"highlighted"
				  options:NSKeyValueObservingOptionNew
				  context:XXContext];
		[self addObserver:self
			   forKeyPath:@"enabled"
				  options:NSKeyValueObservingOptionNew
				  context:XXContext];
		[self _setDidRegisterObserver:true];
	}
}

- (void) _unregisterStateChangeObserver {
	if([self _didRegisterObserver]) {
		[self removeObserver:self
				  forKeyPath:@"selected"
					 context:XXContext];
		[self removeObserver:self
				  forKeyPath:@"highlighted"
					 context:XXContext];
		[self removeObserver:self
				  forKeyPath:@"enabled"
					 context:XXContext];

		[self _setDidRegisterObserver:false];
	}
}

- (void) _myObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(context == XXContext) {
		[self _updateUIForCurrentState];
	}
	else {
		[self _myObserveValueForKeyPath:keyPath
							   ofObject:object
								 change:change
								context:context];
	}
}

- (void) _myDealloc {
	[self _unregisterStateChangeObserver];
	[self _myDealloc];
}

- (void) _myLayoutSubview {
	[self _myLayoutSubview];
	[self _updateUIForCurrentState];
}

- (void) _updateUIForCurrentState {
	UIColor *backgroundColor = [self backgroundColorForState:self.state];
	if(backgroundColor)
		[self setBackgroundColor:backgroundColor];

	UIColor *borderColor = [self borderColorForState:self.state];
	if(borderColor)
		self.layer.borderColor = borderColor.CGColor;

	NSNumber *borderWidth = [self borderWidthForState:self.state];
	if(borderWidth)
		self.layer.borderWidth = borderWidth.floatValue;

	UIFont *font = [self titleFontForState:self.state];
	if(font)
		self.titleLabel.font = font;
}

- (void) setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
	[self _registerStateChangeObserver];
	NSMutableDictionary *dict = [self _dictForKey:kBackgroundColorStateKey];
	[dict setValue:color forKey:keyForState(state)];
}

- (UIColor *) backgroundColorForState:(UIControlState)state {
	NSMutableDictionary *dict = [self _dictForKey:kBackgroundColorStateKey];
	return [dict valueForKey:keyForState(state)];
}

- (void) setBorderWidth:(NSNumber *)width forState:(UIControlState)state {
	[self _registerStateChangeObserver];
	NSMutableDictionary *dict = [self _dictForKey:kBorderWidthStateKey];
	[dict setValue:width forKey:keyForState(state)];
}

- (NSNumber *) borderWidthForState:(UIControlState)state {
	NSMutableDictionary *dict = [self _dictForKey:kBorderWidthStateKey];
	return [dict valueForKey:keyForState(state)];
}

- (void) setBorderColor:(UIColor *)color forState:(UIControlState)state {
	[self _registerStateChangeObserver];
	NSMutableDictionary *dict = [self _dictForKey:kBorderColorStateKey];
	[dict setValue:color forKey:keyForState(state)];
}

- (UIColor *) borderColorForState:(UIControlState)state {
	NSMutableDictionary *dict = [self _dictForKey:kBorderColorStateKey];
	return [dict valueForKey:keyForState(state)];
}

- (void) setTitleFont:(UIFont *)font forState:(UIControlState)state {
	[self _registerStateChangeObserver];
	NSMutableDictionary *dict = [self _dictForKey:kTitleFontStateKey];
	[dict setValue:font forKey:keyForState(state)];
}

- (UIFont *) titleFontForState:(UIControlState)state {
	NSMutableDictionary *dict = [self _dictForKey:kTitleFontStateKey];
	return [dict valueForKey:keyForState(state)];
}

- (NSMutableDictionary *) _dictForKey:(char *)key {
	NSMutableDictionary *dict = objc_getAssociatedObject(self, key);
	if(! dict) {
		dict = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, key, dict, OBJC_ASSOCIATION_RETAIN);
	}
	return dict;
}

- (BOOL) _didRegisterObserver {
	return [objc_getAssociatedObject(self, kDidAddObserverKey) boolValue];
}

- (void) _setDidRegisterObserver:(BOOL)didRegister {
	objc_setAssociatedObject(self, kDidAddObserverKey, @(didRegister), OBJC_ASSOCIATION_COPY);
}

@end
