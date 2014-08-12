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
#import "PogoplugAPI.h"
#import "PogoplugResponse.h"
#import "File+Pogoplug.h"

@interface Core ()
// account
@property (nonatomic) NSURL *accountApiUrl;
@property (nonatomic) NSString *accountAuthorization;
@property (nonatomic) NSString *accountEmail;
@property (nonatomic) AccountState accountState;
// storage
@property (nonatomic) NSURL    *storageApiUrl; // subscription storage api url.
@property (nonatomic) NSString *storageToken;
@property (nonatomic) NSObject *storageTokenLocker;
@property (nonatomic) NSDate   *storageTokenRefreshDate;
@property (nonatomic) NSString *pogoplugDeviceID;
@property (nonatomic) NSString *pogoplugServiceID;
@property (nonatomic) NSURL    *pogoplugServiceApiUrl; // pogoplug service api url.
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
        
        self.accountApiUrl = [NSURL URLWithString:@"https://services.my.nerobackitup.com"];
        self.storageTokenLocker = [[NSObject alloc] init];
        self.storageTokenRefreshDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self;
}

#pragma mark - account actions

- (void)login:(NSString *)username password:(NSString *)password completion:(Completion)completion
{
    NSParameterAssert(username && password);
    NSParameterAssert(completion);
    
    if (0 == username.length || 0 == password.length) {
        NSError *error = nil;
        if (0 == username.length) {
            error = [Error errorWithCode:Error_Failed subCode:Error_Account_Login_NicknameMissing underlyingError:nil debugString:@"not input username." file:__FILE__ line:__LINE__];
        } else {
            error = [Error errorWithCode:Error_Failed subCode:Error_Account_Login_PasswordMissing underlyingError:nil debugString:@"not input password" file:__FILE__ line:__LINE__];
        }
        completion(error);
        return;
    }
    
    self.accountState = AccountState_Logining;
    
    __weak typeof(self) wself = self;
    [AccountAPI authorize:self.accountApiUrl username:username password:password completion:^(NSString *authorization, NSError *error) {
        __strong typeof(wself) sself = wself;
        [sself onLogin:error username:username authorization:authorization];
        completion(error);
    }];
}

- (void)logout:(Completion)completion
{
    NSParameterAssert(completion);
    
    NSString *authorization = self.accountAuthorization;
    if (!authorization) {
        self.accountState = AccountState_Logouted;
        completion(nil);
        return;
    }
    
    __weak typeof(self) wself = self;
    [AccountAPI revoke:self.accountApiUrl authorization:authorization completion:^(NSError *error) {
        __strong typeof(wself) sself = wself;
        [sself onLogout:error];
        completion(error);
    }];
}

- (void)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(Completion)completion
{
    NSParameterAssert(newPassword && oldPassword);
    NSParameterAssert(completion);
    
    [AccountAPI passwordchange:self.accountApiUrl authorization:self.accountAuthorization email:self.accountEmail passwordold:oldPassword passwordnew:newPassword completion:completion];
}

- (void)forgotPassword:(NSString *)email completion:(Completion)completion
{
    NSParameterAssert(email);
    NSParameterAssert(completion);
    
    [AccountAPI passwordrenew:self.accountApiUrl authorization:self.accountAuthorization email:email completion:completion];
}

- (void)acceptTOS:(NSString *)email completion:(Completion)completion
{
    NSParameterAssert(email);
    NSParameterAssert(completion);
    
    [AccountAPI accepttos:self.accountApiUrl authorization:self.accountAuthorization email:email completion:completion];
}

#pragma mark - account results

- (void)onLogin:(NSError *)error username:(NSString *)username authorization:(NSString *)authorization
{
    @synchronized(self) {
        if (error) {
            self.accountAuthorization = nil;
            self.accountState = AccountState_LoginFailed;
        }
        else {
            //self.username = username;
            //self.lastLoginDate = [NSDate date];
            
            self.accountAuthorization = authorization;
            self.accountState = AccountState_LoginSucceeded;
            
            //[self tryTransferImageCacheFromDatabase];
        }
    }
}

- (void)onLogout:(NSError *)error
{
    @synchronized(self) {
        if (error) {
            // TODO
            // log or trace.
        }
        else {
            self.accountAuthorization = nil;
            self.accountState = AccountState_Logouted;
        }
    }
}

- (void)onUnauthorized
{
    @synchronized(self) {
        if (self.accountAuthorization) {
            self.accountAuthorization = nil;
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
            [PogoplugAPI createFile:sself.pogoplugServiceApiUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID filename:filename parentid:parentid type:pogoplugFileType mtime:mtime ctime:ctime completion:^(NSDictionary *dictionary, NSError *error) {
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
            [PogoplugAPI moveFile:sself.pogoplugServiceApiUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid newname:newname completion:^(NSError *error) {
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
            [PogoplugAPI removeFile:sself.pogoplugServiceApiUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid recurse:recurse completion:^(NSError *error) {
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
            [PogoplugAPI uploadFile:sself.pogoplugServiceApiUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid data:data completion:completion];
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
            [PogoplugAPI downloadFile:sself.pogoplugServiceApiUrl valtoken:token deviceid:sself.pogoplugDeviceID serviceid:sself.pogoplugServiceID fileid:fileid completion:completion];
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
            error = [PogoplugAPI getFileURL:self.pogoplugServiceApiUrl valtoken:token deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:file.fileid flag:flag name:nil fileurl:&fileurl];
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

- (NSError *)getAccountAuthorization:(NSString **)authorization
{
    NSParameterAssert(authorization);
    NSString *accountAuthorization = self.accountAuthorization;
    if (!accountAuthorization) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LoginRequired object:self];
        return [Error errorWithCode:Error_Unauthorized subCode:Error_None underlyingError:nil debugString:@"no authorization stored." file:__FILE__ line:__LINE__];
    }
    *authorization = accountAuthorization;
    return nil;
}

- (void)getStorageToken:(void(^)(NSString *token, NSError *error))completion
{
    NSParameterAssert(completion);
    @synchronized(self.storageTokenLocker) {
        if (!self.storageToken || [[NSDate date] timeIntervalSinceDate:self.storageTokenRefreshDate] > 3600) {
            __weak __typeof(self) wself = self;
            [AccountAPI pogopluglogin:self.accountApiUrl authorization:self.accountAuthorization completion:^(NSString *apihost, NSString *token, NSError *error) {
                if (error) {
                    completion(nil, error);
                }
                else {
                    NSParameterAssert(token.length > 0);
                    __strong __typeof(wself) sself = wself;
                    sself.storageApiUrl = [NSURL URLWithString:apihost];
                    sself.storageToken = token;
                    sself.storageTokenRefreshDate = [NSDate date];
                    completion(token, nil);
                }
            }];
        }
        else {
            completion(self.storageToken, nil);
        }
    }
}

#pragma mark -

- (void)getAccountApiParameters:(void(^)(NSURL *apiurl, NSString *authorization, NSError *error))completion
{
    NSString *authorization = self.accountAuthorization;
    if (authorization) {
        completion(self.accountApiUrl, authorization, nil);
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LoginRequired object:self];
        NSError *error = [Error errorWithCode:Error_Unauthorized subCode:Error_None underlyingError:nil debugString:@"no authorization stored." file:__FILE__ line:__LINE__];
        completion(nil, nil, error);
    }
}

- (void)getPogoplugApiParameters:(void(^)(NSURL *apiurl, NSString *valtoken, NSError *error))completion
{
    [self getAccountApiParameters:^(NSURL *apiurl, NSString *authorization, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        
        NSString *valtoken = self.storageToken;
        if (valtoken && [[NSDate date] timeIntervalSinceDate:self.storageTokenRefreshDate] < 3600) {
            completion(apiurl, valtoken, nil);
            return;
        }
        
        [AccountAPI pogopluglogin:apiurl authorization:authorization completion:^(NSString *apihost, NSString *token, NSError *error) {
            if (error) {
                completion(nil, nil, error);
            }
            else {
                NSURL *apiurl = [NSURL URLWithString:apihost];
                @synchronized(self) {
                    self.storageApiUrl = apiurl;
                    self.storageToken = token;
                    self.storageTokenRefreshDate = [NSDate date];
                }
                completion(apiurl, token, nil);
            }
        }];
    }];
}

- (void)getPogoplugSvcParameters:(void(^)(NSURL *apiurl, NSString *valtoken, NSURL *svcurl, NSString *deviceid, NSString *serviceid, NSError *error))completion
{
    [self getPogoplugApiParameters:^(NSURL *apiurl, NSString *valtoken, NSError *error) {
        if (error) {
            completion(apiurl, valtoken, nil, nil, nil, error);
            return;
        }
        
        NSURL *svcurl = self.pogoplugServiceApiUrl;
        NSString *deviceid = self.pogoplugDeviceID;
        NSString *serviceid = self.pogoplugServiceID;
        if (svcurl && deviceid && serviceid) {
            completion(apiurl, valtoken, svcurl, deviceid, serviceid, nil);
            return;
        }
        
        // TODO
        // To list devices and services
        
    }];
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
