//
//  CoreAPI.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Core.h"
#import "AFNetworking.h"
#import "AccountAPI.h"
#import "AccountParameters.h"
#import "PogoplugAPI.h"
#import "PogoplugParameters.h"
#import "PogoplugResponse.h"
#import "File+Pogoplug.h"

@interface Core ()
@property (nonatomic,readonly) dispatch_queue_t completionQueue;
// account
@property (nonatomic,readonly) AccountParameters *accountParams; // baseurl, username, authorization.
@property (nonatomic) AccountState accountState;
@property (nonatomic) id accountStateLocker;
// storage
@property (nonatomic,readonly) NSRecursiveLock *pogoplugLocker;
@property (nonatomic) PogoplugParameters *pogoplugParams;
@property (nonatomic) NSURL    *storageApiUrl; // subscription storage api url.
@property (nonatomic) NSString *storageToken;
@property (nonatomic) NSObject *storageTokenLocker;
@property (nonatomic) NSDate   *storageTokenRefreshDate;
@property (nonatomic) NSString *pogoplugDeviceID;
@property (nonatomic) NSString *pogoplugServiceID;
@property (nonatomic) NSURL    *pogoplugSvcUrl; // pogoplug service api url.
// various kinds of root collections.
@property (nonatomic) File *root;
@property (nonatomic) File *photoTimelines;
@property (nonatomic) File *photoAlbums;
@property (nonatomic) File *videoTimelines;
@property (nonatomic) File *videoAlbums;
@property (nonatomic) File *documents;
@property (nonatomic) File *musicSongs;
@property (nonatomic) File *musicAlbums;
@property (nonatomic) File *musicArtists;
@property (nonatomic) File *musicGenres;
@property (nonatomic) File *musicPlaylists;
@property (nonatomic) File *genericCollections; // a generic collection is a group of files, used for multi-share.
@end

#pragma mark -
#pragma mark -

@implementation Core
{
    NSObject *_storageTokenLocker;
}

+ (Core *)sharedInstance
{
    static Core *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Core alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        _completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        _accountParams = [[AccountParameters alloc] init];
        self.accountParams.baseurl = [NSURL URLWithString:@"https://services.my.nerobackitup.com"];
        self.accountState = AccountState_Unauthorized;
        self.accountStateLocker = [[NSObject alloc] init];
        
        self.storageTokenLocker = [[NSObject alloc] init];
        self.storageTokenRefreshDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self;
}

#pragma mark - account actions

- (Operation *)login:(NSString *)username password:(NSString *)password completion:(void (^)(NSError *))completion
{
    NSParameterAssert(completion);
    NSParameterAssert(username.length > 0 && password.length > 0);
    
    Operation *operation = [[Operation alloc] init];
    __weak typeof(self) wself = self;
    
    dispatch_async(self.completionQueue, ^{
        NSError *error = nil;
        
        if (operation.cancelled) {
            error = [Error errorCancelled:__func__ file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        if (0 == username.length) {
            error = [Error errorWithCode:Error_Failed subCode:Error_Account_Login_NicknameMissing underlyingError:nil debugString:@"not input username." file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        if (0 == password.length) {
            error = [Error errorWithCode:Error_Failed subCode:Error_Account_Login_PasswordMissing underlyingError:nil debugString:@"not input password" file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        __strong typeof(wself) sself = wself;
        if (!sself) {
            NSParameterAssert(sself);
            error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:@"Core instance released while login-ing." file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        @synchronized(sself.accountStateLocker) {
            error = [sself syncLogin:username password:password forOperation:operation];
        }
        completion(error);
    });
    
    return operation;
}

- (NSError *)syncLogin:(NSString *)username password:password forOperation:(Operation *)operation
{
    NSURL *baseurl = nil;
    @synchronized(self.accountParams) {
        baseurl = self.accountParams.baseurl;
        NSParameterAssert(!self.accountParams.authorization);
        self.accountState = AccountState_Logining;
    }
    NSParameterAssert(baseurl.absoluteString.length > 0);
    
    NSCondition *condition = [[NSCondition alloc] init];
    __block BOOL completed = NO;
    __block NSString *authorization = nil;
    __block NSError *error = nil;
    
    NSOperation *subop = [AccountAPI authorize:baseurl username:username password:password completion:^(NSString *authorization_, NSError *error_) {
        authorization = authorization_;
        error = error_;
        completed = YES;
    }];
    
    [operation addUnderlyingOperation:subop];
    
    [condition lock];
    while (!completed) {
        [condition wait];
    }
    [condition unlock];
    
    @synchronized(self.accountParams) {
        self.accountParams.baseurl = baseurl;
        if (error) {
            self.accountParams.authorization = nil;
            self.accountState = AccountState_LoginFailed;
        }
        else {
            self.accountParams.authorization = authorization;
            self.accountState = AccountState_LoginSucceeded;
        }
    }
    
    return error;
}

- (Operation *)logout:(void (^)(NSError *))completion
{
    NSParameterAssert(completion);
    
    Operation *operation = [[Operation alloc] init];
    __weak typeof(self) wself = self;
    
    dispatch_async(self.completionQueue, ^{
        NSError *error = nil;
        
        if (operation.cancelled) {
            error = [Error errorCancelled:__func__ file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        __strong typeof(wself) sself = wself;
        if (!sself) {
            NSParameterAssert(sself);
            error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:@"Core instance released while logout-ing." file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        @synchronized(sself.accountStateLocker) {
            error = [sself syncLogoutForOperation:operation];
        }
        completion(error);
    });
    
    return operation;
}

- (NSError *)syncLogoutForOperation:(Operation *)operation
{
    NSURL *baseurl = nil;
    NSString *authorization = nil;
    @synchronized(self.accountParams) {
        baseurl = self.accountParams.baseurl;
        authorization = self.accountParams.authorization;
    }
    NSParameterAssert(baseurl && authorization);
    
    __block NSError *error = nil;
    
    if (authorization) {
        NSCondition *condition = [[NSCondition alloc] init];
        __block BOOL completed = NO;
        
        NSOperation *subop = [AccountAPI revoke:baseurl authorization:authorization completion:^(NSError *error_) {
            error = error_;
            completed = YES;
        }];
        
        [operation addUnderlyingOperation:subop];
        
        [condition lock];
        while (!completed) {
            [condition wait];
        }
        [condition unlock];
    }
    
    if (!error) {
        @synchronized(self.accountParams) {
            self.accountParams.authorization = nil;
            self.accountState = AccountState_Logouted;
        }
    }
    
    return error;
}

- (void)logout
{
    // TODO
}

- (Operation *)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(Completion)completion
{
    NSParameterAssert(completion);
    NSParameterAssert(newPassword && oldPassword);
    
    Operation *operation = [[Operation alloc] init];
    __weak typeof(self) wself = self;
    
    dispatch_async(self.completionQueue, ^{
        __strong typeof(wself) sself = wself;
        if (!self) {
            NSParameterAssert(sself);
            NSError *error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:@"Core instance released while logout-ing." file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        [sself operation:operation getAccountParameters:^(AccountParameters *params, NSError *error) {
            if (error) {
                completion(error);
                return;
            }
            
            NSOperation *subop = [AccountAPI passwordchange:params.baseurl authorization:params.authorization email:params.username passwordold:oldPassword passwordnew:newPassword completion:completion];
            [operation addUnderlyingOperation:subop];
        }];
    });
    
    return operation;
}

- (Operation *)forgotPassword:(NSString *)email completion:(Completion)completion
{
    NSParameterAssert(completion);
    NSParameterAssert(email);
    
    Operation *operation = [[Operation alloc] init];
    __weak typeof(self) wself = self;
    
    dispatch_async(self.completionQueue, ^{
        __strong typeof(wself) sself = wself;
        if (!self) {
            NSParameterAssert(sself);
            NSError *error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:@"Core instance released while logout-ing." file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        NSURL *baseurl = sself.accountParams.baseurl;
        NSParameterAssert(baseurl);
        
        NSOperation *subop = [AccountAPI passwordrenew:baseurl email:email completion:completion];
        [operation addUnderlyingOperation:subop];
    });
    
    return operation;
}

- (Operation *)acceptTOS:(NSString *)email completion:(Completion)completion
{
    NSParameterAssert(completion);
    NSParameterAssert(email);
    
    Operation *operation = [[Operation alloc] init];
    __weak typeof(self) wself = self;
    
    dispatch_async(self.completionQueue, ^{
        __strong typeof(wself) sself = wself;
        if (!self) {
            NSParameterAssert(sself);
            NSError *error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:@"Core instance released while logout-ing." file:__FILE__ line:__LINE__];
            completion(error);
            return;
        }
        
        [sself operation:operation getAccountParameters:^(AccountParameters *params, NSError *error) {
            if (error) {
                completion(error);
                return;
            }
            
            NSOperation *subop = [AccountAPI accepttos:params.baseurl authorization:params.authorization email:email completion:completion];
            [operation addUnderlyingOperation:subop];
        }];
    });
    
    return operation;
}

#pragma mark - account results

- (void)onLogin:(NSError *)error username:(NSString *)username authorization:(NSString *)authorization
{
    @synchronized(self.accountParams) {
        if (error) {
            self.accountParams.authorization = nil;
            self.accountState = AccountState_LoginFailed;
        }
        else {
            //self.username = username;
            //self.lastLoginDate = [NSDate date];
            
            self.accountParams.authorization = authorization;
            self.accountState = AccountState_LoginSucceeded;
            
            //[self tryTransferImageCacheFromDatabase];
        }
    }
}

- (void)onLogout:(NSError *)error
{
    @synchronized(self.accountParams) {
        if (error) {
            // TODO
            // log or trace.
        }
        else {
            self.accountParams.authorization = nil;
            self.accountState = AccountState_Logouted;
        }
    }
}

- (void)onUnauthorized
{
    @synchronized(self.accountParams) {
        if (self.accountParams.authorization) {
            self.accountParams.authorization = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LoginRequired object:self];
        }
        self.accountState = AccountState_Unauthorized;
    }
}

#pragma mark - storage actions

- (void)openFile:(NSString *)filename parentid:(NSString *)parentid type:(FileType)type ctime:(NSDate *)ctime mtime:(NSDate *)mtime completion:(FileCompletion)completion
{
    NSParameterAssert(filename);
    NSParameterAssert(completion);
    NSString *pogoplugFileType = [NSNumber numberWithInteger:type].description;
    
    __weak __typeof(self) wself = self;
    [self getStorageToken:^(NSString *token, NSError *error) {
        if (error) {
            completion(nil, error);
        }
        else {
            __strong __typeof(wself) sself = wself;
            [PogoplugAPI createFile:sself.pogoplugSvcUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID filename:filename parentid:parentid type:pogoplugFileType mtime:mtime ctime:ctime completion:^(NSDictionary *dictionary, NSError *error) {
                File *file = nil;
                if (!error) {
                    PogoplugResponse *response = [[PogoplugResponse alloc] initWithDictionary:dictionary];
                    error = [File makeFile:&file fromPogoplugResponse:response.file];
                }
                completion(file, error);
            }];
        }
    }];
}

- (void)renameFile:(NSString *)fileid newname:(NSString *)newname completion:(Completion)completion
{
    NSParameterAssert(fileid && newname);
    NSParameterAssert(completion);
    
    __weak __typeof(self) wself = self;
    [self getStorageToken:^(NSString *token, NSError *error) {
        if (error) {
            completion(error);
        }
        else {
            __strong __typeof(wself) sself = wself;
            [PogoplugAPI moveFile:sself.pogoplugSvcUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid newname:newname completion:^(NSError *error) {
                // TODO
                // to change it in database
                completion(error);
            }];
        }
    }];
}

- (void)deleteFile:(NSString *)fileid recurse:(BOOL)recurse completion:(Completion)completion
{
    NSParameterAssert(fileid);
    NSParameterAssert(completion);
    
    __weak __typeof(self) wself = self;
    [self getStorageToken:^(NSString *token, NSError *error) {
        if (error) {
            completion(error);
        }
        else {
            __strong __typeof(wself) sself = wself;
            [PogoplugAPI removeFile:sself.pogoplugSvcUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid recurse:recurse completion:^(NSError *error) {
                // TODO
                // to remove it from database
                completion(error);
            }];
        }
    }];
}

- (void)uploadFile:(NSString *)fileid data:(NSData *)data completion:(Completion)completion
{
    NSParameterAssert(fileid && data);
    NSParameterAssert(completion);
    
    __weak __typeof(self) wself = self;
    [self getStorageToken:^(NSString *token, NSError *error) {
        if (error) {
            completion(error);
        }
        else {
            __strong __typeof(wself) sself = wself;
            [PogoplugAPI uploadFile:sself.pogoplugSvcUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid data:data completion:completion];
        }
    }];
}

- (void)downloadFile:(NSString *)fileid completion:(DataCompletion)completion
{
    NSParameterAssert(fileid);
    NSParameterAssert(completion);
    
    __weak __typeof(self) wself = self;
    [self getStorageToken:^(NSString *token, NSError *error) {
        if (error) {
            completion(nil, error);
        }
        else {
            __strong __typeof(wself) sself = wself;
            [PogoplugAPI downloadFile:sself.pogoplugSvcUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid completion:completion];
        }
    }];
}

- (void)getThumbnailURL:(File *)file completion:(void(^)(NSURL *url, NSError *error))completion
{
    [self getURLForFile:file withFlag:PogoplugFlag_Thumbnail completion:completion];
}

- (void)getPreviewURL:(File *)file completion:(void(^)(NSURL *url, NSError *error))completion
{
    [self getURLForFile:file withFlag:PogoplugFlag_Preview completion:completion];
}

- (void)getStreamURL:(File *)file completion:(void(^)(NSURL *url, NSError *error))completion
{
    NSString *flag = [file.streamtype.lowercaseString isEqualToString:@"full"] ? PogoplugFlag_Stream : nil;
    [self getURLForFile:file withFlag:flag completion:completion];
}

- (void)getURLForFile:(File *)file withFlag:(NSString *)flag completion:(void(^)(NSURL *url, NSError *))completion
{
    [self getStorageToken:^(NSString *token, NSError *error) {
        if (error) {
            completion(nil, error);
        }
        else {
            NSURL *fileurl = nil;
            error = [PogoplugAPI getFileURL:self.pogoplugSvcUrl valtoken:token deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:file.fileid flag:flag name:nil fileurl:&fileurl];
            if (error) {
                completion(nil, error);
            }
            else {
                completion(fileurl, nil);
            }
        }
    }];
}

- (NSError *)forFile:(File *)file getThumbnailCacheKey:(NSString **)key
{
    return [self forFile:file withFlag:PogoplugFlag_Thumbnail getCacheKey:key];
}

- (NSError *)forFile:(File *)file getPreviewCacheKey:(NSString **)key
{
    return [self forFile:file withFlag:PogoplugFlag_Preview getCacheKey:key];
}

- (NSError *)forFile:(File *)file getOriginCacheKey:(NSString **)key
{
    return [self forFile:file withFlag:nil getCacheKey:key];
}

- (NSError *)forFile:(File *)file withFlag:(NSString *)flag getCacheKey:(NSString **)key
{
    NSParameterAssert(file && key);
    
    NSString *cacheKey = file.fileid;
    if (flag.length > 0) {
        cacheKey = [cacheKey stringByAppendingPathComponent:flag];
    }
    else {
        NSString *ext = file.name.pathExtension;
        if (ext.length > 0) {
            cacheKey = [cacheKey stringByAppendingPathExtension:ext];
        }
    }
    
    if (key) {
        *key = cacheKey;
    }
    return nil;
}

#pragma mark - collection actions

- (NSError *)forCollection:(File *)collection getCachedFiles:(NSArray **)files
{
    // TODO
    return nil;
}

- (NSError *)forCollection:(File *)collection refresh:(NSUInteger)size getFiles:(NSArray **)files
{
    // TODO
    return nil;
}

- (NSError *)forCollection:(File *)collection next:(NSUInteger)size getFiles:(NSArray **)files
{
    // TODO
    return nil;
}

- (NSError *)openPhotoAlbum:(NSString *)name album:(File **)album
{
    // TODO
    return nil;
}

- (NSError *)openMusicPlaylist:(NSString *)name playlist:(File **)playlist
{
    // TODO
    return nil;
}

- (NSError *)openGenericCollection:(NSString *)name collection:(File **)collection
{
    // TODO
    return nil;
}

- (NSError *)forPhotoAlbum:(File *)album addFile:(File **)file getItem:(File **)item
{
    // TODO
    return nil;
}

- (NSError *)forMusicPlaylist:(File *)playlist addFile:(File **)file getItem:(File **)item
{
    // TODO
    return nil;
}

- (NSError *)forGenericCollection:(File *)collection addFile:(File **)file getItem:(File **)item
{
    // TODO
    return nil;
}

#pragma mark - share actions

- (NSError *)shareFile:(NSString *)fileid shareURL:(NSURL **)shareURL
{
    NSParameterAssert(fileid && shareURL);
    
    /*
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    */
    
    /*
    NSDictionary *dictionary = nil;
    error = [PogoplugAPI enableShare:self.storageApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid name:nil password:nil permissions:nil result:&dictionary];
    if (error) {
        return error;
    }
    
    PogoplugResponse *response = [[PogoplugResponse alloc] initWithDictionary:dictionary];
    NSURL *url = [NSURL URLWithString:response.shareURL];
    if (0 == url.absoluteString.length) {
        return [PogoplugError error:Error_Pogoplug_InvalidResponseData];
    }
    
    if (shareURL) {
        *shareURL = url;
    }
    */
    return nil;
}

#pragma mark - tokens on demand

- (void)operation:(Operation *)operation getAccountParameters:(void(^)(AccountParameters *, NSError *))completion
{
    __weak typeof(self) wself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (operation.cancelled) {
            completion(nil, [Error errorCancelled:__func__ file:__FILE__ line:__LINE__]);
            return;
        }
        
        AccountParameters *params = nil;
        __strong typeof(wself) sself = wself;
        
        @synchronized(sself.accountParams) {
            params = sself.accountParams.copy;
        }
        
        if (params.authorization) {
            completion(params, nil);
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LoginRequired object:self];
            NSError *error = [Error errorWithCode:Error_Unauthorized subCode:Error_None underlyingError:nil debugString:@"no authorization stored." file:__FILE__ line:__LINE__];
            completion(nil, error);
        }
    });
}

- (void)operation:(Operation *)operation getPogoplugApiParameters:(void(^)(PogoplugParameters *, NSError *))completion
{
    __weak typeof(self) wself = self;
    
    [self operation:operation getAccountParameters:^(AccountParameters *account, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        if (operation.cancelled) {
            completion(nil, [Error errorCancelled:__func__ file:__FILE__ line:__LINE__]);
            return;
        }
        
        PogoplugParameters *params = nil;
        __strong typeof(wself) sself = wself;
        
        @synchronized(sself.pogoplugParams) {
            params = sself.pogoplugParams;
            
            // for base api.
            if (params.valtoken && [[NSDate date] timeIntervalSinceDate:params.tokendate] < 3600) {
                // ok.
            }
            else {
                error = [self syncDownloadPogoplugApiParameters:params forOperation:operation withAccountParameters:account];
            }
            
            // make a copy.
            params = error ? nil : params.copy;
        }
        
        completion(params, error);
    }];
}

- (void)operation:(Operation *)operation getPogoplugSvcParameters:(void(^)(PogoplugParameters *, NSError *))completion
{
    __weak typeof(self) wself = self;
    
    [self operation:operation getAccountParameters:^(AccountParameters *account, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        if (operation.cancelled) {
            completion(nil, [Error errorCancelled:__func__ file:__FILE__ line:__LINE__]);
            return;
        }
        
        PogoplugParameters *params = nil;
        __strong typeof(wself) sself = wself;
        
        @synchronized(sself.pogoplugParams) {
            params = sself.pogoplugParams;
            
            // for base api.
            if (params.valtoken && [[NSDate date] timeIntervalSinceDate:params.tokendate] < 3600) {
                // ok
            }
            else {
                error = [self syncDownloadPogoplugApiParameters:params forOperation:operation withAccountParameters:account];
            }
            
            // for service api.
            if (!error && !params.deviceid) {
                error = [self syncDownloadPogoplugSvcParameters:params forOperation:operation];
            }
            
            // make a copy.
            params = error ? nil : params.copy;
        }
        
        completion(params, error);
    }];
}

- (NSError *)syncDownloadPogoplugApiParameters:(PogoplugParameters *)params forOperation:(Operation *)operation withAccountParameters:(AccountParameters *)account
{
    NSCondition *condition = [[NSCondition alloc] init];
    __block BOOL completed = NO;
    __block NSError *error = nil;
    
    NSOperation *op = [AccountAPI pogopluglogin:account.baseurl authorization:account.authorization completion:^(NSString *apihost, NSString *token, NSError *e) {
        if (e) {
            error = e;
        }
        else {
            params.apiurl = [NSURL URLWithString:apihost];
            params.valtoken = token;
            params.tokendate = [NSDate date];
            params.svcurl = nil;
            params.deviceid = nil;
            params.serviceid = nil;
        }
        completed = YES;
    }];
    
    [operation addUnderlyingOperation:op];
    
    [condition lock];
    while (!completed) {
        [condition wait];
    }
    [condition unlock];
    
    return error;
}

- (NSError *)syncDownloadPogoplugSvcParameters:(PogoplugParameters *)params forOperation:(Operation *)operation
{
    NSCondition *condition = [[NSCondition alloc] init];
    __block BOOL completed = NO;
    __block NSError *error = nil;
    
    NSOperation *op = [PogoplugAPI listDevices:params.apiurl valtoken:params.valtoken completion:^(NSDictionary *response, NSError *e) {
        if (e) {
            error = e;
        }
        else if (![self syncFillPogoplugSvcParameters:params withListDeviceResponse:response]) {
            error = [Error errorWithCode:Error_Unexpected subCode:Error_None underlyingError:nil debugString:[NSString stringWithFormat:@"response data: %@", response] file:__FILE__ line:__LINE__];
        }
        completed = YES;
    }];
    
    [operation addUnderlyingOperation:op];
    
    [condition lock];
    while (!completed) {
        [condition wait];
    }
    [condition unlock];
    
    return error;

}

- (BOOL)syncFillPogoplugSvcParameters:(PogoplugParameters *)params withListDeviceResponse:(NSDictionary *)response
{
    PogoplugResponse *value = [[PogoplugResponse alloc] initWithDictionary:response];
    for (PogoplugResponse_Device *device in value.devices) {
        for (PogoplugResponse_Service *service in device.services) {
            NSString *deviceid = device.deviceID;
            NSString *serviceid = service.serviceID;
            NSString *apiurlstr = service.apiurl;
            if (isstring(deviceid) && isstring(serviceid) && isstring(apiurlstr)) {
                NSURL *svcurl = [NSURL URLWithString:apiurlstr];
                if (svcurl.absoluteString.length > 0) {
                    params.svcurl = svcurl;
                    params.deviceid = deviceid;
                    params.serviceid = serviceid;
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark -

- (void)tryTransferImageCacheFromDatabase {
    NSParameterAssert(!NSThread.isMainThread);
    
    const int s_display_progress_cacheNumber = 200;
    NSCondition *condition = [[NSCondition alloc] init];
    __block BOOL completed = NO;
    __block UIAlertView *alertView = nil;
    __block NSUInteger lastProgress = 0;
    
    [self transferCacheFilesWithProgress:^(NSUInteger total, NSUInteger finished) {
        if (finished == 0 && total >= s_display_progress_cacheNumber) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString *title = @"Upgrading";
                alertView = [[UIAlertView alloc] initWithTitle:title message:@"0%" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
                [alertView show];
            });
        }
        
        if(alertView) {
            // if alertView is created, then total could not be zero.
            NSUInteger progress = finished*100/total;
            if (alertView && progress > lastProgress) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    alertView.message = [NSString stringWithFormat:@"(%lu%%)", (unsigned long)progress];
                });
                lastProgress = progress;
            }
        }
        
    } completion:^{
        if (alertView) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                alertView.message = @"100%";
            });
            [NSThread sleepForTimeInterval:0.5];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            });
        }
        
        [condition lock];
        completed = YES;
        [condition signal];
        [condition unlock];
    }];
    
    [condition lock];
    while (!completed) {
        [condition wait];
    }
    [condition unlock];
}

- (void)transferCacheFilesWithProgress:(void(^)(NSUInteger total, NSUInteger finished))progress completion:(void(^)())completion
{
    // TODO
}

@end
