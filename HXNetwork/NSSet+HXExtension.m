//
//  NSSet+HXExtension.m
//  HXNetwork
//
//  Created by 吕浩轩 on 16/1/22.
//  Copyright © 2016年 satisfy. All rights reserved.
//

#import "NSSet+HXExtension.h"
#import "NSObject+HXExtension.h"
#import <objc/runtime.h>

@implementation NSSet (HXExtension)




#if DEBUG
/*!
 *  @author 吕浩轩, 16-02-26 16:02:27
 *
 *  开发阶段对集合漂亮打印的方法重写(release 模式不运行,可以放心使用)
 *
 *  @param locale
 *  @param level
 *
 *  @return
 */
- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSMutableString *desc = [NSMutableString string];
    
    NSMutableString *tabString = [[NSMutableString alloc] initWithCapacity:level];
    for (NSUInteger i = 0; i < level; ++i) {
        [tabString appendString:@"   "];
    }
    
    NSString *tab = @"   ";
    if (level > 0) {
        tab = tabString;
    }
    [desc appendString:@"{[\n"];
    
    for (id obj in self) {
        if ([obj isKindOfClass:[NSDictionary class]]
            || [obj isKindOfClass:[NSArray class]]
            || [obj isKindOfClass:[NSSet class]]) {
            NSString *str = [((NSDictionary *)obj) descriptionWithLocale:locale indent:level + 1];
            [desc appendFormat:@"%@   %@,\n", tab, str];
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *str = [obj stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
            str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            [desc appendFormat:@"%@   \"%@\",\n", tab, str];
        } else if ([obj isKindOfClass:[NSData class]]) {
            // 如果是NSData类型，尝试去解析结果，以打印出可阅读的数据
            NSError *error = nil;
            NSObject *result =  [NSJSONSerialization JSONObjectWithData:obj
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&error];
            // 解析成功
            if (error == nil && result != nil) {
                if ([result isKindOfClass:[NSDictionary class]]
                    || [result isKindOfClass:[NSArray class]]
                    || [result isKindOfClass:[NSSet class]]) {
                    NSString *str = [((NSDictionary *)result) descriptionWithLocale:locale indent:level + 1];
                    [desc appendFormat:@"%@   %@,\n", tab, str];
                } else if ([obj isKindOfClass:[NSString class]]) {
                    [desc appendFormat:@"%@   \"%@\",\n", tab, result];
                }
            } else {
                @try {
                    NSString *str = [[NSString alloc] initWithData:obj encoding:NSUTF8StringEncoding];
                    if (str != nil) {
                        [desc appendFormat:@"%@   \"%@\",\n", tab, str];
                    } else {
                        [desc appendFormat:@"%@   %@,\n", tab, obj];
                    }
                }
                @catch (NSException *exception) {
                    [desc appendFormat:@"%@   %@,\n", tab, obj];
                }
            }
        } else {
            //TMD 打印出来太丑了
            [desc appendFormat:@" <%s>\n",class_getName([obj class])];
            NSDictionary *Properties = [obj getAllPropertiesAndValue];
            NSString *str = [((NSDictionary *)Properties) descriptionWithLocale:locale indent:level + 1];
            [desc appendFormat:@"   %@%@,\n", tab, str];
        }
    }
    desc = [NSMutableString stringWithString:[desc substringWithRange:NSMakeRange(0, [desc length] - 2)]];
    if (self.count == 0) {
        [desc appendFormat:@"[]}"];
    }else{
        [desc appendFormat:@"\n%@]}", tab];
    }
    
    
    return desc;
}
#endif

@end
