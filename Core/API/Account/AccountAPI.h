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

+ (NSOperation *)authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)passwordrenew:(NSURL *)apiurl email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)getuser:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)pogopluglogin:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)storageauth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;

@end
