//
//  Operation.m
//  NewCore
//
//  Created by Yang Jason on 14-8-23.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "Operation.h"
#import "Cancellable.h"

@interface UnderlyingOperation : NSObject <Cancellable>
- (id)initWithOperation:(NSOperation *)operation;
@end

@interface CancellingBlock : NSObject <Cancellable>
- (id)initWithBlock:(dispatch_block_t)block;
@end

@implementation Operation
{
    NSMutableArray *_cancellingItems;
}

- (id)init
{
    if (self = [super init]) {
        _cancellingItems = [NSMutableArray array];
    }
    return self;
}

- (void)cancel
{
    @synchronized(_cancellingItems) {
        for (id<Cancellable> item in _cancellingItems) {
            [item cancel];
        }
        _cancelled = YES;
    }
}

- (void)addUnderlyingOperation:(NSOperation *)operation
{
    @synchronized(_cancellingItems) {
        if (self.cancelled) {
            [operation cancel];
        } else {
            id<Cancellable> item = [[UnderlyingOperation alloc] initWithOperation:operation];
            [_cancellingItems addObject:item];
        }
    }
}

- (void)addCancellingBlock:(dispatch_block_t)block
{
    @synchronized(_cancellingItems) {
        if (self.cancelled) {
            block();
        } else {
            id<Cancellable> item = [[CancellingBlock alloc] initWithBlock:block];
            [_cancellingItems addObject:item];
        }
    }
}

@end

@implementation UnderlyingOperation
{
    NSOperation *_operation;
}

- (id)initWithOperation:(NSOperation *)operation
{
    if (self = [super init]) {
        _operation = operation;
    }
    return self;
}

- (void)cancel
{
    if (_operation) {
        [_operation cancel];
    }
}

@end

@implementation CancellingBlock
{
    dispatch_block_t _block;
}

- (id)initWithBlock:(dispatch_block_t)block
{
    if (self = [super init]) {
        _block = block;
    }
    return self;
}

- (void)cancel
{
    if (_block) {
        _block();
    }
}

@end
