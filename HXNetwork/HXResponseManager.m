//
//  HXResponse.m
//  HXResponse
//
//  Created by 吕浩轩 on 15/11/15.
//  Copyright © 2015年 吕浩轩. All rights reserved.
//

#import "HXResponseManager.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPSessionManager.h"
#import <CommonCrypto/CommonDigest.h>

/*
 * 打印日志
 */

#ifdef DEBUG
#define HXLog(format, ...) NSLog((@"———————————— * * * * *  HXNetwork 打印日志  * * * * * ————————————\n\n< 执行文件 >: %@ \n< 执行代码 >: %d 行 \n< 执行函数 >: %s \n< 执行内容 >: " format @"\n\n\n"), [[[NSString stringWithFormat:@"%s", __FILE__] componentsSeparatedByString:@"/"] lastObject], __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define HXLog(...) {}
#endif



@interface NSString (md5)

+ (NSString *)hxNetWork_md5:(NSString *)string;

@end

@implementation NSString (md5)

+ (NSString *)hxNetWork_md5:(NSString *)string {
    if (string == nil || [string length] == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    
    return [ms copy];
}

@end


static NSString *hx_privateNetworkBaseUrl = nil;
static BOOL hx_shouldAutoEncode = YES;
static BOOL hx_isCache = NO;
static NSDictionary *hx_httpHeaders = nil;
static NSMutableArray *hx_requestTasks;
static HXResponseMethod hx_responseMethod = HXResponseMethodJSON;
static HXRequestSerializerMethod  hx_requestSerializerMethod  = HXRequestSerializerMethodHTTP;
static NSString *fileData_key = @"fileData";
static NSString *name_key = @"name";
static NSString *fileName_key = @"fileName";
static NSString *mimeType_key = @"mimeType";

@implementation HXResponseManager

+ (nonnull instancetype)manager {
    
    static HXResponseManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)updateBaseUrl:(nonnull NSString *)baseUrl {
    hx_privateNetworkBaseUrl = baseUrl;
}

- (nonnull NSString *)baseUrl {
    return hx_privateNetworkBaseUrl;
}

- (void)cofigCache:(BOOL)isCache {
    hx_isCache = isCache;
}

- (void)configResponseMethod:(HXResponseMethod)responseMethod {
    hx_responseMethod = responseMethod;
}

- (void)configRequestSerializerMethod:(HXRequestSerializerMethod)requestSerializerMethod {
    hx_requestSerializerMethod = requestSerializerMethod;
}

- (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode {
    hx_shouldAutoEncode = shouldAutoEncode;
}

- (BOOL)shouldEncode {
    return hx_shouldAutoEncode;
}

- (void)configCommonHttpHeaders:(nullable NSDictionary *)httpHeaders {
    hx_httpHeaders = httpHeaders;
}

-(void)configFileData_key:(nonnull NSString *)key {
    fileData_key = key;
}

- (void)configName_key:(nonnull NSString *)key {
    name_key = key;
}

- (void)configFileName_key:(nonnull NSString *)key {
    fileName_key = key;
}

- (void)configMimeType_key:(nonnull NSString *)key {
    mimeType_key = key;
}

- (void)setCompletionBlockWithSuccess:(HXResponseSuccess)success failure:(HXResponseFail)failure {
    self.responseSuccess = success;
    self.responseFail = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.responseSuccess = nil;
    self.responseFail = nil;
}

static inline NSString *cachePath() {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HXNetworkCaches"];
}

- (void)clearCaches {
    NSString *directoryPath = cachePath();
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
        
        if (error) {
            SLog(@" 清 除 缓 存 错 误: %@", error.localizedDescription);
        } else {
            SLog(@" 清 除 缓 存 完 成");
        }
    }
}

- (unsigned long long)totalCacheSize {
    NSString *directoryPath = cachePath();
    BOOL isDir = NO;
    unsigned long long total = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
        if (isDir) {
            NSError *error = nil;
            NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
            
            if (error == nil) {
                for (NSString *subpath in array) {
                    NSString *path = [directoryPath stringByAppendingPathComponent:subpath];
                    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path
                                                                                          error:&error];
                    if (!error) {
                        total += [dict[NSFileSize] unsignedIntegerValue];
                    }
                }
            }
        }
    }
    
    return total;
}

- (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (hx_requestTasks == nil) {
            hx_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    
    return hx_requestTasks;
}

- (void)cancelAllRequest {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HXURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[HXURLSessionTask class]]) {
                [task cancel];
            }
        }];
        
        [[self allTasks] removeAllObjects];
    };
}

- (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HXURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[HXURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}


- (nullable HXURLSessionTask *)getWithUrl:(nullable NSString *)url
                                  success:(nullable HXResponseSuccess)success
                                     fail:(nullable HXResponseFail)fail {
    return [self getWithUrl:url
                     params:nil
                    success:success
                       fail:fail];
}

- (nullable HXURLSessionTask *)getWithUrl:(nullable NSString *)url
                                   params:(nullable NSDictionary *)params
                                  success:(nullable HXResponseSuccess)success
                                     fail:(nullable HXResponseFail)fail {
    return [self getWithUrl:url
                     params:params
                   progress:nil
                    success:success
                       fail:fail];
}

- (nullable HXURLSessionTask *)getWithUrl:(nullable NSString *)url
                                   params:(nullable NSDictionary *)params
                                 progress:(nullable HXGetProgress)progress
                                  success:(nullable HXResponseSuccess)success
                                     fail:(nullable HXResponseFail)fail {
    
    return [self _requestWithUrl:url
                       httpMedth:HXRequestMethodGet
                          params:params
                    networkCache:hx_isCache
                        progress:progress
                         success:success
                            fail:fail];
}

- (nullable HXURLSessionTask *)postWithUrl:(nullable NSString *)url
                                    params:(nullable NSDictionary *)params
                                   success:(nullable HXResponseSuccess)success
                                      fail:(nullable HXResponseFail)fail {
    return [self postWithUrl:url
                      params:params
                    progress:nil
                     success:success
                        fail:fail];
}

- (nullable HXURLSessionTask *)postWithUrl:(nullable NSString *)url
                                    params:(nullable NSDictionary *)params
                                  progress:(nullable HXPostProgress)progress
                                   success:(nullable HXResponseSuccess)success
                                      fail:(nullable HXResponseFail)fail {
    
    return [self _requestWithUrl:url
                       httpMedth:HXRequestMethodPost
                          params:params
                    networkCache:hx_isCache
                        progress:progress
                         success:success
                            fail:fail];
}

- (HXURLSessionTask *)_requestWithUrl:(nullable NSString *)url
                            httpMedth:(HXRequestMethod)httpMethod
                               params:(nullable NSDictionary *)params
                         networkCache:(BOOL)networkCache
                             progress:(nullable HXDownloadProgress)progress
                              success:(nullable HXResponseSuccess)success
                                 fail:(nullable HXResponseFail)fail {
    
    AFHTTPSessionManager *manager = [self managers];
    /**
     *  处理 url
     */
    url = [self hx_handleURL:url];
    
    if ([NSURL URLWithString:url] == nil) {
        SLog(@"请重新检查 baseUrl / url ");
        return nil;
    }
    
    /**
     *  这里只有 GET 和 POST 添加了缓存机制
     */
    if (httpMethod == HXRequestMethodGet || httpMethod == HXRequestMethodPost) {
        /**
         *  获取缓存
         */
        if (networkCache) {
            
            id response = [self cahceResponseWithURL:url parameters:params];
            if (response) {
                self.responseSuccess = success;
                if (self.responseSuccess) {
                    self.responseSuccess(nil, [self tryToParseData:response]);
                }
            }
        }
    }
    
    NSURLSessionTask *session;
    
    switch (httpMethod) {
        case HXRequestMethodGet: {
            
            session = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progress) {
                    progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self successResponse:responseObject task:task callback:success];
                
                /**
                 *  存储数据
                 */
                [self cacheResponseObject:responseObject request:task.currentRequest  parameters:params isCache:networkCache];
                
                [self logWithSuccessResponse:responseObject url:task.response.URL.absoluteString params:params];
                [[self allTasks] removeObject:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (fail) {
                    fail(error);
                }
                [self logWithFailError:error url:url params:params];
                [[self allTasks] removeObject:task];
            }];
            
            break;
        }
        case HXRequestMethodPost: {
            
            session = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progress) {
                    progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self successResponse:responseObject task:task callback:success];
                
                /**
                 *  存储数据
                 */
                [self cacheResponseObject:responseObject request:task.currentRequest  parameters:params isCache:networkCache];
                
                [self logWithSuccessResponse:responseObject url:task.response.URL.absoluteString params:params];
                [[self allTasks] removeObject:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (fail) {
                    fail(error);
                }
                [self logWithFailError:error url:url params:params];
                [[self allTasks] removeObject:task];
            }];
            
            break;
        }
        case HXRequestMethodHead: {
            
            session = [manager HEAD:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task) {
                [self successResponse:nil task:task callback:success];
                [self logWithSuccessResponse:nil url:task.response.URL.absoluteString params:params];
                [[self allTasks] removeObject:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (fail) {
                    fail(error);
                }
                [self logWithFailError:error url:url params:params];
                [[self allTasks] removeObject:task];
            }];
            
            break;
        }
        case HXRequestMethodPut: {
            
            session = [manager PUT:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self successResponse:responseObject task:task callback:success];
                [self logWithSuccessResponse:responseObject url:task.response.URL.absoluteString params:params];
                [[self allTasks] removeObject:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (fail) {
                    fail(error);
                }
                [self logWithFailError:error url:url params:params];
                [[self allTasks] removeObject:task];
            }];
            
            break;
        }
        case HXRequestMethodDelete: {
            
            session = [manager DELETE:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self successResponse:responseObject task:task callback:success];
                [self logWithSuccessResponse:responseObject url:task.response.URL.absoluteString params:params];
                [[self allTasks] removeObject:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (fail) {
                    fail(error);
                }
                [self logWithFailError:error url:url params:params];
                [[self allTasks] removeObject:task];
            }];
            
            break;
        }
        case HXRequestMethodPatch: {
            
            session = [manager PATCH:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self successResponse:responseObject task:task callback:success];
                [self logWithSuccessResponse:responseObject url:task.response.URL.absoluteString params:params];
                [[self allTasks] removeObject:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (fail) {
                    fail(error);
                }
                [self logWithFailError:error url:url params:params];
                [[self allTasks] removeObject:task];
            }];
            
            break;
        }
        default:
            break;
    }
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    /**
     *  恢复默认
     */
    [self restoreDefaults];
    return session;
}

- (nullable HXURLSessionTask *)uploadFileWithUrl:(nonnull NSString *)url
                               uploadingFilePath:(nonnull NSString *)uploadingFilePath
                                        progress:(nullable HXUploadProgress)progress
                                         success:(nullable HXResponseSuccess)success
                                            fail:(nullable HXResponseFail)fail {
    
    url = [self hx_handleURL:url];
    if ([NSURL URLWithString:url] == nil) {
        SLog(@"URLString无效，无法生成URL。%@", url);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    uploadingFilePath = [self hx_URLEncodedString:uploadingFilePath];
    if (!uploadingFilePath) {
        SLog(@"uploadingFilePath 无效，无法生成URL。请检查待上传文件是否存在  %@", uploadingFilePath);
        return nil;
    }
    NSURL *fromFile = [NSURL fileURLWithPath:uploadingFilePath];
    
    if (!request || !fromFile) {
        SLog(@"请重新检查 URL: %@ ===> FilePath: %@", url, uploadingFilePath);
        return nil;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionUploadTask *session = [manager uploadTaskWithRequest:request fromFile:fromFile progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (fail) {
                fail(error);
            }
            [self clearCompletionBlock];
            HXLog(@" >>>>——————————> 💔 上 传 失 败 💔 <————————————<<<<\n>>> 上传地址: %@\n>>> 文件路径: %@\n>>> 错误信息: %@\n",[self hx_URLDecodedString:url], [self hx_URLDecodedString:uploadingFilePath], [error localizedDescription]);
        } else {
            [self successResponse:responseObject task:nil callback:success];
            [self clearCompletionBlock];
            HXLog(@" >>>>——————————> ❤️ 上 传 成 功 ❤️ <————————————<<<<\n>>> 上传地址: %@\n>>> 文件路径: %@\n>>> 返回数据: %@\n",[self hx_URLDecodedString:url], [self hx_URLDecodedString:uploadingFilePath], responseObject);
        }
        [[self allTasks] removeObject:session];
    }];
    
    [session resume];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    /**
     *  恢复默认
     */
    [self restoreDefaults];
    
    return session;
}

- (nullable HXURLSessionTask *)uploadWithUrl:(nonnull NSString *)url
                                 fileSources:(nonnull NSArray<NSDictionary *> *)fileSources
                                  parameters:(nullable NSDictionary *)parameters
                                    progress:(nullable HXUploadProgress)progress
                                     success:(nullable HXResponseSuccess)success
                                        fail:(nullable HXResponseFail)fail {
    url = [self hx_handleURL:url];
    if ([NSURL URLWithString:url] == nil) {
        SLog(@"URLString无效，无法生成URL。%@", url);
        return nil;
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSDictionary *dic in fileSources) {
            id imageData = [dic valueForKey:fileData_key];
            NSString *name = [dic valueForKey:name_key];
            NSString *fileName = [dic valueForKey:fileName_key];
            NSString *mimeType = [dic valueForKey:mimeType_key];
            if (name == nil || ![name isKindOfClass:[NSString class]] || name.length == 0) {
                if (fileName == nil || ![fileName isKindOfClass:[NSString class]] || fileName.length == 0) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyyMMddHHmmss";
                    name = [formatter stringFromDate:[NSDate date]];
                    fileName = [NSString stringWithFormat:@"%@.jpg", name];
                }else{
                    NSArray *nameArray = [fileName componentsSeparatedByString:@"."];
                    name = [nameArray firstObject];
                }
            }else{
                if (fileName == nil || ![fileName isKindOfClass:[NSString class]] || fileName.length == 0) {
                    fileName = [NSString stringWithFormat:@"%@.jpg", name];
                }
            }
            if (mimeType == nil || ![mimeType isKindOfClass:[NSString class]] || mimeType.length == 0) {
                mimeType = @"image/jpeg";
            }
            if (imageData != nil && imageData != NULL && [imageData isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:mimeType];
            }else if (imageData != nil && imageData != NULL && [imageData isKindOfClass:[NSString class]]) {
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:imageData] name:name fileName:fileName mimeType:mimeType error:nil];
            }else if (imageData != nil && imageData != NULL && [imageData isKindOfClass:[UIImage class]]) {
                NSData *data = UIImageJPEGRepresentation((UIImage *)imageData, 1);
                [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
            }
        }
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *session = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (fail) {
                fail(error);
            }
            [self clearCompletionBlock];
            HXLog(@" >>>>——————————> 💔 上 传 失 败 💔 <————————————<<<<\n>>> 上传地址: %@\n>>> 文件信息: %@\n>>> 携带参数: %@\n>>> 错误信息: %@\n",[self hx_URLDecodedString:url], fileSources, parameters, [error localizedDescription]);
        } else {
            [self successResponse:responseObject task:nil callback:success];
            
            [self clearCompletionBlock];
            HXLog(@" >>>>——————————> ❤️ 上 传 成 功 ❤️ <————————————<<<<\n>>> 上传地址: %@\n>>> 文件信息: %@\n>>> 携带参数: %@\n>>> 返回数据: %@\n",[self hx_URLDecodedString:url], fileSources, parameters, responseObject);
        }
        [[self allTasks] removeObject:session];
    }];
    
    [session resume];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    /**
     *  恢复默认
     */
    [self restoreDefaults];
    
    return session;
}

- (nullable HXURLSessionTask *)downloadWithUrl:(nonnull NSString *)url
                                    saveToPath:(nullable NSString *)saveToPath
                                      fileName:(nullable NSString *)fileName
                                      progress:(nullable HXDownloadProgress)progressBlock
                                       success:(nullable HXResponseSuccess)success
                                       failure:(nullable HXResponseFail)failure {
    
    url = [self hx_handleURL:url];
    if ([NSURL URLWithString:url] == nil) {
        SLog(@"URLString无效，无法生成URL。%@", url);
        return nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *session = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (saveToPath) {
            // 判断文件夹是否存在，如果不存在，则创建
            if (![[NSFileManager defaultManager] fileExistsAtPath:saveToPath]) {
                NSFileManager *fileManager = [[NSFileManager alloc] init];
                [fileManager createDirectoryAtPath:saveToPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            if (fileName) {
                return [[NSURL fileURLWithPath:saveToPath] URLByAppendingPathComponent:fileName];
            } else {
                return [[NSURL fileURLWithPath:saveToPath] URLByAppendingPathComponent:[response suggestedFilename]];
            }
        }else{
            if (fileName) {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:fileName];
            } else {
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
            }
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failure(error);
            [self clearCompletionBlock];
            HXLog(@" >>>>——————————> 💔 下 载 失 败 💔 <————————————<<<<\n>>> 下载地址: %@\n>>> 错误信息:%@\n",[self hx_URLDecodedString:url], [error localizedDescription]);
        } else if (success) {
            NSString *path = [filePath.absoluteString substringFromIndex:7];
            path = [self hx_URLDecodedString:path];
            
            [self successResponse:path task:nil callback:success];
            [self clearCompletionBlock];
            HXLog(@" >>>>——————————> ❤️ 下 载 成 功 ❤️ <————————————<<<<\n>>> 下载地址: %@\n>>> 沙盒路径:%@\n",url, path);
        }
        [[self allTasks] removeObject:session];
    }];
    [session resume];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
    /**
     *  恢复默认
     */
    [self restoreDefaults];
    
    return session;
}

#pragma mark - Private
- (AFHTTPSessionManager *)managers {
    // 开启转圈圈
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //支持 https
    manager.securityPolicy.allowInvalidCertificates = YES;
    
    switch (hx_requestSerializerMethod) {
        case HXRequestSerializerMethodHTTP: {
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        }
        case HXRequestSerializerMethodJSON: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        }
        default: {
            break;
        }
    }
    
    switch (hx_responseMethod) {
        case HXResponseMethodJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case HXResponseMethodXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
        case HXResponseMethodData: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        default: {
            break;
        }
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    //如果有请求头,添加请求头
    for (NSString *key in hx_httpHeaders.allKeys) {
        if (hx_httpHeaders[key] != nil) {
            [manager.requestSerializer setValue:hx_httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    //响应数据支持的类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*"]];
    
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 4;
    
    return manager;
}

- (void)restoreDefaults {
    //恢复默认
    hx_httpHeaders = nil;
    hx_shouldAutoEncode = YES;
    hx_isCache = NO;
    hx_responseMethod = HXResponseMethodJSON;
    hx_requestSerializerMethod = HXRequestSerializerMethodHTTP;
}

- (void)logWithSuccessResponse:(id)response url:(NSString *)url params:(NSDictionary *)params {
    [self clearCompletionBlock];
    HXLog(@" >>>>——————————> ❤️ 请 求 成 功 ❤️ <————————————<<<<\n>>> 请求接口: %@\n>>> 请求参数: %@\n>>> 返回数据: %@\n",[self hx_URLDecodedString:url],params,response);
}

- (void)logWithFailError:(NSError *)error url:(NSString *)url params:(NSDictionary *)params {
    [self clearCompletionBlock];
    HXLog(@" >>>>——————————> 💔 请 求 失 败 💔 <————————————<<<<\n>>> 请求接口: %@\n>>> 请求参数: %@\n>>> 错误信息: %@\n",[self hx_URLDecodedString:url],params,[error localizedDescription]);
}

- (NSString *)hx_handleURL:(NSString *)string {
    
    if (![string hasPrefix:@"http://"] && ![string hasPrefix:@"https://"]) {
        
        if ([self baseUrl] == nil) {
            if (string == nil) {
                return nil;
            }
        } else {
            if (string == nil) {
                string = [self baseUrl];
            } else {
                string = [NSString stringWithFormat:@"%@%@", [self baseUrl], string];
            }
        }
    }
    
    
    if ([self shouldEncode]) {
        string = [self hx_URLEncodedString:string];
    }
    return string;
}

- (id)tryToParseData:(id)responseData {
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

- (void)successResponse:(_Nullable id)responseData task:(NSURLSessionDataTask * _Nullable)task callback:(_Nullable HXResponseSuccess)success {
    
    self.responseSuccess = success;
    if (self.responseSuccess) {
        self.responseSuccess(task, [self tryToParseData:responseData]);
    }
    
}

// 仅对一级字典结构起作用
- (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
        return url;
    }
    
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}

- (id)cahceResponseWithURL:(NSString *)url parameters:params {
    id cacheData = nil;
    
    if (url) {
        // Try to get datas from disk
        NSString *directoryPath = cachePath();
        NSString *absoluteURL = [self generateGETAbsoluteURL:url params:params];
        NSString *key = [NSString hxNetWork_md5:absoluteURL];
        NSString *path = [directoryPath stringByAppendingPathComponent:key];
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        if (data) {
            cacheData = data;
            SLog(@"读 取 缓 存: %@\n", url);
        }
    }
    
    return cacheData;
}

- (void)cacheResponseObject:(id)responseObject request:(NSURLRequest *)request parameters:params isCache:(BOOL)isCache {
    if (!isCache) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (request && responseObject && ![responseObject isKindOfClass:[NSNull class]]) {
            NSString *directoryPath = cachePath();
            
            NSError *error = nil;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
                if (error) {
                    SLog(@" 创 建 缓 存 错 误 信 息: %@\n", error.localizedDescription);
                    return;
                }
            }
            
            NSString *absoluteURL = [self generateGETAbsoluteURL:request.URL.absoluteString params:params];
            NSString *key = [NSString hxNetWork_md5:absoluteURL];
            NSString *path = [directoryPath stringByAppendingPathComponent:key];
            NSDictionary *dict = (NSDictionary *)responseObject;
            
            NSData *data = nil;
            if ([dict isKindOfClass:[NSData class]]) {
                data = responseObject;
            } else {
                data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
            }
            
            if (data && error == nil) {
                BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
                if (isOk) {
                    SLog(@" 缓 存 请 求 完 成 : %@\n", absoluteURL);
                } else {
                    SLog(@" 缓 存 请 求 失 败 : %@\n", absoluteURL);
                }
            }
        }
    });
}

//编码
- (NSString *)hx_URLEncodedString:(NSString *)string {
    NSString *newString = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    if (newString) {
        return newString;
    }
    
    return string;
}


//解码
-(NSString *)hx_URLDecodedString:(NSString*)string {
    
    NSString *newString = CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
                                                                                       (CFStringRef)string,
                                                                                       CFSTR("")));
    if (newString) {
        return newString;
    }
    
    return string;
}

/**
 *  网络判断 稍后再弄 (复制这段代码就可以了,没什么必要再写了)
 */
- (void)reachability {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        SLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        switch (status) {
                
            case AFNetworkReachabilityStatusUnknown:{
                
                SLog(@"未知");
                
                break;
                
            }
            case AFNetworkReachabilityStatusNotReachable:{
                
                SLog(@"无网络");
                
                break;
                
            }
                
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                
                SLog(@"WiFi网络");
                
                break;
                
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                
                SLog(@"蜂窝网络");
                
                break;
                
            }
                
            default:
                
                break;
                
        }
        
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
