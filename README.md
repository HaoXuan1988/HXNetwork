# HXNetwork


## Usage

#### Creating a Download Task

```objective-c
HXResponseManager *manager = [HXResponseManager manager];

[manager downloadWithUrl:@"http://example.com/download.zip" saveToPath:nil fileName:nil progress:^(int64_t bytesRead, int64_t totalBytesRead) {
dispatch_async( dispatch_get_main_queue(), ^{
//code
});

} success:^(id _Nullable responseObject) {
//得到保存的沙盒路径

} failure:^(NSError * _Nullable error) {

}];
```

#### GET

```objective-c
HXResponseManager *manager = [HXResponseManager manager];

[manager updateBaseUrl:@"http://example.com?foo=bar&baz[]=1&baz[]=2&baz[]=3"];
//这里可以拼接 url
[manager getWithUrl:nil params:nil success:^(id _Nullable responseObject) {
//code...
} fail:^(NSError * _Nullable error) {

}];
```

#### POST

```objective-c
HXResponseManager *manager = [HXResponseManager manager];

[manager updateBaseUrl:@"http://example.com/"];
[manager postWithUrl:@"foo=bar&baz[]=1&baz[]=2&baz[]=3" params:nil success:^(id _Nullable responseObject) {
//code...
} fail:^(NSError *_Nullable error) {

}];
```

#### JSON

```objective-c
HXResponseManager *manager = [HXResponseManager manager];
//我在这里举个例子
//每次请求会恢复默认
[manager configRequestSerializerMethod:HXRequestSerializerMethodJSON];
[manager configCommonHttpHeaders:@{@"apikey":@"8e4dd1aebc9f047a58da2a0baeadfd34"}];//我 BaiduAPI 的 key
//请求参数
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
[manager postWithUrl:@"http://apis.baidu.com/idl_baidu/faceverifyservice/face_deleteuser" params:json success:^(id  _Nullable responseObject) {
//code...
} fail:^(NSError * _Nullable error) {

}];
```
