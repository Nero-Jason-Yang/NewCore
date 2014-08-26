//
//  PogoplugNetwork.h
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PogoplugNetwork : NSObject

+ (NSOperation *) get:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion;
+ (NSOperation *)post:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSDictionary *response, NSError *error))completion;
+ (NSOperation *)head:(NSURL *)url path:(NSString *)path parameters:(NSDictionary *)parameters completion:(void (^)(NSError *error))completion;
+ (NSOperation *) put:(NSURL *)url path:(NSString *)path data:(NSData *)data completion:(void (^)(NSError *error))completion;
+ (NSOperation *)down:(NSURL *)url path:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion;

@end
