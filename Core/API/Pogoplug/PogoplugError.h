//
//  PogoplugError.h
//  BackItUp
//
//  Created by Jason Yang on 14-7-18.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : int32_t {
    PogoplugError_Unknown,
    PogoplugError_HostUnspecified,
    PogoplugError_NetworkNotAvailable,
    PogoplugError_InvalidResponseData, // unexpected, the response data is invalid.
    
    PogoplugError_Unauthorized,
} PogoplugErrorCode;

@interface PogoplugError : NSError

+ (NSError *)errorWithCode:(PogoplugErrorCode)code;

@end
