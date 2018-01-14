#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat)alpha;

- (NSString *)convertJPEGToBase64Compression:(CGFloat)compression;

- (NSString *)convertPNGToBase64;

- (NSString *)contentTypeForImageData;

- (BOOL)isJPEG;
- (BOOL)isPNG;

- (CGFloat)getFileSize;
- (id)getFileSizeInRedableFormat;

@end
