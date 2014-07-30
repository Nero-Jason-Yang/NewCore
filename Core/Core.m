//
//  CoreAPI.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Core.h"
#import "AccountAPI.h"
#import "PogoplugAPI.h"
#import "PogoplugResponse.h"
#import "File+Pogoplug.h"

@interface Core ()
// account
@property (nonatomic) NSURL *accountApiUrl;
@property (nonatomic) NSString *accountToken;
@property (nonatomic) NSString *accountEmail;
@property (nonatomic) AccountState accountState;
// storage
@property (nonatomic) NSURL *storageApiUrl; // subscription storage api url.
@property (nonatomic) NSString *storageToken;
@property (nonatomic) NSObject *storageTokenLocker;
@property (nonatomic) NSDate *lastStorageAccessDate;
@property (nonatomic) NSString *pogoplugDeviceID;
@property (nonatomic) NSString *pogoplugServiceID;
@property (nonatomic) NSURL *pogoplugServiceApiUrl; // pogoplug service api url.
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
        self.accountApiUrl = [NSURL URLWithString:@"https://services.my.nerobackitup.com/api"];
        self.storageTokenLocker = [[NSObject alloc] init];
    }
    return self;
}

#pragma mark - account actions

- (void)login:(NSString *)username password:(NSString *)password completion:(Completion)completion
{
    NSParameterAssert(username && password);
    NSParameterAssert(completion);
    
    if (0 == username.length || 0 == password.length) {
        NSParameterAssert(0);
        NSError *error = [AccountError errorWithCode:AccountError_Login_DataMissing underlyingError:nil debugString:@"invalid input username or password" file:__FILE__ line:__LINE__];
        completion(error);
        return;
    }
    
    self.accountState = AccountState_Logining;
    
    __weak typeof(self) wself = self;
    [AccountAPI auth_ncs_authorize:self.accountApiUrl username:username password:password completion:^(NSString *authorization, NSError *error) {
        __strong typeof(wself) sself = wself;
        [sself onLogin:error username:username authorization:authorization];
        completion(error);
    }];
}

- (void)logout:(Completion)completion
{
    NSParameterAssert(completion);
    
    NSString *authorization = self.accountToken;
    if (!authorization) {
        self.accountState = AccountState_Logouted;
        completion(nil);
        return;
    }
    
    __weak typeof(self) wself = self;
    [AccountAPI auth_ncs_revoke:self.accountApiUrl authorization:authorization completion:^(NSError *error) {
        __strong typeof(wself) sself = wself;
        [sself onLogout:error];
        completion(error);
    }];
}

- (void)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(Completion)completion
{
    NSParameterAssert(newPassword && oldPassword);
    NSParameterAssert(completion);
    
    [AccountAPI auth_ncs_passwordchange:self.accountApiUrl authorization:self.accountToken email:self.accountEmail passwordold:oldPassword passwordnew:newPassword completion:completion];
}

- (void)forgotPassword:(NSString *)email completion:(Completion)completion
{
    NSParameterAssert(email);
    NSParameterAssert(completion);
    
    [AccountAPI auth_ncs_passwordrenew:self.accountApiUrl authorization:self.accountToken email:email completion:completion];
}

- (void)acceptTOS:(NSString *)email completion:(Completion)completion
{
    NSParameterAssert(email);
    NSParameterAssert(completion);
    
    [AccountAPI user_accepttos:self.accountApiUrl authorization:self.accountToken email:email completion:completion];
}

#pragma mark - account results

- (void)onLogin:(NSError *)error username:(NSString *)username authorization:(NSString *)authorization
{
    @synchronized(self) {
        if (error) {
            self.accountToken = nil;
            self.accountState = AccountState_LoginFailed;
        }
        else {
            //self.username = username;
            //self.lastLoginDate = [NSDate date];
            
            self.accountToken = authorization;
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
            self.accountToken = nil;
            self.accountState = AccountState_Logouted;
        }
    }
}

- (void)onUnauthorized
{
    @synchronized(self) {
        if (self.accountToken) {
            self.accountToken = nil;
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
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        completion(nil, error);
        return;
    }
    
    NSString *pogoplugFileType = [NSNumber numberWithInteger:type].description;
    
    [PogoplugAPI createFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID filename:filename parentid:parentid type:pogoplugFileType mtime:mtime ctime:ctime completion:^(NSDictionary *dictionary, NSError *error) {
        File *file = nil;
        if (!error) {
            PogoplugResponse *response = [[PogoplugResponse alloc] initWithDictionary:dictionary];
            error = [File makeFile:&file fromPogoplugResponse:response.file];
        }
        completion(file, error);
    }];
}

- (void)renameFile:(NSString *)fileid newname:(NSString *)newname completion:(Completion)completion
{
    NSParameterAssert(fileid && newname);
    NSParameterAssert(completion);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        completion(error);
        return;
    }
    
    [PogoplugAPI moveFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid newname:newname completion:^(NSError *error) {
        // TODO
        // to change it in database
        completion(error);
    }];
}

- (void)deleteFile:(NSString *)fileid recurse:(BOOL)recurse completion:(Completion)completion
{
    NSParameterAssert(fileid);
    NSParameterAssert(completion);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        completion(error);
        return;
    }
    
    [PogoplugAPI removeFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid recurse:recurse completion:^(NSError *error) {
        // TODO
        // to remove it from database
        completion(error);
    }];
}

- (void)uploadFile:(NSString *)fileid data:(NSData *)data completion:(Completion)completion
{
    NSParameterAssert(fileid && data);
    NSParameterAssert(completion);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        completion(error);
        return;
    }
    
    [PogoplugAPI uploadFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid data:data completion:completion];
}

- (void)downloadFile:(NSString *)fileid completion:(DataCompletion)completion
{
    NSParameterAssert(fileid);
    NSParameterAssert(completion);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        completion(nil, error);
        return;
    }
    
    [PogoplugAPI downloadFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid completion:completion];
}

- (NSError *)forFile:(File *)file getThumbnailURL:(NSURL **)URL
{
    return [self forFile:file withFlag:PogoplugFlag_Thumbnail getURL:URL];
}

- (NSError *)forFile:(File *)file getPreviewURL:(NSURL **)URL
{
    return [self forFile:file withFlag:PogoplugFlag_Preview getURL:URL];
}

- (NSError *)forFile:(File *)file getStreamURL:(NSURL **)URL
{
    NSString *flag = [file.streamtype.lowercaseString isEqualToString:@"full"] ? PogoplugFlag_Stream : nil;
    return [self forFile:file withFlag:flag getURL:URL];
}

- (NSError *)forFile:(File *)file withFlag:(NSString *)flag getURL:(NSURL **)URL
{
    NSParameterAssert(file && URL);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    error = [PogoplugAPI getFileURL:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:file.fileid flag:flag name:nil fileurl:URL];
    if (error) {
        return error;
    }
    
    return nil;
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
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    /*
    NSDictionary *dictionary = nil;
    error = [PogoplugAPI enableShare:self.storageApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid name:nil password:nil permissions:nil result:&dictionary];
    if (error) {
        return error;
    }
    
    PogoplugResponse *response = [[PogoplugResponse alloc] initWithDictionary:dictionary];
    NSURL *url = [NSURL URLWithString:response.shareURL];
    if (0 == url.absoluteString.length) {
        return [PogoplugError error:PogoplugError_InvalidResponseData];
    }
    
    if (shareURL) {
        *shareURL = url;
    }
    */
    return nil;
}

#pragma mark -

- (NSError *)getAccountToken:(NSString **)token
{
    NSString *accountToken = self.accountToken;
    if (!accountToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LoginRequired object:self];
        return [Error errorWithCode:Error_Unauthorized underlyingError:nil debugString:@"no authorization stored." file:__FILE__ line:__LINE__];
    }
    *token = accountToken;
    return nil;
}

- (NSError *)getStorageToken:(NSString **)token
{
    NSParameterAssert(token);
    @synchronized(_storageTokenLocker) {
        if (!self.storageToken || !self.lastStorageAccessDate || [[NSDate date] timeIntervalSinceDate:self.lastStorageAccessDate] > 3600) {
            NSError *error = [self refreshStorageToken];
            if (error) {
                return error;
            }
        }
        NSParameterAssert(self.storageToken);
        *token = self.storageToken;
        self.lastStorageAccessDate = [NSDate date];
    }
    return nil;
}

- (NSError *)refreshStorageToken
{
    return nil;
    /*
    NSString *accountToken = nil;
    NSError *error = [self getAccountToken:&accountToken];
    if (error) {
        return error;
    }
    
    NSString *storageApi = nil;
    NSString *storageToken = nil;
    error = [AccountAPI subscriptions_pogoplug_login:self.accountApiUrl authorization:accountToken host:&storageApi token:&storageToken];
    if (error) {
        return error;
    }
    
    NSParameterAssert([storageApi.lastPathComponent isEqualToString:@"api"]);
    self.storageApiUrl = [NSURL URLWithString:storageApi];
    self.storageToken = storageToken;
    
    NSDictionary *result = nil;
    error = [PogoplugAPI listDevices:self.storageApiUrl valtoken:self.storageToken result:&result];
    if (error) {
        return error;
    }
    
    PogoplugResponse *response = [[PogoplugResponse alloc] initWithDictionary:result];
    for (PogoplugResponse_Device *device in response.devices) {
        NSString *deviceID = device.deviceID;
        if (deviceID.length > 0) {
            self.pogoplugDeviceID = deviceID;
            for (PogoplugResponse_Service *service in device.services) {
                self.pogoplugDeviceID = service.serviceID;
                self.pogoplugServiceApiUrl = [NSURL URLWithString:service.apiurl];
                if (self.pogoplugDeviceID && self.pogoplugServiceApiUrl) {
                    return nil; // OK.
                }
            }
        }
    }
    
    return [PogoplugError error:PogoplugError_InvalidResponseData];
     */
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
