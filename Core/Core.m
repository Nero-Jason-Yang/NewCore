//
//  CoreAPI.m
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "CoreAPI.h"
#import "NSError+Core.h"
#import "AccountAPI.h"
#import "AccountError.h"
#import "PogoplugAPI.h"
#import "PogoplugError.h"
#import "PogoplugResponse.h"
#import "PogoPlugOperationManager.h"
#import "StorageFile+Pogoplug.h"

@interface CoreAPI ()
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
@property (nonatomic) StorageFile *root;
@property (nonatomic) StorageFile *photoTimelines;
@property (nonatomic) StorageFile *photoAlbums;
@property (nonatomic) StorageFile *videoTimelines;
@property (nonatomic) StorageFile *videoAlbums;
@property (nonatomic) StorageFile *documents;
@property (nonatomic) StorageFile *musicSongs;
@property (nonatomic) StorageFile *musicAlbums;
@property (nonatomic) StorageFile *musicArtists;
@property (nonatomic) StorageFile *musicGenres;
@property (nonatomic) StorageFile *musicPlaylists;
@property (nonatomic) StorageFile *genericCollections; // a generic collection is a group of files, used for multi-share.
@end

@implementation CoreAPI
{
    NSObject *_storageTokenLocker;
}

+ (CoreAPI *)sharedInstance
{
    static CoreAPI *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreAPI alloc] init];
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

- (NSError *)login:(NSString *)username password:(NSString *)password
{
    NSParameterAssert(username && password);
    
    if (0 == username.length || 0 == password.length) {
        NSParameterAssert(0);
        return [AccountError errorWithCode:AccountError_Login_DataMissing];
    }
    
    self.accountState = AccountState_Logining;
    
    NSString *authorization = nil;
    NSError *error = [AccountAPI auth_ncs_authorize:self.accountApiUrl username:username password:password authorization:&authorization];
    
    if (error) {
        self.accountToken = nil;
        self.accountState = AccountState_LoginFailed;
        return error;
    }
    else {
        //self.username = username;
        //self.lastLoginDate = [NSDate date];
        
        self.accountToken = authorization;
        self.accountState = AccountState_LoginSucceeded;
        
        //[self tryTransferImageCacheFromDatabase];
        return nil;
    }
}

- (NSError *)logout
{
    if (self.accountToken) {
        NSError *error = [AccountAPI auth_ncs_revoke:self.accountApiUrl authorization:self.accountToken];
        if (error.isTimeout) {
            for (int i = 0; i < 3 && error.isTimeout; i ++) {
                error = [AccountAPI auth_ncs_revoke:self.accountApiUrl authorization:self.accountToken];
            }
        }
        if (error) {
            return error;
        }
    }
    
    self.accountToken = nil;
    self.accountState = AccountState_Logouted;
    return nil;
}

- (NSError *)changePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword
{
    NSParameterAssert(newPassword && oldPassword);
    
    return [AccountAPI auth_ncs_passwordchange:self.accountApiUrl authorization:self.accountToken email:self.accountEmail passwordold:oldPassword passwordnew:newPassword];
}

- (NSError *)forgotPassword:(NSString *)email
{
    NSParameterAssert(email);
    
    return [AccountAPI auth_ncs_passwordrenew:self.accountApiUrl authorization:self.accountToken email:email];
}

- (NSError *)acceptTOS:(NSString *)email
{
    NSParameterAssert(email);
    
    return [AccountAPI user_accepttos:self.accountApiUrl authorization:self.accountToken email:email];
}

#pragma mark - storage actions

- (NSError *)openFile:(NSString *)filename parentid:(NSString *)parentid type:(FileType)type ctime:(NSDate *)ctime mtime:(NSDate *)mtime file:(StorageFile **)file
{
    NSParameterAssert(filename && file);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    NSString *pogoplugFileType = [NSNumber numberWithInteger:type].description;
    
    NSDictionary *result = nil;
    error = [PogoplugAPI createFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID filename:filename parentid:parentid type:pogoplugFileType mtime:mtime ctime:ctime result:&result];
    if (error) {
        return error;
    }
    
    PogoplugResponse *response = [[PogoplugResponse alloc] initWithDictionary:result];
    error = [StorageFile makeFile:file fromPogoplugResponse:response.file];
    if (error) {
        return error;
    }
    
    return nil;
}

- (NSError *)renameFile:(NSString *)fileid newname:(NSString *)newname
{
    NSParameterAssert(fileid && newname);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    error = [PogoplugAPI moveFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid newname:newname];
    if (error) {
        return error;
    }
    
    return nil;
}

- (NSError *)deleteFile:(NSString *)fileid recurse:(BOOL)recurse
{
    NSParameterAssert(fileid);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    error = [PogoplugAPI removeFile:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid recurse:recurse];
    if (error) {
        return error;
    }
    
    return nil;
}

- (NSError *)uploadFile:(NSString *)fileid data:(NSData *)data
{
    NSParameterAssert(fileid && data);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    NSURL *fileURL = nil;
    error = [PogoplugAPI getFileURL:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid flag:nil name:nil result:&fileURL];
    if (error) {
        return error;
    }
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:fileURL];
    if (![manager uploadData:data withPath:fileURL.path parameters:nil error:&error]) {
        return error;
    }
    
    return nil;
}

- (NSError *)downloadFile:(NSString *)fileid data:(NSData **)data
{
    NSParameterAssert(fileid && data);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    NSURL *fileURL = nil;
    error = [PogoplugAPI getFileURL:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:fileid flag:nil name:nil result:&fileURL];
    if (error) {
        return error;
    }
    
    PogoplugOperationManager *manager = [PogoplugOperationManager managerWithBaseURL:fileURL];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSData *responseData = [manager GET:fileURL.path parameters:nil operation:NULL error:&error];
    if (!responseData) {
        return error;
    }
    
    if (data) {
        *data = responseData;
    }
    return nil;
}

- (NSError *)forFile:(StorageFile *)file getThumbnailURL:(NSURL **)URL
{
    return [self forFile:file withFlag:PogoplugFlag_Thumbnail getURL:URL];
}

- (NSError *)forFile:(StorageFile *)file getPreviewURL:(NSURL **)URL
{
    return [self forFile:file withFlag:PogoplugFlag_Preview getURL:URL];
}

- (NSError *)forFile:(StorageFile *)file getStreamURL:(NSURL **)URL
{
    NSString *flag = [file.streamtype.lowercaseString isEqualToString:@"full"] ? PogoplugFlag_Stream : nil;
    return [self forFile:file withFlag:flag getURL:URL];
}

- (NSError *)forFile:(StorageFile *)file withFlag:(NSString *)flag getURL:(NSURL **)URL
{
    NSParameterAssert(file && URL);
    
    NSString *valtoken = nil;
    NSError *error = [self getStorageToken:&valtoken];
    if (error) {
        return error;
    }
    
    error = [PogoplugAPI getFileURL:self.pogoplugServiceApiUrl valtoken:valtoken deviceid:self.pogoplugDeviceID serviceid:self.pogoplugServiceID fileid:file.fileid flag:flag name:nil result:URL];
    if (error) {
        return error;
    }
    
    return nil;
}

- (NSError *)forFile:(StorageFile *)file getThumbnailCacheKey:(NSString **)key
{
    return [self forFile:file withFlag:PogoplugFlag_Thumbnail getCacheKey:key];
}

- (NSError *)forFile:(StorageFile *)file getPreviewCacheKey:(NSString **)key
{
    return [self forFile:file withFlag:PogoplugFlag_Preview getCacheKey:key];
}

- (NSError *)forFile:(StorageFile *)file getOriginCacheKey:(NSString **)key
{
    return [self forFile:file withFlag:nil getCacheKey:key];
}

- (NSError *)forFile:(StorageFile *)file withFlag:(NSString *)flag getCacheKey:(NSString **)key
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

- (NSError *)forCollection:(StorageFile *)collection getCachedFiles:(NSArray **)files
{
    // TODO
    return nil;
}

- (NSError *)forCollection:(StorageFile *)collection refresh:(NSUInteger)size getFiles:(NSArray **)files
{
    // TODO
    return nil;
}

- (NSError *)forCollection:(StorageFile *)collection next:(NSUInteger)size getFiles:(NSArray **)files
{
    // TODO
    return nil;
}

- (NSError *)openPhotoAlbum:(NSString *)name album:(StorageFile **)album
{
    // TODO
    return nil;
}

- (NSError *)openMusicPlaylist:(NSString *)name playlist:(StorageFile **)playlist
{
    // TODO
    return nil;
}

- (NSError *)openGenericCollection:(NSString *)name collection:(StorageFile **)collection
{
    // TODO
    return nil;
}

- (NSError *)forPhotoAlbum:(StorageFile *)album addFile:(StorageFile **)file getItem:(StorageFile **)item
{
    // TODO
    return nil;
}

- (NSError *)forMusicPlaylist:(StorageFile *)playlist addFile:(StorageFile **)file getItem:(StorageFile **)item
{
    // TODO
    return nil;
}

- (NSError *)forGenericCollection:(StorageFile *)collection addFile:(StorageFile **)file getItem:(StorageFile **)item
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
    return nil;
}

#pragma mark -

- (NSError *)getAccountToken:(NSString **)token
{
    NSString *accountToken = self.accountToken;
    if (!accountToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AccountNeedLoginNotification object:self];
        return [AccountError errorWithCode:AccountError_Unauthorized];
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
