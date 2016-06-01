//
//  HXResponse.h
//  HXResponse
//
//  Created by 吕浩轩 on 15/11/15.
//  Copyright © 2015年 吕浩轩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#ifndef __OPTIMIZE__
#define SLog(...) NSLog(__VA_ARGS__)
#else
#define SLog(...) {}
#endif


/**
 *  下载进度
 *
 *  @param bytesRead                 已下载的大小
 *  @param totalBytesRead            文件总大小
 *  @param totalBytesExpectedToRead 还有多少需要下载
 */
typedef void (^HXDownloadProgress)(int64_t bytesRead,
                                   int64_t totalBytesRead);

typedef HXDownloadProgress HXGetProgress;
typedef HXDownloadProgress HXPostProgress;

/**
 *  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytesWritten         总上传大小
 */
typedef void (^HXUploadProgress)(int64_t bytesWritten,
                                 int64_t totalBytesWritten);

typedef NS_ENUM(NSUInteger, HXResponseMethod) {
    HXResponseMethodJSON = 1, // 默认
    HXResponseMethodXML  = 2, // XML
    // 特殊情况下，一转换服务器就无法识别的，默认会尝试转换成JSON，若失败则需要自己去转换
    HXResponseMethodData = 3
};

typedef NS_ENUM(NSInteger , HXRequestSerializerMethod) {
    HXRequestSerializerMethodHTTP = 1,
    HXRequestSerializerMethodJSON,
};

typedef NS_ENUM(NSUInteger, HXRequestMethod) {
    HXRequestMethodGet = 1,
    HXRequestMethodPost,
    HXRequestMethodHead,
    HXRequestMethodPut,
    HXRequestMethodDelete,
    HXRequestMethodPatch
};

@class NSURLSessionTask;

// 请勿直接使用NSURLSessionDataTask,以减少对第三方的依赖
// 所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值
// 且处理，请转换成对应的子类类型
typedef NSURLSessionTask HXURLSessionTask;

/**
 *  请求成功的回调
 *
 *  @param cache          YES 代表是缓存, NO 代表是新数据
 *  @param responseObject 服务端返回的数据类型，通常是字典
 */
typedef void(^HXResponseSuccess)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject);

/**
 *  网络响应失败时的回调
 *
 *  @param error 错误信息
 */
typedef void(^HXResponseFail)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error);

/**
 *  基于AFNetworking的网络层封装类.
 *
 *  @note 这里只提供公共api
 */
@interface HXResponseManager : NSObject

@property (nonatomic, copy) __nullable HXResponseSuccess responseSuccess;
@property (nonatomic, copy) __nullable HXResponseFail responseFail;

/**
 *  初始化
 *
 *  @return HXResponseManager
 */
+ (nonnull instancetype)manager;

/**
 *  用于指定网络请求接口的基础url，如：
 *  http://baidu.com或者http://202.108.22.5
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl 网络接口的基础url
 */
- (void)updateBaseUrl:(nonnull NSString *)baseUrl;

/**
 *  对外公开可获取当前所设置的网络接口基础url
 *
 *  @return 当前基础url
 */
- (nonnull NSString *)baseUrl;

/**
 *  是否缓存
 *
 *  @param isCache  BOOL
 */
- (void)configCache:(BOOL)isCache;

/**
 *  配置返回格式，默认为JSON。若为XML或者PLIST请在全局修改一下
 *
 *  @param responseMethod 响应格式
 */
- (void)configResponseMethod:(HXResponseMethod)responseMethod;

/**
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestMethod 请求格式
 */
- (void)configRequestSerializerMethod:(HXRequestSerializerMethod)requestSerializerMethod;

/**
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
- (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/**
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
- (void)configCommonHttpHeaders:(nullable NSDictionary *)httpHeaders;

/**
 *  重新配置源文件对应的 key
 *
 *  @param key  默认是 @"fileData"
 */
-(void)configFileData_key:(nonnull NSString *)key;

/**
 *  重新配置源文件名对应的 key
 *
 *  @param key 默认是 @"name"
 */
- (void)configName_key:(nonnull NSString *)key;

/**
 *  重新配置源文件全名对应的 key
 *
 *  @param key 默认是 @"fileName"
 */
- (void)configFileName_key:(nonnull NSString *)key;

/**
 *  重新配置源文件类型对应的 key
 *
 *  @param key 默认是 @"mimeType"
 */
- (void)configMimeType_key:(nonnull NSString *)key;

/**
 *  网络判断
 */
- (void)reachability;

/**
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList?categoryid=1
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)getWithUrl:(nullable NSString *)url
                                  success:(nullable HXResponseSuccess)success
                                     fail:(nullable HXResponseFail)fail;
/**
 *  带 参数 的 GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList
 *  @param params  接口中所需要的拼接参数，如@{"categoryid" : @(12)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)getWithUrl:(nullable NSString *)url
                                   params:(nullable NSDictionary *)params
                                  success:(nullable HXResponseSuccess)success
                                     fail:(nullable HXResponseFail)fail;
/**
 *  带 参数 和 progress 的 GET 请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url      接口路径，如/path/getArticleList
 *  @param params   接口中所需要的拼接参数，如@{"categoryid" : @(12)}
 *  @param progress 注意:在主线程更新 UI
 *  @param success  接口成功请求到数据的回调
 *  @param fail     接口请求数据失败的回调
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)getWithUrl:(nullable NSString *)url
                                   params:(nullable NSDictionary *)params
                                 progress:(nullable HXGetProgress)progress
                                  success:(nullable HXResponseSuccess)success
                                     fail:(nullable HXResponseFail)fail;

/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList
 *  @param params  接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)postWithUrl:(nullable NSString *)url
                                    params:(nullable NSDictionary *)params
                                   success:(nullable HXResponseSuccess)success
                                      fail:(nullable HXResponseFail)fail;

/**
 *  带 progress 的 POST 请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url      接口路径，如/path/getArticleList
 *  @param params   接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param progress 注意:在主线程更新 UI
 *  @param success  接口成功请求到数据的回调
 *  @param fail     接口请求数据失败的回调
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)postWithUrl:(nullable NSString *)url
                                    params:(nullable NSDictionary *)params
                                  progress:(nullable HXPostProgress)progress
                                   success:(nullable HXResponseSuccess)success
                                      fail:(nullable HXResponseFail)fail;


/**
 *   多张图片上传接口，可传完整的url  (多任务处理)
 *
 *  @param url         上传图片的接口路径，如/path/images/
 *  @param fileSources 源文件数组<字典>  例如: @[
 @{
 @"fileData": UIImage / Data / Path( 沙盒路径 FileURL),只能是这三种类型
 @"name": @"随便", 可以是nil
 @"fileName": @"12345",
 @"mimeType": @"image/jepg"
 }
 ]
 *  @param parameters  携带参数 可以是 nil
 *  @param progress    上传进度(回到主线程更新UI)
 *  @param success     上传成功回调
 *  @param fail        上传失败回调
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)uploadWithUrl:(nonnull NSString *)url
                                 fileSources:(nonnull NSArray<NSDictionary *> *)fileSources
                                  parameters:(nullable NSDictionary *)parameters
                                    progress:(nullable HXUploadProgress)progress
                                     success:(nullable HXResponseSuccess)success
                                        fail:(nullable HXResponseFail)fail;

/**
 *	上传文件操作
 *
 *	@param url                  上传路径
 *	@param uploadingFile        待上传文件的路径
 *	@param progress             上传进度
 *	@param success				上传成功回调
 *	@param fail					上传失败回调
 *
 *	@return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)uploadFileWithUrl:(nonnull NSString *)url
                               uploadingFilePath:(nonnull NSString *)uploadingFilePath
                                        progress:(nullable HXUploadProgress)progress
                                         success:(nullable HXResponseSuccess)success
                                            fail:(nullable HXResponseFail)fail;


/*
 *  下载文件
 *
 *  @param url           下载URL
 *  @param saveToPath    下载到哪个路径下
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 *
 *	@return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)downloadWithUrl:(nonnull NSString *)url
                                    saveToPath:(nullable NSString *)saveToPath
                                      fileName:(nullable NSString *)fileName
                                      progress:(nullable HXDownloadProgress)progressBlock
                                       success:(nullable HXResponseSuccess)success
                                       failure:(nullable HXResponseFail)failure;

/**
 *  HEAD 请求 不带参数
 *
 *  @param url     URL
 *  @param success 成功
 *  @param fail    失败
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)headWithUrl:(nullable NSString *)url
                                   success:(nullable HXResponseSuccess)success
                                      fail:(nullable HXResponseFail)fail;

/**
 *  HEAD 请求 带参数
 *
 *  @param url     URL
 *  @param params   参数
 *  @param success 成功
 *  @param fail    失败
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)headWithUrl:(nullable NSString *)url
                                    params:(nullable NSDictionary *)params
                                   success:(nullable HXResponseSuccess)success
                                      fail:(nullable HXResponseFail)fail;

/**
 *  通用的请求
 *
 *  @param url          URL
 *  @param httpMethod   httpMethod
 *  @param params       参数
 *  @param networkCache 缓存
 *  @param progress     进度
 *  @param success      成功
 *  @param fail         失败
 *
 *  @return NSURLSessionTask
 */
- (nullable HXURLSessionTask *)requestWithUrl:(nullable NSString *)url
                           httpMedth:(HXRequestMethod)httpMethod
                              params:(nullable NSDictionary *)params
                        networkCache:(BOOL)networkCache
                            progress:(nullable HXDownloadProgress)progress
                             success:(nullable HXResponseSuccess)success
                                fail:(nullable HXResponseFail)fail;

@end
