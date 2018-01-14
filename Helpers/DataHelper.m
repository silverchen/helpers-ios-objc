#import "DataHelper.h"
#import "NSDate+DateTools.h"
#import "UserPreferences.h"
#import "AFURLResponseSerialization.h"

@implementation DataHelper

+ (BOOL)getBoolValue:(id)value {
    @try {
        if (![self isObjectNull:value]) {
            return [value boolValue];
        }
    } @catch (NSException *theException) {
        NSLog(@"%@. %@", theException.name, theException.reason);
    }

    return false;
}

+ (int)getIntValue:(id)value {
    @try {
        if (![self isObjectNull:value]) {
            return [value intValue];
        }
    } @catch (NSException *theException) {
        NSLog(@"%@. %@", theException.name, theException.reason);
    }

    return 0;
}

+ (CGFloat)getFloatValue:(id)value {
    @try {
        if (![self isObjectNull:value]) {
            return [value floatValue];
        }
    } @catch (NSException *theException) {
        NSLog(@"%@. %@", theException.name, theException.reason);
    }

    return .0f;
}

+ (NSString *)getStringValue:(id)value {
    if (![value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"%@", [value description]];
    }

    return value;
}

+ (BOOL)isStringInt:(NSString *)value {
    NSScanner* scan = [NSScanner scannerWithString:value];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isStringFloat:(NSString *)value {
    NSScanner* scan = [NSScanner scannerWithString:value];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

+ (BOOL)isStringNull:(NSString *)value {
    if (![self isObjectNull:value]) {
        if ([value isKindOfClass:[NSString class]]) {
            return !value.length;
        } else {
            return !value.description.length;
        }
    }

    return YES;
}

+ (BOOL)isArrayEmpty:(NSArray *)value {
    if (![self isObjectNull:value]) {
        if ([value isKindOfClass:[NSArray class]]) {
            return value.count == 0;
        }
    }

    return YES;
}

+ (BOOL)isDictionaryEmpty:(NSDictionary *)value {
    if (![self isObjectNull:value]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            return value.count == 0;
        }
    }

    return YES;
}

+ (BOOL)isObjectNull:(id)value {
    return value == nil || value == [NSNull null];
}

+ (NSString *)getNumberInCurrency:(NSNumber *)value {
    return [DataHelper getNumberInCurrency:value withDecimalPoints:2];
}

+ (NSString *)getNumberInCurrency:(NSNumber *)value withDecimalPoints:(NSUInteger)decimalPoints {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:[DataHelper isNumberFraction:value]?decimalPoints:0];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    NSString *symbol = [self getCurrency];

    [formatter setCurrencySymbol:symbol];

    return [formatter stringFromNumber:value];
}

+ (NSString *)getNumberInDistance:(NSNumber *)value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencySymbol:@""];

    return [NSString stringWithFormat:@"%@ km", [formatter stringFromNumber:value]];
}

+ (NSString *)getYearFromNumber:(NSString *)value {
    int year = [[[[value stringByReplacingOccurrencesOfString:@"year" withString:@""] stringByReplacingOccurrencesOfString:@"s" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] intValue];

    NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSInteger currentYear = [gregorian component:NSCalendarUnitYear fromDate:NSDate.date];

    return [NSString stringWithFormat:@"%ld", (int)currentYear - year];
}

+ (NSString *)getFormattedDateFromDate:(NSDate *)date {
    // Date
    NSString *formattedDate = [self ISO8601StringFromDate:date format:@"%d %b %Y"];

    return formattedDate;
}

+ (NSString *)getFormattedDateTimeFromDate:(NSDate *)date {
    // Date
    NSString *formattedDate = [self ISO8601StringFromDate:date format:@"%d %b %Y %H:%M"];

    return formattedDate;
}

+ (NSString *)getFormattedDate:(NSString *)dateString {
    // Date
    NSDate *d = [self dateFromISO8601String:dateString format:@"%Y-%m-%d %H:%M:%S"];
    NSString *formattedDate = [self ISO8601StringFromDate:d format:@"%d %b %Y"];

    return formattedDate;
}

+ (NSString *)getFormattedDateTime:(NSString *)dateString {
    // Date
    NSDate *d = [self dateFromISO8601String:dateString format:@"%Y-%m-%d %H:%M:%S"];
    NSString *formattedDate = [self ISO8601StringFromDate:d format:@"%d %b %Y %H:%M"];

    return formattedDate;
}

+ (NSString *)getDateDifferencesInString:(NSDate *)startingDate endingDate:(NSDate *)endingDate {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitQuarter | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitEra | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekOfYear;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:startingDate toDate:endingDate options:0];
    NSInteger days     = [dateComponents day];
    NSInteger months   = [dateComponents month];
    NSInteger years    = [dateComponents year];
    NSInteger hours    = [dateComponents hour];
    NSInteger minutes  = [dateComponents minute];
    NSInteger seconds  = [dateComponents second];

    NSString *countDown;

    if (years > 0) {
        countDown = [NSString stringWithFormat:@"%d %@", (int)years, years > 1?@"years":@"year"];

        if (months > 0) {
            countDown = [NSString stringWithFormat:@"%@ %d %@", countDown, (int)months, months > 1?@"months":@"month"];
        }
    } else if (months > 0) {
        countDown = [NSString stringWithFormat:@"%d %@", (int)months, months > 1?@"months":@"month"];

        if (days > 0) {
            countDown = [NSString stringWithFormat:@"%@ %d %@", countDown, (int)days, days > 1?@"days":@"day"];
        }
    } else if (days > 0) {
        countDown = [NSString stringWithFormat:@"%d %@", (int)days, days > 1?@"days":@"day"];

        if (hours > 0) {
            countDown = [NSString stringWithFormat:@"%@ %d %@", countDown, (int)hours, hours > 1?@"hours":@"hour"];
        }
    } else if (hours > 0) {
        countDown = [NSString stringWithFormat:@"%d %@", (int)hours, hours > 1?@"hours":@"hour"];

        if (minutes > 0) {
            countDown = [NSString stringWithFormat:@"%@ %d %@", countDown, (int)minutes, minutes > 1?@"minutes":@"minute"];
        }
    } else if (minutes > 0) {
        countDown = [NSString stringWithFormat:@"%d %@", (int)hours, hours > 1?@"minutes":@"minute"];

        if (seconds > 0) {
            countDown = [NSString stringWithFormat:@"%@ %d %@", countDown, (int)seconds, seconds > 1?@"seconds":@"second"];
        }
    }

    return [DataHelper isStringNull:countDown]?@"Expired":countDown;
}

+ (NSString *)getTimeAgo:(NSDate *)date {
    return [date timeAgoSinceNow];
}

+ (NSString *)getShortTimeAgo:(NSDate *)date {
    return [date shortTimeAgoSinceNow];
}

+ (NSDate *)dateFromISO8601String:(nonnull NSString *)string format:(nonnull NSString *)format {
    if ([self isStringNull:string] || [self isStringNull:format]) {
        return nil;
    }

    const char *cFormat = [format UTF8String];
    struct tm tm;
    time_t t;
    char *ret;

    memset(&tm, 0, sizeof(tm));

    ret = strptime([string cStringUsingEncoding:NSUTF8StringEncoding], cFormat, &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);

    return [NSDate dateWithTimeIntervalSince1970:t]; //[[NSTimeZone localTimeZone] secondsFromGMT]
}

+ (NSString *)ISO8601StringFromDate:(nonnull NSDate *)date format:(nonnull NSString *)format {
    if ([self isObjectNull:date] || [self isStringNull:format]) {
        return nil;
    }

    const char *cFormat = [format UTF8String];
    struct tm timeinfo;
    char buffer[80];

    time_t time = [date timeIntervalSince1970];
    localtime_r(&time, &timeinfo);
    strftime(buffer, 80, cFormat, &timeinfo);

    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

+ (NSString *)encodeToBase64String:(UIImage *)image withDataPrefix:(BOOL)hasDataPrefix {
    NSString *s = [UIImageJPEGRepresentation(image, 0.3) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    if (hasDataPrefix) {
        s = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", s];
    }

    return s;
}

+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

+ (BOOL)isNumberFraction:(NSNumber *)number {
    double dValue = [number doubleValue];
    if (dValue < 0.0)
        return (dValue != ceil(dValue));
    else
        return (dValue != floor(dValue));
}

+ (NSDictionary *)getColorFromString:(NSString *)value {
    if (![self isStringNull:value]) {
        Configuration *config = [UserPreferences sharedInstance].config;
        for (id key in config.colors) {
            if ([[self purifyString:value] isEqualToString:[self purifyString:key]]) {
                return config.colors[key];
                break;
            }
        }
    }

    return nil;
}

+ (UIColor *)getColorFromHexString:(NSString *)value {
    if (![self isStringNull:value]) {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:value];
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&rgbValue];
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
    }

    return nil;
}

+ (BOOL)isLightColor:(UIColor *)clr {
    CGFloat white = 0;
    [clr getWhite:&white alpha:nil];
    return (white >= 0.6);
}

+ (NSString *)purifyString:(NSString *)value {
    if (![self isStringNull:value]) {
        return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].lowercaseString;
    }

    return @"";
}

+ (int)getMinFromTimeInternal:(double)t {
    return fabs(floor(t/60));
}

+ (NSArray *)convertDictionaryToArray:(NSDictionary *)dic {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    NSArray *keys = [dic allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];

    for (id key in sortedKeys) {
        id value = [dic objectForKey:key];
        NSDictionary *d = @{key:value};
        [a addObject:d];
    }

    return a;
}

+ (BOOL)isImageEmpty:(UIImage *)image {
    if ([self isObjectNull:image]) {
        return YES;
    }

    CGImageRef cgref = [image CGImage];
    CIImage *cim = [image CIImage];

    return cim == nil && cgref == NULL;
}

+ (NSString *)getAppIdentifier {
    SideMenu *selectedSideMenu = [UserPreferences sharedInstance].selectedSideMenu;
    if (![DataHelper isObjectNull:selectedSideMenu] && ![DataHelper isStringNull:selectedSideMenu.appTarget]) {
        return selectedSideMenu.appTarget;
    }

    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];

    if ([bundle isEqualToString:@"com.sample.one"] || [bundle isEqualToString:@"com.sample.two"]) {
        return APP_TEMPLATE_ONE;
    } else if ([bundle isEqualToString:@"com.sample.three"]) {
        return APP_TEMPLATE_TWO;
    }

    return nil;
}

+ (NSString *)getDefaultPhoneNumberPrefix {
#ifdef TH
    return @"+66";
#else
    return @"+65";
#endif
}

+ (NSInteger)getStatusCodeFromError:(NSError *)error {
    if (![DataHelper isObjectNull:[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey]]) {
        return [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    }

    return -1;
}

+ (NSDictionary *)getResponseFromError:(NSError *)error {
    if (![DataHelper isObjectNull:error.userInfo] && ![DataHelper isObjectNull:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]]) {
        NSError* err;
        NSDictionary* errResponse = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:kNilOptions error:&err];

        if ([DataHelper isObjectNull:err] && ![DataHelper isObjectNull:errResponse]) {
            return errResponse;
        }
    }

    return nil;
}

+ (NSString *)getCurrency {
    Configuration *config = [UserPreferences sharedInstance].config;

    if (![DataHelper isObjectNull:config] && ![DataHelper isStringNull:config.currency]) {
        return config.currency;
    }

    return @"$";
}

+ (NSString *)getUserRoleFromUser:(User *)u {
    NSString *r;

#warning temporary to handle v3 api
    if ([DataHelper isArrayEmpty:u.roles]) {
        r = [DataHelper purifyString:u.role];
    } else {
        r = u.roles[0];
    }

    return r;
}

+ (NSString *)getFormattedStringEfficientlyWithFormat:(NSString *)format, ... {
    va_list args;
    char *buffer = NULL;
    NSString *formattedString;

    va_start(args, format);
    asprintf(&buffer, [format cStringUsingEncoding:NSUTF8StringEncoding], args);
    va_end(args);

    if (buffer != NULL) {
        formattedString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
    }
    free(buffer);

    return formattedString;
}

@end
