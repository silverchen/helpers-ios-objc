#import "UIImage+Extension.h"

@implementation UIImage (Extension)

- (UIImage*) replaceColor:(UIColor*)color withTolerance:(float)tolerance {
	CGImageRef imageRef = [self CGImage];

	NSUInteger width = CGImageGetWidth(imageRef);
	NSUInteger height = CGImageGetHeight(imageRef);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	NSUInteger bytesPerPixel = 4;
	NSUInteger bytesPerRow = bytesPerPixel * width;
	NSUInteger bitsPerComponent = 8;
	NSUInteger bitmapByteCount = bytesPerRow * height;

	unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));

	CGContextRef context = CGBitmapContextCreate(rawData, width, height,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);

	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

	// [UIColor getRed:green:blue:alpha] only works on iOS 7 and above
	CGFloat r,g,b;
	assert([color getRed:&r green:&g blue:&b alpha:nil]); // This will fail on old iOS version (may be 6.0 ???)

//	CGColorRef cgColor = [color CGColor];
//	const CGFloat *components = CGColorGetComponents(cgColor);
//	CGColorGetColorSpace(cgColor);
//	float r = components[0];
//	float g = components[1];
//	float b = components[2];
	//float a = components[3]; // not needed

	r = r * 255.0;
	g = g * 255.0;
	b = b * 255.0;

	const CGFloat redRange[2] = {
		MAX(r - (tolerance / 2.0), 0.0),
		MIN(r + (tolerance / 2.0), 255.0)
	};

	const CGFloat greenRange[2] = {
		MAX(g - (tolerance / 2.0), 0.0),
		MIN(g + (tolerance / 2.0), 255.0)
	};

	const CGFloat blueRange[2] = {
		MAX(b - (tolerance / 2.0), 0.0),
		MIN(b + (tolerance / 2.0), 255.0)
	};

	int byteIndex = 0;

	while (byteIndex < bitmapByteCount) {
		unsigned char red   = rawData[byteIndex];
		unsigned char green = rawData[byteIndex + 1];
		unsigned char blue  = rawData[byteIndex + 2];

		if (((red >= redRange[0]) && (red <= redRange[1])) &&
			((green >= greenRange[0]) && (green <= greenRange[1])) &&
			((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
			// make the pixel transparent
			//
			rawData[byteIndex] = 0;
			rawData[byteIndex + 1] = 0;
			rawData[byteIndex + 2] = 0;
			rawData[byteIndex + 3] = 0;
		}

		byteIndex += 4;
	}

	CGImageRef imgref = CGBitmapContextCreateImage(context);
	UIImage *result = [UIImage imageWithCGImage:imgref];

	CGImageRelease(imgref);
	CGContextRelease(context);
	free(rawData);

	return result;
}

@end
