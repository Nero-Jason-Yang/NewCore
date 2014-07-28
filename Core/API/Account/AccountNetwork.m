//
//  AccountNetwork.m
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "AccountNetwork.h"
#import "AccountError.h"
#import "AFNetworking.h"

@interface AccountRequestOperationManager : AFHTTPRequestOperationManager
- (instancetype)initWithBaseURL:(NSURL *)url;
@end

@interface AccountResponseSerializer : AFJSONResponseSerializer

@end

@implementation AccountNetwork

+ (NSOperationQueue *)operationQueue
{
    static NSOperationQueue *queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
    });
    return queue;
}

+ (void)post:(NSURL *)url path:(NSString *)path authorization:(NSString *)authorization parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSParameterAssert(path.length > 0);
    
    if (0 == url.scheme.length || 0 == url.host.length) {
        NSAssert(NO, @"Invalid account base url:(%@).", url);
        NSError *error = [AccountError errorWithCode:AccountError_HostUnspecified];
        completion(nil, error);
        return;
    }
    
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        NSError *error = [AccountError errorWithCode:AccountError_NetworkNotAvailable];
        completion(nil, error);
        return;
    }
    
    if (!authorization) {
        NSError *error = [AccountError errorWithCode:AccountError_Unauthorized];
        completion(nil, error);
        return;
    }
    
    NSDictionary *header = nil;
    if (authorization.length > 0) {
        header = @{@"authorization":authorization};
    }
    
    // TODO
    // ...
}

@end

@implementation AccountRequestOperationManager

- (instancetype)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        self.responseSerializer = [AccountResponseSerializer serializer];
        self.securityPolicy.allowInvalidCertificates = YES;
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)post:(NSURL *)url path:(NSString *)path authorization:(NSString *)authorization parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSString *URLString = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:URLString parameters:parameters];
    if (authorization.length > 0) {
        [request setValue:authorization forHTTPHeaderField:@"authorization"];
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    
    [self.operationQueue addOperation:operation];
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

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    id json = [self JSONObjectFromData:data withResponse:response];
    
    NSInteger statusCode = 200;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (statusCode == 503) {
            NSString *description = nil;
            NSDictionary *info = nil;
            if (json) {
                NSDictionary *details = json[@"details"];
                if ([details isKindOfClass:NSDictionary.class]) {
                    description = details[@"message"];
                }
                info = details;
            }
            *error = [AccountError errorWithCode:AccountError_ServiceUnavailable description:description info:info];
            return nil;
        }
    }
    
    if (!json) {
        return [super responseObjectForResponse:response data:data error:error];
    }
    
    NSString *message;
    NSString *code = [self exceptionCodeFromDictionary:json exceptionMessage:&message];
    if (code) {
        *error = [self errorWithStatusCode:statusCode exceptionCode:code message:message];
        return nil;
    }
    
    if (statusCode >= 400) {
        *error = [NSError errorWithHTTPStatusCode:statusCode];
        return nil;
    }
    
    return json;
}

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
            NSError *e;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:self.readingOptions error:&e];
            if (!e) {
                return json;
            }
        }
    }
    
    return nil;
}

- (NSString *)exceptionCodeFromDictionary:(id)dic exceptionMessage:(NSString **)exceptionMessage
{
    if (![dic isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSDictionary *details = [dic objectForKey:@"details"];
    if (![details isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSArray *exceptionDetails = [details objectForKey:@"exception_details"];
    if (![exceptionDetails isKindOfClass:NSArray.class]) {
        return nil;
    }
    
    for (NSDictionary *exceptionDetail in exceptionDetails) {
        if ([exceptionDetail isKindOfClass:NSDictionary.class]) {
            NSString *exceptionCode = [exceptionDetail objectForKey:@"code"];
            if ([exceptionCode isKindOfClass:NSString.class] && exceptionCode.length > 0) {
                if (exceptionMessage) {
                    NSString *message = [exceptionDetail objectForKey:@"message"];
                    if (![message isKindOfClass:NSString.class]) {
                        message = @"";
                    }
                    *exceptionMessage = message;
                }
                return exceptionCode;
            }
        }
    }
    return nil;
}

- (NSError *)errorWithStatusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    return [AccountError unknownErrorWithStatusCode:statusCode exceptionCode:code message:message];
}

@end

@implementation NeroLoginResponseSerializer

- (NSError *)errorWithStatusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"data:1"]) {
        return [AccountError errorWithCode:AccountError_Login_DataMissing description:message];
    }
    if ([code isEqualToString:@"login:1"]) {
        return [AccountError errorWithCode:AccountError_Login_NicknameMissing description:message];
    }
    if ([code isEqualToString:@"login:2"]) {
        return [AccountError errorWithCode:AccountError_Login_PasswordMissing description:message];
    }
    if ([code isEqualToString:@"login:3"]) {
        return [AccountError errorWithCode:AccountError_Login_AccountInactived description:message];
    }
    if ([code isEqualToString:@"login:4"]) {
        return [AccountError errorWithCode:AccountError_Login_EmailPasswordMismatched description:message];
    }
    if ([code isEqualToString:@"login:6"]) {
        return [AccountError errorWithCode:AccountError_Login_TOSChanged description:message];
    }
    if ([code isEqualToString:@"login:7"]) {
        return [AccountError errorWithCode:AccountError_Login_NotFound description:message];
    }
    
    return [AccountError unknownErrorWithStatusCode:statusCode exceptionCode:code message:message];
}

@end

@implementation NeroRegisterResponseSerializer

- (NSError *)errorWithStatusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"register:1"]) {
        return [AccountError errorWithCode:AccountError_Register_NicknameMissing description:message];
    }
    if ([code isEqualToString:@"register:3"]) {
        return [AccountError errorWithCode:AccountError_Register_EmailMissing description:message];
    }
    if ([code isEqualToString:@"register:4"]) {
        return [AccountError errorWithCode:AccountError_Register_CountryMissing description:message];
    }
    if ([code isEqualToString:@"register:5"]) {
        return [AccountError errorWithCode:AccountError_Register_SecurityCodeMissing description:message];
    }
    if ([code isEqualToString:@"register:6"]) {
        return [AccountError errorWithCode:AccountError_Register_PasswordMissing description:message];
    }
    if ([code isEqualToString:@"register:7"]) {
        return [AccountError errorWithCode:AccountError_Register_ChecksumMissing description:message];
    }
    if ([code isEqualToString:@"register:8"]) {
        return [AccountError errorWithCode:AccountError_Register_ActivateFailed description:message];
    }
    if ([code isEqualToString:@"invalid:email:String:1202"]) {
        return [AccountError errorWithCode:AccountError_Register_AlreadyExisted description:message];
    }
    
    return [AccountError unknownErrorWithStatusCode:statusCode exceptionCode:code message:message];
}

@end

@implementation NeroPasswordChangeResponseSerializer

- (NSError *)errorWithStatusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"password:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_OldPasswordMissing description:message];
    }
    if ([code isEqualToString:@"password:2"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NewPasswordMissing description:message];
    }
    if ([code isEqualToString:@"password:3"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NewPasswordTooShort description:message];
    }
    if ([code isEqualToString:@"password:4"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_OldPasswordIncorrect description:message];
    }
    if ([code isEqualToString:@"invalid:email:String:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_EmailMissing description:message];
    }
    if ([code isEqualToString:@"user:passwordchange:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NotFound description:message];
    }
    if ([code isEqualToString:@"invalid:passwordnew:String:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NewPasswordMissing description:message];
    }
    
    return [AccountError unknownErrorWithStatusCode:statusCode exceptionCode:code message:message];
}

@end

@implementation NeroPasswordRenewResponseSerializer

- (NSError *)errorWithStatusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"invalid:email:String:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordRenew_EmailMissing description:message];
    }
    if ([code isEqualToString:@"user:passwordrenew:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordRenew_SendFailed description:message];
    }
    if ([code isEqualToString:@"user:passwordrenew:2"]) {
        return [AccountError errorWithCode:AccountError_PasswordRenew_NotEnoughTime description:message];
    }
    
    return [AccountError unknownErrorWithStatusCode:statusCode exceptionCode:code message:message];
}

@end

@implementation NeroAcceptTOSResponseSerializer

- (NSError *)errorWithStatusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"email:missing"]) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_EmailMissing description:message];
    }
    if ([code isEqualToString:@"tos:missing"]) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_TOSMissing description:message];
    }
    if ([code isEqualToString:@"ots:invalid"]) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_TOSInvalid description:message];
    }
    if (statusCode == 403) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_TOSDateOld description:nil];
    }
    if (statusCode == 404) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_NotFound description:nil];
    }
    
    return [AccountError unknownErrorWithStatusCode:statusCode exceptionCode:code message:message];
}

@end