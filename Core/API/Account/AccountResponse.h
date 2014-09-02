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
@property (readonly) NSInteger code;
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
@property (readonly) NSArray *subscriptions; // [AccountResponseData_Subscription]
@end

@interface AccountResponseData_Subscription : DictionaryReader
// TODO
@end
