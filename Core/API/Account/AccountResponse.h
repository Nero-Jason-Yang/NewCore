//
//  AccountResponse.h
//  NewCore
//
//  Created by Jason Yang on 14-9-2.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Response Types:
//

@interface AccountResponse : DictionaryReader
@property (readonly) NSNumber *code; // NSInteger
@property (readonly) NSString *message;
@end

@interface AccountResponse_Authorize : AccountResponse
@property (readonly) NSString *access_token;
@property (readonly) NSString *token_type;
@property (readonly) NSString *authorization; // composite string: ("%@ %@", token_type, access_token)
@end

@interface AccountResponse_PogoplugLogin : AccountResponse
@property (readonly) NSString *token;
@property (readonly) NSString *api_host;
@property (readonly) NSString *webclient_url;
@property (readonly) NSArray  *subscriptions; // [AccountResponseValue_Subscription]
@end

@interface AccountResponse_StorageAuth : AccountResponse
@property (readonly) NSString *api_host;
@property (readonly) NSString *access_token;
@property (readonly) NSString *token_type;
@property (readonly) NSNumber *expires_in; // NSInteger
@property (readonly) NSArray  *subscriptions; // [AccountResponseValue_Subscription]
@end

//
// Response Value Types
//

@class AccountResponseValue_Subscription;
@class AccountResponseValue_SubscriptionPlan;
@class AccountResponseValue_SubscriptionPlanDetails;
@class AccountResponseValue_SubscriptionSpace;

@interface AccountResponseValue_Subscription : DictionaryReader
@property (readonly) NSNumber *ID; // NSInteger
@property (readonly) NSString *provider;
@property (readonly) NSString *type;
@property (readonly) NSString *provider_id;
@property (readonly) NSDate   *creationdate;
@property (readonly) NSDate   *expirationdate;
@property (readonly) NSString *state;
@property (readonly) NSString *source;
@property (readonly) AccountResponseValue_SubscriptionPlan *plan;
@property (readonly) AccountResponseValue_SubscriptionSpace *space;
@end

@interface AccountResponseValue_SubscriptionPlan : DictionaryReader
@property (readonly) NSNumber *ID; // NSInteger
@property (readonly) NSString *provider;
@property (readonly) NSString *type;
@property (readonly) NSString *provplanid;
@property (readonly) NSString *name;
@property (readonly) AccountResponseValue_SubscriptionPlanDetails *details;
@end

@interface AccountResponseValue_SubscriptionPlanDetails : DictionaryReader
@property (readonly) NSNumber *capacity; // int64
@property (readonly) NSNumber *all_features; // BOOL
@end

@interface AccountResponseValue_SubscriptionSpace : DictionaryReader
@property (readonly) NSNumber *free; // int64
@property (readonly) NSNumber *used; // int64
@property (readonly) NSNumber *capacity; // int64
@end
