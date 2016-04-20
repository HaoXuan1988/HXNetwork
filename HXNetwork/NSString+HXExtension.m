//
//  NSString+HXExtension.m
//  HXNetwork
//
//  Created by 吕浩轩 on 16/2/19.
//  Copyright © 2016年 satisfy. All rights reserved.
//

#import "NSString+HXExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HXExtension)
#pragma mark - 给定宽/高返回高/宽
//给定宽返回高
+ (CGFloat)hx_givenTheWidth_getHeight:(NSString*)text  width:(CGFloat)width font:(UIFont *)font
{
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, 10000)
                                     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:font} context:nil];
    return rect.size.height;
}

//给定高返回宽
+ (CGFloat)hx_givenTheHeight_getWidth:(NSString*)text  height:(CGFloat)height font:(UIFont *)font
{
    
    CGRect tmpRect = [text boundingRectWithSize:CGSizeMake(10000, height)
                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                     attributes:@{NSFontAttributeName:font} context:nil];
    return tmpRect.size.width;
}

#pragma mark - 正则表达式
//判断手机号
+(BOOL)hx_isValidatMobilePhoneCode:(NSString *)phoneCode
{
    
    NSString *emailRegex = @"^((100)|(13[0-9])|(14[5|7])|(15[0-9])|(18[0-9])|(17[0-9]))\\d{8}$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isMatch = [emailTest evaluateWithObject:phoneCode];
    return isMatch;
}

//用户密码6-19位数字和字母组合
+ (BOOL)hx_isValidatPassword:(NSString *)password
{
    NSString *pattern = @"^[0-9a-zA-Z]{6,16}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}

//判断昵称
+(BOOL)hx_isValidatNickName:(NSString*)nickName
{
    NSString *pattern = @"^[a-zA-Z0-9_\u4e00-\u9fa5]{1,10}$";;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:nickName];
    return isMatch;
}

//检查邮箱格式
+(BOOL)hx_isValidatEmail:(NSString*)email
{
    
    NSString *pattern =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:email];
    return isMatch;
}

//检查QQ格式
+(BOOL)hx_isValidatQQ:(NSString*)QQ
{
    NSString *pattern = @"^[1-9](\\d){4,12}$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:QQ];
    return isMatch;
}

//检查是不是表情
+ (BOOL)hx_stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue =NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring,NSRange substringRange,NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];

         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue =YES;
                 }
             }
         }else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue =YES;
             }
         }else {

             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue =YES;
             }else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue =YES;
             }else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue =YES;
             }else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue =YES;
             }else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue =YES;
             }
         }
     }];
    return returnValue;
}

#pragma mark - URLEncodingUTF8String
// 字符串 编码(网络请求专用)
+ (NSString *)hx_URLEncodingUTF8String:(NSString *)string
{
    NSString *newString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    if (newString) {
        return newString;
    }
    
    return string;
}


// 字符串 编码(通用)
+ (NSString *)hx_encodingUTF8String:(NSString *)string
{
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)string,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    if (newString) {
        return newString;
    }
    
    return string;
}


// 字符串 解码 (通用)
+ (NSString *)hx_decodeString:(NSString*)string
{
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
                                                                                       (CFStringRef)string,
                                                                                       CFSTR("")));
    if (newString) {
        return newString;
    }
    
    return string;
}

// 时间戳转时间
+ (NSString *)hx_getTimeToShowWithTimestamp:(NSString *)timestamp type:(NSString *)type
{
    int start = 0;//“（”的位置
    int end = 0;//“）”的位置
    for (int i = 0; i < timestamp.length; i++) {
        if ([timestamp characterAtIndex:i] == '(') {
            start = i;
        }
        if ([timestamp characterAtIndex:i] == ')') {
            end = i;
        }
    }
    NSString *publishString = [timestamp substringToIndex:end];
    publishString = [publishString substringFromIndex:start + 1];
    
    double publishLong = [publishString doubleValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:type];
    
    NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:publishLong/1000];
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    publishDate = [publishDate  dateByAddingTimeInterval: interval];
    
    publishString = [formatter stringFromDate:publishDate];
    
    return publishString;
}


//时间戳对应的NSDate
- (NSDate *)hx_date{
    
    NSTimeInterval timeInterval=self.floatValue;
    
    return [NSDate dateWithTimeIntervalSince1970:timeInterval];
}


/**
 *  32位MD5加密
 */
- (NSString *)hx_MD5{
    
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return [result copy];
}




/**
 *  SHA1加密
 */
- (NSString *)hx_SHA1{
    
    const char *cStr = [self UTF8String];
    NSData *data = [NSData dataWithBytes:cStr length:self.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return [result copy];
}


+ (NSString *)hx_homeDirectoryPath
{
    return NSHomeDirectory();
}

+ (NSString *)hx_documentDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)hx_libraryDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)hx_cacheDirectoryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)hx_tmpDirectoryPath
{
    return NSTemporaryDirectory();
}

+ (NSString *)hx_pathByAppendingForHome:(NSString *)appendingPath
{
    return [[self hx_homeDirectoryPath] stringByAppendingPathComponent:appendingPath];
}

+ (NSString *)hx_pathByAppendingForDocument:(NSString *)appendingPath
{
    return [[self hx_documentDirectoryPath] stringByAppendingPathComponent:appendingPath];
}

+ (NSString *)hx_pathByAppendingForLibrary:(NSString *)appendingPath
{
    return [[self hx_libraryDirectoryPath] stringByAppendingPathComponent:appendingPath];
}

+ (NSString *)hx_pathByAppendingForCache:(NSString *)appendingPath
{
    return [[self hx_cacheDirectoryPath] stringByAppendingPathComponent:appendingPath];
}

+ (NSString *)hx_pathByAppendingForTmp:(NSString *)appendingPath
{
    return [[self hx_tmpDirectoryPath] stringByAppendingPathComponent:appendingPath];
}

+ (NSString *)hx_parentDirectoryPath:(NSString *)subPath
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[subPath componentsSeparatedByString:@"/"]];
    if ([array count] > 1)
    {
        if ([array count] == 2)
            return @"/";
        
        [array removeLastObject];
        return [array componentsJoinedByString:@"/"];
    }
    
    return nil;
}

/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)hx_createSubFolder:(NSString *)subFolder{
    
    NSString *subFolderPath=[NSString stringWithFormat:@"%@/%@",self,subFolder];
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return subFolderPath;
}
@end
