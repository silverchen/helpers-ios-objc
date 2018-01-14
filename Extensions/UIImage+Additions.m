#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size alpha:(CGFloat)alpha; {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetAlpha(context, alpha);
    CGContextFillRect(context, rect);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

- (NSString *)convertJPEGToBase64Compression:(CGFloat)compression {
    if (!self)
        return nil;
    //Compression expressed as a value from 0.0 to 1.0. 0.0 represents the maximum compression while 1.0 represents the least compression
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    return [imageData base64EncodedStringWithOptions:0];
}

- (NSString *)convertPNGToBase64 {
    if (!self)
        return nil;

    NSData *imageData = UIImagePNGRepresentation(self);
    return [imageData base64EncodedStringWithOptions:0];
}

- (NSString *)contentTypeForImageData{
    uint8_t c;
    NSData *data = UIImageJPEGRepresentation(self, 1);

    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (BOOL)isJPEG{
    uint8_t c;
    NSData *data = UIImageJPEGRepresentation(self, 1);

    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return true;
        default:
            return false;
    }
}

- (BOOL)isPNG{
    uint8_t c;
    NSData *data = UIImageJPEGRepresentation(self, 1);

    [data getBytes:&c length:1];

    switch (c) {
        case 0x89:
            return true;
        default:
            return false;
    }
}

- (CGFloat)getFileSize {

    NSData *imgData = UIImageJPEGRepresentation(self, 1); //1 it represents the quality of the image.
//    CGF = (unsigned long)[imgData length];
    unsigned long long ullvalue = (unsigned long)[imgData length];
    return ullvalue/1024.0f/1024.0f; // value in MB
}

- (id)getFileSizeInRedableFormat
{
    CGFloat convertedValue = [self getFileSize];
    int multiplyFactor = 0;

    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];

    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }

    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

@end
