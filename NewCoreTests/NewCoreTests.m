//
//  NewCoreTests.m
//  NewCoreTests
//
//  Created by Jason Yang on 14-7-28.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Core.h"

@interface NewCoreTests : XCTestCase

@end

@implementation NewCoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    [[Core sharedInstance] login:@"ja2yang@nero.com" password:@"111111" completion:^(NSError *error) {
        if (error) {
            NSLog(@"Login failed with error: %@", error);
        } else {
            NSLog(@"Login succeeded.");
        }
    }];
    [NSThread sleepForTimeInterval:10];
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
