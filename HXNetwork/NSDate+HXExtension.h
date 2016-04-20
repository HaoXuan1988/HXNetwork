//
//  NSDate+HXExtension.h
//  HXNetworkDemo
//
//  Created by 吕浩轩 on 16/4/11.
//  Copyright © 2016年 吕浩轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HXExtension)

/*
 *  时间戳
 */
@property (nonatomic,copy,readonly) NSString *timestamp;



/*
 *  时间成分
 */
@property (nonatomic,strong,readonly) NSDateComponents *components;




/*
 *  是否是今年
 */
@property (nonatomic,assign,readonly) BOOL isThisYear;




/*
 *  是否是今天
 */
@property (nonatomic,assign,readonly) BOOL isToday;




/*
 *  是否是昨天
 */
@property (nonatomic,assign,readonly) BOOL isYesToday;




/**
 *  两个时间比较
 *
 *  @param unit     成分单元
 *  @param fromDate 起点时间
 *  @param toDate   终点时间
 *
 *  @return 时间成分对象
 */
+(NSDateComponents *)dateComponents:(NSCalendarUnit)unit fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
@end
