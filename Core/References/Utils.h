//
//  Utils.h
//  NewCore
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

#define opt // optional parameter indicator

@interface Utils : NSObject

@end


@interface NSURL (Utils)
+ (NSURL *)URLWithPath:(NSString *)path relativeToURL:(NSURL *)url;
+ (NSURL *)URLWithScheme:(NSString *)scheme relativeToURL:(NSURL *)url;
@end

@interface NSDate (Pogoplug)
+ (id)dateWithPogoplugTimeString:(NSString *)string;
- (NSString *)pogoplugTimeString;
@end

@interface NSError (HTTP)
#define HTTPErrorDomain @"HTTP"
#define HTTPHeaderFieldsErrorKey @"HTTPHeaderFields" // object is type of NSDictionary.
enum {
    HTTPErrorBadRequest            = 400,
    HTTPErrorUnauthorized          = 401,
    HTTPErrorPaymentRequired       = 402,
    HTTPErrorForbidden             = 403,
    HTTPErrorNotFound              = 404,
    HTTPErrorMethodNotAllowed      = 405,
    HTTPErrorNotAcceptable         = 406,
    HTTPErrorRequestTimeout        = 408,
    HTTPErrorConflict              = 409,
    HTTPErrorGone                  = 410,
    HTTPErrorLengthRequired        = 411,
    HTTPErrorPreconditionFailed    = 412,
    HTTPErrorRequestURITooLong     = 414,
    HTTPErrorExpectationFailed     = 417,
    HTTPErrorTooManyConnections    = 421,
    HTTPErrorUnprocessableEntity   = 422,
    HTTPErrorLocked                = 423,
    HTTPErrorFailedDependency      = 424,
    HTTPErrorUnorderedCollection   = 425,
    HTTPErrorUpgradeRequired       = 426,
    HTTPErrorRetryWith             = 449,
    HTTPErrorInternalServerError   = 500,
    HTTPErrorNotImplemented        = 501,
    HTTPErrorBadGateway            = 502,
    HTTPErrorServiceUnavailable    = 503,
    HTTPErrorGatewayTimeout        = 504,
    HTTPErrorInsufficientStorage   = 507,
    HTTPErrorLoopDetected          = 508,
    HTTPErrorNotExtended           = 510,
};
+ (id)errorWithResponse:(NSHTTPURLResponse *)response;
@end
