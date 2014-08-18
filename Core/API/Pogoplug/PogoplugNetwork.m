//
//  PogoplugNetwork.m
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Core.h"
#import "PogoplugNetwork.h"
#import "AFNetworking.h"

@interface PogoplugResponseSerializer : AFJSONResponseSerializer
- (instancetype)initWithRequestPath:(NSString *)requestPath;
@end

@implementation PogoplugNetwork
{
    AFHTTPRequestSerializer *_requestSerializer;
    NSTimeInterval _timeoutInterval;
    NSOperationQueue *_operationQueue;
    dispatch_queue_t _completionQueue;
}

- (id)init
{
    if (self = [super init]) {
        _requestSerializer = [AFJSONRequestSerializer serializer];
        _timeoutInterval = 15.0;
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
        _completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (NSOperation *)get:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    return [[self sharedInstance] send:@"GET" url:url path:path parameters:parameters data:nil serializer:nil completion:^(id object, NSError *error) {
        NSParameterAssert(!object || [object isKindOfClass:NSDictionary.class]);
        completion(object, error);
    }];
}

+ (void)post:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    [[self sharedInstance] send:@"POST" url:url path:path parameters:parameters data:nil serializer:nil completion:^(id object, NSError *error) {
        NSParameterAssert(!object || [object isKindOfClass:NSDictionary.class]);
        completion(object, error);
    }];
}

+ (void)head:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSError *))completion
{
    [[self sharedInstance] send:@"HEAD" url:url path:path parameters:parameters data:nil serializer:nil completion:^(id object, NSError *error) {
        completion(error);
    }];
}

+ (void) put:(NSURL *)url path:(NSString *)path data:(NSData *)data completion:(void (^)(NSError *))completion
{
    [[self sharedInstance] send:@"PUT" url:url path:path parameters:nil data:data serializer:nil completion:^(id object, NSError *error) {
        completion(error);
    }];
}

+ (void)down:(NSURL *)url path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion
{
    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
    [[self sharedInstance] send:@"GET" url:url path:path parameters:nil data:nil serializer:serializer completion:^(id object, NSError *error) {
        NSParameterAssert(!object || [object isKindOfClass:NSData.class]);
        completion(object, error);
    }];
}

- (NSOperation *)send:(NSString *)method url:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters data:(NSData *)data serializer:(AFHTTPResponseSerializer *)serializer completion:(void (^)(id object, NSError *error))completion
{
    NSParameterAssert(path.length > 0);
    
    if (0 == url.scheme.length || 0 == url.host.length) {
        NSAssert(NO, @"Invalid account base url:(%@).", url);
        NSError *error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:@"Pogoplug send request with invalid url." file:__FILE__ line:__LINE__];
        completion(nil, error);
        return nil;
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        NSError *error = [Error errorWithCode:Error_NetworkUnavailable subCode:Error_None underlyingError:nil debugString:@"Network not reachable." file:__FILE__ line:__LINE__];
        completion(nil, error);
        return nil;
    }
    
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:url] absoluteString];
    NSMutableURLRequest *request = [_requestSerializer requestWithMethod:method URLString:URLString parameters:parameters];
    if (_timeoutInterval > 0.0) {
        request.timeoutInterval = _timeoutInterval;
    }
    if (data) {
        request.HTTPBody = data;
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = serializer ? serializer : [[PogoplugResponseSerializer alloc] initWithRequestPath:path];
    operation.shouldUseCredentialStorage = NO;
    operation.credential = nil;
    operation.securityPolicy.allowInvalidCertificates = YES;
    operation.completionQueue = _completionQueue;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    
    [_operationQueue addOperation:operation];
    return operation;
}

@end

@implementation PogoplugResponseSerializer
{
    NSString *_requestPath;
}

- (id)initWithRequestPath:(NSString *)requestPath
{
    if (self = [super init]) {
        _requestPath = requestPath;
    }
    return self;
}

@end
