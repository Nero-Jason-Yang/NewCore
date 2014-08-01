//
//  AccountNetwork.m
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Core.h"
#import "AccountNetwork.h"
#import "AccountAPI.h"
#import "AFNetworking.h"

@interface AccountResponseSerializer : AFJSONResponseSerializer
- (instancetype)initWithRequestPath:(NSString *)requestPath;
@end

@implementation AccountNetwork
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

+ (void)post:(NSURL *)url path:(NSString *)path authorization:(NSString *)authorization parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSParameterAssert(path.length > 0);
    
    if (0 == url.scheme.length || 0 == url.host.length) {
        NSError *error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"invalid base url:%@", url] file:__FILE__ line:__LINE__];
        completion(nil, error);
        return;
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        NSError *error = [Error errorWithCode:Error_NetworkUnavailable subCode:Error_None underlyingError:nil debugString:@"network is not reachable" file:__FILE__ line:__LINE__];
        completion(nil, error);
        return;
    }
    
    if (!authorization) {
        NSError *error = [Error errorWithCode:Error_Unauthorized subCode:Error_None underlyingError:nil debugString:@"authorization is not specified" file:__FILE__ line:__LINE__];
        completion(nil, error);
        return;
    }
    
    [[self sharedInstance] post:url path:path authorization:authorization parameters:parameters completion:completion];
}

- (void)post:(NSURL *)url path:(NSString *)path authorization:(NSString *)authorization parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:url] absoluteString];
    NSMutableURLRequest *request = [_requestSerializer requestWithMethod:@"POST" URLString:URLString parameters:parameters];
    if (_timeoutInterval > 0.0) {
        request.timeoutInterval = _timeoutInterval;
    }
    if (authorization.length > 0) {
        [request setValue:authorization forHTTPHeaderField:@"authorization"];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [[AccountResponseSerializer alloc] initWithRequestPath:path];
    operation.shouldUseCredentialStorage = NO;
    operation.credential = nil;
    operation.securityPolicy.allowInvalidCertificates = YES;
    operation.completionQueue = _completionQueue;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *e = [Error errorWithCode:Error_Failed subCode:Error_None underlyingError:error debugString:@"post failed." file:__FILE__ line:__LINE__];
        completion(nil, e);
    }];
    
    [_operationQueue addOperation:operation];
}

@end

@implementation AccountResponseSerializer
{
    NSString *_requestPath;
}

- (instancetype)initWithRequestPath:(NSString *)requestPath
{
    NSParameterAssert(requestPath.length > 0);
    if (self = [super init]) {
        self.readingOptions = 0;
        _requestPath = requestPath;
    }
    return self;
}

#pragma mark <AFURLResponseSerialization>

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    // convert data to json.
    id json = [self JSONObjectFromData:data withResponse:response];
    
    // get exception code and message.
    NSString *exception = nil, *message = nil;
    if ([json isKindOfClass:NSDictionary.class]) {
        [self getDetails:json exceptionCode:&exception message:&message];
    }
    
    *error = [Error tryGetErrorWithAccountResponse:(id)response JSONObject:json requestPath:_requestPath];
    if (*error) {
        return nil;
    }
    
    return json;
}

#pragma mark internal

- (id)JSONObjectFromData:(NSData *)data withResponse:(NSURLResponse *)response
{
    if (!data) {
        return nil;
    }
    
    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    // See https://github.com/rails/rails/issues/1742
    NSStringEncoding stringEncoding = self.stringEncoding;
    if (response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
    if (responseString.length > 0) {
        // Workaround for a bug in NSJSONSerialization when Unicode character escape codes are used instead of the actual character
        // See http://stackoverflow.com/a/12843465/157142
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        if (responseData.length > 0) {
            NSError *error;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:self.readingOptions error:&error];
            if (!error) {
                return json;
            }
        }
    }
    
    return nil;
}

- (void)getDetails:(NSDictionary *)response exceptionCode:(NSString **)exceptionCode message:(NSString **)message
{
    NSParameterAssert([response isKindOfClass:NSDictionary.class]);
    NSParameterAssert(exceptionCode && message);
    
    NSDictionary *details = [response objectForKey:@"details"];
    if (![details isKindOfClass:NSDictionary.class]) {
        return;
    }
    
    NSArray *exceptionDetails = [details objectForKey:@"exception_details"];
    if ([exceptionDetails isKindOfClass:NSArray.class]) {
        for (NSDictionary *exception in exceptionDetails) {
            if ([self getException:exception code:exceptionCode message:message]) {
                break;
            }
        }
    }
    else if ([exceptionDetails isKindOfClass:NSDictionary.class]) {
        [self getException:(NSDictionary *)exceptionDetails code:exceptionCode message:message];
    }
    
    if (!*message) {
        *message = details[@"message"];
    }
}

- (BOOL)getException:(NSDictionary *)exception code:(NSString **)code message:(NSString **)message
{
    NSParameterAssert([exception isKindOfClass:NSDictionary.class]);
    NSParameterAssert(code && message);
    
    NSString *s_code = exception[@"code"];
    NSString *s_message = exception[@"message"];
    
    if ([s_code isKindOfClass:NSString.class]) {
        *code = s_code;
        *message = [s_message isKindOfClass:NSString.class] ? s_message : @"";
        return YES;
    }
    
    return NO;
}

@end
