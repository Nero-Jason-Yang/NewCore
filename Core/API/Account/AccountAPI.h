//
//  AccountAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-17.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountAPI : NSObject

+ (void)auth_ncs_authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSString *authorization, NSError *error))completion;
+ (void)auth_ncs_revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSError *error))completion;
+ (void)auth_ncs_passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSError *error))completion;
+ (void)auth_ncs_passwordrenew:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSError *error))completion;
+ (void)user:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *user, NSError *error))completion;
+ (void)user_accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSError *error))completion;
+ (void)subscriptions_pogoplug_login:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSString *apihost, NSString *token, NSError *error))completion;
+ (void)subscriptions_storage_auth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(int64_t freeSpace, NSError *error))completion;

@end
