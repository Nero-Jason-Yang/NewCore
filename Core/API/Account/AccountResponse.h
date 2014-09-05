//
//  AccountResponse.h
//  NewCore
//
//  Created by Jason Yang on 14-9-2.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryReader : NSObject
- (id)initWithDictionary:(NSDictionary *)dictionary;
@property (nonatomic,readonly) NSDictionary *dictionary;
@end

@interface AccountResponse : DictionaryReader
@property (readonly) NSNumber *code; // NSInteger
@property (readonly) NSString *message;
@property (readonly) id details;
@property (readonly) id data;
@end

@interface AccountResponse_Authorize : AccountResponse
@property (readonly) NSString *access_token;
@property (readonly) NSString *token_type;
@end

@interface AccountResponse_Authorize (Advance)
@property (readonly) NSString *authorization;
@end

@interface AccountResponse_PogoplugLogin : AccountResponse
@property (readonly) NSString *token;
@property (readonly) NSString *api_host;
@property (readonly) NSString *webclient_url;
@property (readonly) NSArray  *subscriptions; // [AccountResponseData_Subscription]
@end

@interface AccountResponse_StorageAuth : AccountResponse
@property (readonly) NSString *api_host;
@property (readonly) NSString *access_token;
@property (readonly) NSString *token_type;
@property (readonly) NSNumber *expires_in; // NSInteger
@property (readonly) NSArray  *subscriptions; // [AccountResponseData_Subscription]
@end

@class AccountResponseData_Subscription;
@class AccountResponseData_SubscriptionPlan;
@class AccountResponseData_SubscriptionPlanDetails;
@class AccountResponseData_SubscriptionSpace;

@interface AccountResponseData_Subscription : DictionaryReader
@property (readonly) NSNumber *ID; // NSInteger
@property (readonly) NSString *provider;
@property (readonly) NSString *type;
@property (readonly) NSString *provider_id;
@property (readonly) NSDate   *creationdate;
@property (readonly) NSDate   *expirationdate;
@property (readonly) NSString *state;
@property (readonly) NSString *source;
@property (readonly) AccountResponseData_SubscriptionPlan *plan;
@property (readonly) AccountResponseData_SubscriptionSpace *space;
@end

@interface AccountResponseData_SubscriptionPlan : DictionaryReader
@property (readonly) NSNumber *ID; // NSInteger
@property (readonly) NSString *provider;
@property (readonly) NSString *type;
@property (readonly) NSString *provplanid;
@property (readonly) NSString *name;
@property (readonly) AccountResponseData_SubscriptionPlanDetails *details;
@end

@interface AccountResponseData_SubscriptionPlanDetails : DictionaryReader
@property (readonly) NSNumber *capacity; // int64
@property (readonly) NSNumber *all_features; // BOOL
@end

@interface AccountResponseData_SubscriptionSpace : DictionaryReader
@property (readonly) NSNumber *free; // int64
@property (readonly) NSNumber *used; // int64
@property (readonly) NSNumber *capacity; // int64
@end
