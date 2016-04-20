//
//  NSString+HXExtension.h
//  HXNetwork
//
//  Created by 吕浩轩 on 16/2/19.
//  Copyright © 2016年 satisfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (HXExtension)

/**
 *  32位MD5加密
 */
@property (nonatomic,copy,readonly) NSString *hx_MD5;

/**
 *  SHA1加密
 */
@property (nonatomic,copy,readonly) NSString *hx_SHA1;

/**
 *  给定宽返回高
 *
 *  @param text  text
 *  @param width 定宽
 *  @param font  字体.大小
 *
 *  @return 高
 */
+ (CGFloat)hx_givenTheWidth_getHeight:(NSString*)text  width:(CGFloat)width font:(UIFont *)font;

/**
 *  给定高返回宽
 *
 *  @param text   text
 *  @param height 定高
 *  @param font   字体
 *
 *  @return 宽
 */
+ (CGFloat)hx_givenTheHeight_getWidth:(NSString*)text  height:(CGFloat)height font:(UIFont *)font;

/**
 *  判断手机号
 *
 *  @param phoneCode
 *
 *  @return 
 */
+(BOOL)hx_isValidatMobilePhoneCode:(NSString *)phoneCode;

/*
 *  用户密码6-19位数字和字母组合
 *
 *  @param password
 *
 *  @return 
 */
+ (BOOL)hx_isValidatPassword:(NSString *)password;

/*
 *  判断昵称
 *
 *  @param nickName
 *
 *  @return 
 */
+(BOOL)hx_isValidatNickName:(NSString*)nickName;

/*
 *  检查邮箱格式
 *
 *  @param email
 *
 *  @return
 */
+(BOOL)hx_isValidatEmail:(NSString*)email;

/*
 *  检查QQ格式
 *
 *  @param QQ
 *
 *  @return 
 */
+(BOOL)hx_isValidatQQ:(NSString*)QQ;

/*
 *  检查是不是表情
 *
 *  @param string
 *
 *  @return 
 */
+ (BOOL)hx_stringContainsEmoji:(NSString *)string;

/**
 *  URLEncodingUTF8String 字符串 编码(网络请求专用)
 *
 *  @param string string
 *
 *  @return URLEncodingUTF8String
 */
+ (NSString *)hx_URLEncodingUTF8String:(NSString *)string;

/**
 *  URLEncodingUTF8String 字符串 编码(通用)
 *
 *  @param string string
 *
 *  @return URLEncodingUTF8String
 */
+ (NSString *)hx_encodingUTF8String:(NSString *)string;

/**
 *  URLEncodingUTF8String 字符串 解码 (通用)
 *
 *  @param string URLEncodingUTF8String
 *
 *  @return string
 */
+ (NSString *)hx_decodeString:(NSString*)string;

/*
 *  时间戳转时间,自定义
 *
 *  @param string 时间戳
 *
 *  @param type   例如:@"yyyy-MM-dd"
 *
 *  @return URLEncodingUTF8String
 */
+ (NSString *)hx_getTimeToShowWithTimestamp:(NSString *)timestamp type:(NSString *)type;


+ (NSString *)hx_homeDirectoryPath;
+ (NSString *)hx_documentDirectoryPath;
+ (NSString *)hx_libraryDirectoryPath;
+ (NSString *)hx_cacheDirectoryPath;
+ (NSString *)hx_tmpDirectoryPath;

+ (NSString *)hx_pathByAppendingForHome:(NSString *)appendingPath;
+ (NSString *)hx_pathByAppendingForDocument:(NSString *)appendingPath;
+ (NSString *)hx_pathByAppendingForLibrary:(NSString *)appendingPath;
+ (NSString *)hx_pathByAppendingForCache:(NSString *)appendingPath;
+ (NSString *)hx_pathByAppendingForTmp:(NSString *)appendingPath;

+ (NSString *)hx_parentDirectoryPath:(NSString *)subPath;

/**
 *  生成子文件夹
 *
 *  如果子文件夹不存在，则直接创建；如果已经存在，则直接返回
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 文件夹路径
 */
-(NSString *)hx_createSubFolder:(NSString *)subFolder;

@end
