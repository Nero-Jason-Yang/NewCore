//
//  AccountAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-17.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AccountPath_Authorize       @"/api/v1/auth/ncs/authorize"
#define AccountPath_Revoke          @"/api/v1/auth/ncs/revoke"
#define AccountPath_PasswordChange  @"/api/v1/auth/ncs/passwordchange"
#define AccountPath_PasswordRenew   @"/api/v1/auth/ncs/passwordrenew"
#define AccountPath_GetUserInfo     @"/api/v1/user"
#define AccountPath_AcceptTOS       @"/api/v1/user/accepttos"
#define AccountPath_PogoplugLogin   @"/api/v1/subscriptions/pogoplug/login"
#define AccountPath_StorageAuth     @"/api/v1/subscriptions/storage/auth"

@interface AccountAPI : NSObject

+ (void)authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSString *authorization, NSError *error))completion;
+ (void)revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSError *error))completion;
+ (void)passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSError *error))completion;
+ (void)passwordrenew:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSError *error))completion;
+ (void)user:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *user, NSError *error))completion;
+ (void)accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSError *error))completion;
+ (void)pogopluglogin:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSString *apihost, NSString *token, NSError *error))completion;
+ (void)storageauth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(int64_t freeSpace, NSError *error))completion;

@end
