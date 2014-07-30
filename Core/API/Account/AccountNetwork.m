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
        completion(nil, error);
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
    // retrieve http status code.
    NSInteger statusCode = 200;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }
    
    // convert data to json.
    id json = [self JSONObjectFromData:data withResponse:response];
    
    // get exception code and message.
    NSString *exceptionCode = nil, *message = nil;
    if ([json isKindOfClass:NSDictionary.class]) {
        [self getDetails:json exceptionCode:&exceptionCode message:&message];
    }
    
    // find error.
    NSError *e = [self getErrorForPath:_requestPath data:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    if (e) {
        *error = e;
        return nil;
    }
    
    // for account apis, the response data must be a dictionary.
    if ([json isKindOfClass:NSDictionary.class]) {
        return json;
    }
    
    *error = [AccountError errorWithCode:AccountError_InvalidResponseData];
    return nil;
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

#pragma mark errors

- (NSError *)getErrorForPath:(NSString *)path data:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)exceptionCode message:(NSString *)message
{
    NSError *error = nil;
    
    if (statusCode == 401) {
        error = [AccountError errorWithCode:AccountError_Unauthorized];
    }
    else if (statusCode == 503) {
        error = [AccountError errorWithCode:AccountError_ServiceUnavailable];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsAuthorize]) {
        error = [self getErrorForLogin:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsRevoke]) {
        error = [self getErrorForLogout:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsPasswordchange]) {
        error = [self getErrorForPasswordchange:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_AuthNcsPasswordrenew]) {
        error = [self getErrorForPasswordrenew:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else if ([path isEqualToString:AccountAPIPath_UserAccepttos]) {
        error = [self getErrorForAccepttos:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    else {
        error = [self getUnknownErrorForPath:path data:data statusCode:statusCode exceptionCode:exceptionCode message:message];
    }
    
    return error;
}

- (NSError *)getErrorForLogin:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"data:1"]) {
        return [AccountError errorWithCode:AccountError_Login_DataMissing message:message];
    }
    if ([code isEqualToString:@"login:1"]) {
        return [AccountError errorWithCode:AccountError_Login_NicknameMissing message:message];
    }
    if ([code isEqualToString:@"login:2"]) {
        return [AccountError errorWithCode:AccountError_Login_PasswordMissing message:message];
    }
    if ([code isEqualToString:@"login:3"]) {
        return [AccountError errorWithCode:AccountError_Login_AccountInactived message:message];
    }
    if ([code isEqualToString:@"login:4"]) {
        return [AccountError errorWithCode:AccountError_Login_EmailPasswordMismatched message:message];
    }
    if ([code isEqualToString:@"login:6"]) {
        return [AccountError errorWithCode:AccountError_Login_TOSChanged message:message];
    }
    if ([code isEqualToString:@"login:7"]) {
        return [AccountError errorWithCode:AccountError_Login_NotFound message:message];
    }
    return nil;
}

- (NSError *)getErrorForLogout:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"register:1"]) {
        return [AccountError errorWithCode:AccountError_Register_NicknameMissing message:message];
    }
    if ([code isEqualToString:@"register:3"]) {
        return [AccountError errorWithCode:AccountError_Register_EmailMissing message:message];
    }
    if ([code isEqualToString:@"register:4"]) {
        return [AccountError errorWithCode:AccountError_Register_CountryMissing message:message];
    }
    if ([code isEqualToString:@"register:5"]) {
        return [AccountError errorWithCode:AccountError_Register_SecurityCodeMissing message:message];
    }
    if ([code isEqualToString:@"register:6"]) {
        return [AccountError errorWithCode:AccountError_Register_PasswordMissing message:message];
    }
    if ([code isEqualToString:@"register:7"]) {
        return [AccountError errorWithCode:AccountError_Register_ChecksumMissing message:message];
    }
    if ([code isEqualToString:@"register:8"]) {
        return [AccountError errorWithCode:AccountError_Register_ActivateFailed message:message];
    }
    if ([code isEqualToString:@"invalid:email:String:1202"]) {
        return [AccountError errorWithCode:AccountError_Register_AlreadyExisted message:message];
    }
    return nil;
}

- (NSError *)getErrorForPasswordchange:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"password:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_OldPasswordMissing message:message];
    }
    if ([code isEqualToString:@"password:2"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NewPasswordMissing message:message];
    }
    if ([code isEqualToString:@"password:3"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NewPasswordTooShort message:message];
    }
    if ([code isEqualToString:@"password:4"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_OldPasswordIncorrect message:message];
    }
    if ([code isEqualToString:@"invalid:email:String:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_EmailMissing message:message];
    }
    if ([code isEqualToString:@"user:passwordchange:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NotFound message:message];
    }
    if ([code isEqualToString:@"invalid:passwordnew:String:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordChange_NewPasswordMissing message:message];
    }
    return nil;
}

- (NSError *)getErrorForPasswordrenew:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"invalid:email:String:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordRenew_EmailMissing message:message];
    }
    if ([code isEqualToString:@"user:passwordrenew:1"]) {
        return [AccountError errorWithCode:AccountError_PasswordRenew_SendFailed message:message];
    }
    if ([code isEqualToString:@"user:passwordrenew:2"]) {
        return [AccountError errorWithCode:AccountError_PasswordRenew_NotEnoughTime message:message];
    }
    return nil;
}

- (NSError *)getErrorForAccepttos:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if ([code isEqualToString:@"email:missing"]) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_EmailMissing message:message];
    }
    if ([code isEqualToString:@"tos:missing"]) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_TOSMissing message:message];
    }
    if ([code isEqualToString:@"ots:invalid"]) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_TOSInvalid message:message];
    }
    if (statusCode == 403) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_TOSDateOld message:nil];
    }
    if (statusCode == 404) {
        return [AccountError errorWithCode:AccountError_AcceptTOS_NotFound message:nil];
    }
    return nil;
}

- (NSError *)getUnknownErrorForPath:(NSString *)requestPath data:(NSData *)data statusCode:(NSInteger)statusCode exceptionCode:(NSString *)code message:(NSString *)message
{
    if (code.length > 0) {
        NSString *reason = [NSString stringWithFormat:@"Nero Account Error with HTTP status-code:%d, exception-code:%@, message:%@", (int)statusCode, code, message];
        
        //[[GAI sharedInstance].defaultTracker send:[GAIDictionaryBuilder createExceptionWithDescription:str withFatal:@NO].build];
        
        return [AccountError errorWithCode:AccountError_Unknown message:message reason:reason];
    }
    
    if (statusCode >= 400) {
        return [AccountError errorWithStatusCode:statusCode];
    }
    
    return nil;
}

@end
