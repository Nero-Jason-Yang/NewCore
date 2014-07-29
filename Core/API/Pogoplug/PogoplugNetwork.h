//
//  PogoplugNetwork.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PogoplugNetwork : NSObject

+ (void) get:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion;
+ (void)post:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion;
+ (void)head:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSError *error))completion;
+ (void) put:(NSURL *)url path:(NSString *)path data:(NSData *)data completion:(void (^)(NSError *error))completion;
+ (void)down:(NSURL *)url path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion;

@end
