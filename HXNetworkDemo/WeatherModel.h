//
//  WeatherModel.h
//  HXNetworkDemo
//
//  Created by 吕浩轩 on 16/3/17.
//  Copyright © 2016年 吕浩轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Basic,Update,Now,Wind_3,Cond_2,Aqi,City,Suggestion,Drsg,Flu,Sport,Comf,Trav,Cw,Uv,Daily_Forecast,Cond,Wind_2,Tmp,Astro,Hourly_Forecast,Wind_1;
@interface WeatherModel : NSObject

@property (nonatomic, strong) NSArray<Hourly_Forecast *> *hourly_forecast;

@property (nonatomic, copy) NSString *status;

@property (nonatomic, strong) NSArray<Daily_Forecast *> *daily_forecast;

@property (nonatomic, strong) Now *now;

@property (nonatomic, strong) Aqi *aqi;

@property (nonatomic, strong) Basic *basic;

@property (nonatomic, strong) Suggestion *suggestion;

@end
@interface Basic : NSObject

@property (nonatomic, copy) NSString *cnty;

@property (nonatomic, copy) NSString *id;

@property (nonatomic, copy) NSString *lat;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSString *lon;

@property (nonatomic, strong) Update *update;

@end

@interface Update : NSObject

@property (nonatomic, copy) NSString *loc;

@property (nonatomic, copy) NSString *utc;

@end

@interface Now : NSObject

@property (nonatomic, copy) NSString *pres;

@property (nonatomic, copy) NSString *tmp;

@property (nonatomic, strong) Wind_3 *wind;

@property (nonatomic, copy) NSString *hum;

@property (nonatomic, copy) NSString *vis;

@property (nonatomic, strong) Cond_2 *cond;

@property (nonatomic, copy) NSString *fl;

@property (nonatomic, copy) NSString *pcpn;

@end

@interface Wind_3 : NSObject

@property (nonatomic, copy) NSString *dir;

@property (nonatomic, copy) NSString *deg;

@property (nonatomic, copy) NSString *sc;

@property (nonatomic, copy) NSString *spd;

@end

@interface Cond_2 : NSObject

@property (nonatomic, copy) NSString *txt;

@property (nonatomic, copy) NSString *code;

@end

@interface Aqi : NSObject

@property (nonatomic, strong) City *city;

@end

@interface City : NSObject

@property (nonatomic, copy) NSString *qlty;

@property (nonatomic, copy) NSString *pm25;

@property (nonatomic, copy) NSString *aqi;

@property (nonatomic, copy) NSString *co;

@property (nonatomic, copy) NSString *no2;

@property (nonatomic, copy) NSString *o3;

@property (nonatomic, copy) NSString *pm10;

@property (nonatomic, copy) NSString *so2;

@end

@interface Suggestion : NSObject

@property (nonatomic, strong) Drsg *drsg;

@property (nonatomic, strong) Flu *flu;

@property (nonatomic, strong) Sport *sport;

@property (nonatomic, strong) Comf *comf;

@property (nonatomic, strong) Trav *trav;

@property (nonatomic, strong) Cw *cw;

@property (nonatomic, strong) Uv *uv;

@end

@interface Drsg : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Flu : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Sport : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Comf : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Trav : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Cw : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Uv : NSObject

@property (nonatomic, copy) NSString *brf;

@property (nonatomic, copy) NSString *txt;

@end

@interface Daily_Forecast : NSObject

@property (nonatomic, strong) Astro *astro;

@property (nonatomic, copy) NSString *pres;

@property (nonatomic, strong) Tmp *tmp;

@property (nonatomic, strong) Wind_2 *wind;

@property (nonatomic, copy) NSString *hum;

@property (nonatomic, copy) NSString *date;

@property (nonatomic, copy) NSString *vis;

@property (nonatomic, strong) Cond *cond;

@property (nonatomic, copy) NSString *pcpn;

@property (nonatomic, copy) NSString *pop;

@end

@interface Cond : NSObject

@property (nonatomic, copy) NSString *txt_d;

@property (nonatomic, copy) NSString *code_n;

@property (nonatomic, copy) NSString *code_d;

@property (nonatomic, copy) NSString *txt_n;

@end

@interface Wind_2 : NSObject

@property (nonatomic, copy) NSString *dir;

@property (nonatomic, copy) NSString *deg;

@property (nonatomic, copy) NSString *sc;

@property (nonatomic, copy) NSString *spd;

@end

@interface Tmp : NSObject

@property (nonatomic, copy) NSString *max;

@property (nonatomic, copy) NSString *min;

@end

@interface Astro : NSObject

@property (nonatomic, copy) NSString *ss;

@property (nonatomic, copy) NSString *sr;

@end

@interface Hourly_Forecast : NSObject

@property (nonatomic, copy) NSString *pres;

@property (nonatomic, strong) Wind_1 *wind;

@property (nonatomic, copy) NSString *hum;

@property (nonatomic, copy) NSString *tmp;

@property (nonatomic, copy) NSString *pop;

@property (nonatomic, copy) NSString *date;

@end

@interface Wind_1 : NSObject

@property (nonatomic, copy) NSString *dir;

@property (nonatomic, copy) NSString *deg;

@property (nonatomic, copy) NSString *sc;

@property (nonatomic, copy) NSString *spd;

@end

