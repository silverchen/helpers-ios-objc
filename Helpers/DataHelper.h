#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataHelper : NSObject

+ (BOOL)getBoolValue:(nullable id)value;

+ (int)getIntValue:(nullable id)value;

+ (CGFloat)getFloatValue:(nullable id)value;

+ (BOOL)isStringInt:(nullable NSString *)value;

+ (BOOL)isStringFloat:(nullable NSString *)value;

+ (nullable NSString *)getStringValue:(nullable id)value;

+ (nonnull NSString *)getNumberInCurrency:(nullable NSNumber *)value;

+ (nonnull NSString *)getNumberInCurrency:(nullable NSNumber *)value withDecimalPoints:(NSUInteger)decimalPoints;

+ (nonnull NSString *)getNumberInDistance:(nullable NSNumber *)value;

+ (nonnull NSString *)getYearFromNumber:(nonnull NSString *)value;

+ (BOOL)isStringNull:(nullable NSString *)value;

+ (BOOL)isArrayEmpty:(nullable NSArray *)value;

+ (BOOL)isDictionaryEmpty:(nullable NSDictionary *)value;

+ (BOOL)isObjectNull:(nullable id)value;

+ (nonnull NSString *)getTimeAgo:(nonnull NSDate *)date;

+ (nonnull NSString *)getShortTimeAgo:(nonnull NSDate *)date;

+ (nonnull NSString *)getDateDifferencesInString:(nonnull NSDate *)startingDate endingDate:(nonnull NSDate *)endingDate;

+ (nullable NSDate *)dateFromISO8601String:(nonnull NSString *)string format:(nonnull NSString *)format;

+ (nullable NSString *)ISO8601StringFromDate:(nonnull NSDate *)date format:(nonnull NSString *)format;

+ (nonnull NSString *)encodeToBase64String:(nonnull UIImage *)image withDataPrefix:(BOOL)hasDataPrefix;

+ (nonnull UIImage *)decodeBase64ToImage:(nonnull NSString *)strEncodeData;

+ (BOOL)isNumberFraction:(nonnull NSNumber *)number;

+ (nonnull NSString *)purifyString:(nonnull NSString *)value;

+ (int)getMinFromTimeInternal:(double)t;

//Localized
+ (nonnull NSString *)getFormattedDateFromDate:(nonnull NSDate *)date;

+ (nonnull NSString *)getFormattedDateTimeFromDate:(nonnull NSDate *)date;

+ (nonnull NSString *)getFormattedDate:(nonnull NSString *)dateString;

+ (nonnull NSString *)getFormattedDateTime:(nonnull NSString *)dateString;

+ (nullable NSDictionary *)getColorFromString:(nullable NSString *)value;

+ (nullable UIColor *)getColorFromHexString:(nullable NSString *)value;

+ (BOOL)isLightColor:(nonnull UIColor *)clr;

+ (nonnull NSArray *)convertDictionaryToArray:(nonnull NSDictionary *)dic;

+ (BOOL)isImageEmpty:(nonnull UIImage *)image;

+ (nullable NSString *)getAppIdentifier;

+ (NSInteger)getStatusCodeFromError:(nonnull NSError *)error;

+ (nullable NSDictionary *)getResponseFromError:(nonnull NSError *)error;

+ (nullable NSString *)getCurrency;

+ (nullable NSString *)getUserRoleFromUser:(nonnull User *)u;

+ (nonnull NSString *)getDefaultPhoneNumberPrefix;

+ (nullable NSString *)getFormattedStringEfficientlyWithFormat:(nonnull NSString *)format, ...;

@end
