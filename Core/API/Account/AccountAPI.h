//
//  AccountAPI.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-17.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACCOUNT_APIPATH_REGISTER        @"/api/v1/auth/ncs/register"
#define ACCOUNT_APIPATH_AUTHORIZE       @"/api/v1/auth/ncs/authorize"
#define ACCOUNT_APIPATH_REVOKE          @"/api/v1/auth/ncs/revoke"
#define ACCOUNT_APIPATH_PASSWORDCHANGE  @"/api/v1/auth/ncs/passwordchange"
#define ACCOUNT_APIPATH_PASSWORDRENEW   @"/api/v1/auth/ncs/passwordrenew"
#define ACCOUNT_APIPATH_GETUSER         @"/api/v1/user"
#define ACCOUNT_APIPATH_ACCEPTTOS       @"/api/v1/user/accepttos"
#define ACCOUNT_APIPATH_POGOPLUGLOGIN   @"/api/v1/subscriptions/pogoplug/login"
#define ACCOUNT_APIPATH_STORAGEAUTH     @"/api/v1/subscriptions/storage/auth"

@interface AccountAPI : NSObject

+ (NSOperation *)signup:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password details:(NSDictionary *)details completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)authorize:(NSURL *)apiurl username:(NSString *)username password:(NSString *)password completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)revoke:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)passwordchange:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email passwordold:(NSString *)passwordold passwordnew:(NSString *)passwordnew completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)passwordrenew:(NSURL *)apiurl email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)getuser:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)accepttos:(NSURL *)apiurl authorization:(NSString *)authorization email:(NSString *)email completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)pogopluglogin:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void (^)(NSDictionary *dictionary, NSError *error))completion;
+ (NSOperation *)storageauth:(NSURL *)apiurl authorization:(NSString *)authorization completion:(void(^)(NSDictionary *dictionary, NSError *error))completion;

@end
