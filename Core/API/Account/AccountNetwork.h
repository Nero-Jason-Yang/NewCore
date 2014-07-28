//
//  AccountNetwork.h
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountNetwork : NSObject

+ (void)post:(NSURL *)url path:(NSString *)path authorization:(NSString *)authorization parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion;

@end
