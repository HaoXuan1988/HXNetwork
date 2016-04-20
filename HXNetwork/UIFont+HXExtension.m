//
//  UIFont+HXExtension.m
//  HXNetworkDemo
//
//  Created by 吕浩轩 on 16/4/11.
//  Copyright © 2016年 吕浩轩. All rights reserved.
//

#import "UIFont+HXExtension.h"

@implementation UIFont (HXExtension)

#pragma mark  打印并显示所有字体
+(void)showAllFonts{
    NSArray *familyNames = [UIFont familyNames];
    for( NSString *familyName in familyNames ){
        printf( "Family: %s \n", [familyName UTF8String] );
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for( NSString *fontName in fontNames ){
            printf( "\tFont: %s \n", [fontName UTF8String] );
        }
    }
}




#pragma mark  宋体
+(UIFont *)songTypefaceFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"经典宋体简" size:size];
}


#pragma mark  微软雅黑
+(UIFont *)microsoftYaHeiFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"MicrosoftYaHei" size:size];
}


#pragma mark  微软雅黑：加粗字体
+(UIFont *)boldMicrosoftYaHeiFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"MicrosoftYaHei-Bold" size:size];
}


#pragma mark  DroidSansFallback
+(UIFont *)customFontNamedDroidSansFallbackWithFontOfSize:(CGFloat)size{
    return [UIFont fontWithName:@"DroidSansFallback" size:size];
}


@end
