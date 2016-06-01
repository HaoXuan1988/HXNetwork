//
//  ViewController.m
//  HXNetworkDemo
//
//  Created by 吕浩轩 on 16/3/11.
//  Copyright © 2016年 吕浩轩. All rights reserved.
//

#import "ViewController.h"
#import "HXExtension.h"
#import "HXNetwork.h"
#import "WeatherModel.h"
#import "MJExtension.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = [NSMutableArray array];
    /*!
     @author 吕浩轩, 16-03-17 14:03:03
     
     每次请求后 header / HXResponseMethod / HXRequestSerializerMethod 恢复默认值
     当然如果另有需求可以自己更改...
     
     一般写在 AppDelegate
     */
    HXResponseManager *manager = [HXResponseManager manager];
    [manager updateBaseUrl:@"http://apis.baidu.com/heweather/weather/free"];
    
    
    
    
    
    
    
    
    /*!
     @author 吕浩轩, 16-03-17 14:03:49
     
     GET
     */
    [manager configCommonHttpHeaders:@{@"apikey":@"8e4dd1aebc9f047a58da2a0baeadfd34"}];
    //这里可以直接给 http:// .......
    [manager getWithUrl:@"" success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        for (NSDictionary *dic in [responseObject objectForKey:@"HeWeather data service 3.0"]) {
            
            WeatherModel *model = [WeatherModel mj_objectWithKeyValues:dic];
            [self.datas addObject:model];
            
            NSLog(@"pm2.5 : %@", model.aqi.city.pm25);
            
        }
    } fail:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
    }];


    
    
    
    
    
    
    
    /*!
     @author 吕浩轩, 16-03-17 14:03:33
     
     POST
     */
    [manager configCommonHttpHeaders:@{@"apikey":@"8e4dd1aebc9f047a58da2a0baeadfd34"}];
    [manager configCache:YES];
    [manager postWithUrl:nil params:@{@"city":@"北京"} success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        //code...
        
    } fail:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
    }];
    
    
    
    /*!
     @author 吕浩轩, 16-03-18 11:03:46
     
     
     JSON 请求 (人脸识别)
     
     
     
     返回参数说明：
     
     
     响应参数      必选           类型                说明
     
     id          true          string            请求标识,与请求中id一致
     result      true          Json对象           结果,协议格式，无意义
     _ret        true          Json对象           结果值,协议格式，无意义
     errnum      true          Int               返回码 示例值：0, 无错误， 其他值有错误
     errmsg      true          string            错误消息，示例值：目前为空
     
     **********(请求完成恢复默认 HTTP ,所以需要每次都下下面这句话,)***********
     */
    [manager configRequestSerializerMethod:HXRequestSerializerMethodJSON];
    [manager configCommonHttpHeaders:@{@"apikey":@"8e4dd1aebc9f047a58da2a0baeadfd34"}];
    NSDictionary *json = @{
                           @"params": @[
                                   @{
                                       @"username": @"test",
                                       @"cmdid": @"1000",
                                       @"logid": @"12345",
                                       @"appid": @"8e4dd1aebc9f047a58da2a0baeadfd34",
                                       @"clientip": @"10.23.34.5",
                                       @"type": @"st_groupverify",
                                       @"groupid": @"0",
                                       @"versionnum": @"1.0.0.1"
                                       }
                                   ],
                           @"jsonrpc": @"2.0",
                           @"method": @"Delete",
                           @"id": @12
                           };
    [manager postWithUrl:@"http://apis.baidu.com/idl_baidu/faceverifyservice/face_deleteuser" params:json success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        
        
    } fail:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
    }];
    
    
    /*!
     @author 吕浩轩, 16-03-17 14:03:36
     
     下载一个文件(例如图片)
     
     */
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:imageView];
    
    //这里也可以拼接 baseUrl
    [manager downloadWithUrl:@"http://b.hiphotos.baidu.com/album/pic/item/caef76094b36acafe72d0e667cd98d1000e99c5f.jpg?psign=e72d0e667cd98d1001e93901213fb80e7aec54e737d1b867" saveToPath:nil fileName:@"小狗.jpg" progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            //
        });
        
    } success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        //得到保存的沙盒路径
        //可以做一些事情 例如:
        [imageView setImage:[UIImage imageWithContentsOfFile:responseObject]];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        
    }];
    
    
    
 
    

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
