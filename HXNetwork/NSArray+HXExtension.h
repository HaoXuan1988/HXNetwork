//
//  NSArray+HXExtension.h
//  HXNetwork
//
//  Created by 吕浩轩 on 16/1/22.
//  Copyright © 2016年 satisfy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HXExtension)
/**
 *  数组转字符串
 *
 *  @return 字符串
 */
-(NSString *)hx_string;


/**
 *  数组比较
 *
 *  @param array  源数组
 *
 *  @return  BOOL
 */
-(BOOL)hx_compareIgnoreObjectOrderWithArray:(NSArray *)array;


/**
 *  数组计算交集
 *
 *  @param otherArray 源数组
 *
 *  @return 新数组
 */
-(NSArray *)hx_arrayForIntersectionWithOtherArray:(NSArray *)otherArray;

/**
 *  数据计算差集
 *
 *  @param otherArray 源数组
 *
 *  @return 新数组
 */
-(NSArray *)hx_arrayForMinusWithOtherArray:(NSArray *)otherArray;
@end
