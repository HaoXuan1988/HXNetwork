//
//  NSObject+HXExtension.h
//  ZhiYu
//
//  Created by 吕浩轩 on 16/6/2.
//  Copyright © 2016年 上海先致信息股份有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (HXExtension)


- (NSArray *)getAllProperties;

- (NSDictionary *)getAllPropertiesAndValue;

-(void)printMothList;

@end
