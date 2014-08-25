//
//  Operation.h
//  NewCore
//
//  Created by Yang Jason on 14-8-23.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Operation : NSObject
@property (nonatomic,readonly) BOOL cancelled;
- (void)cancel;
- (void)addUnderlyingOperation:(NSOperation *)operation;
- (void)addCancellingBlock:(dispatch_block_t)block;
@end
