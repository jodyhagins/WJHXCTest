//
//  WJHXCTestTests.m
//  WJHXCTestTests
//
//  Created by Jody Hagins on 1/25/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "WJHXCTest.h"

@interface WJHXCTestTests : XCTestCase
@property BOOL expectTimeout;
@property BOOL testDidTimeout;
@end


@implementation WJHXCTestTests

- (void)wjhTestDidTimeout
{
  if (self.expectTimeout) {
    self.testDidTimeout = YES;
  } else {
    [super wjhTestDidTimeout];
  }
}

- (void)setUp
{
  [super setUp];
}

- (void)tearDown
{
  [super tearDown];
}

- (void)testThatDoesNotStartWithTestAsyncAndDoesNotEndWithAsyncIsNotAsynchronous
{
  XCTAssertEqualObjects([NSThread mainThread], [NSThread currentThread], @"Synchronous test should run on the main thread");
  XCTAssertTrue([self.invocation isMemberOfClass:[NSInvocation class]], @"Synchronous test should use NSInvocation");
}

- (void)testAsyncIsAsynchronousTest
{
  XCTAssertNotEqualObjects([NSThread mainThread], [NSThread currentThread], @"Asynchronous test should not be running on the main thread");
  XCTAssertTrue([self.invocation isMemberOfClass:NSClassFromString(@"_WJHXCTestInvocation")], @"Asynchronous test should use _WJHXCTestInvocation");
  XCTFinished();
}

- (void)testAsyncmainIsAsynchronousTestRunningOnMainThread
{
  XCTAssertEqualObjects([NSThread mainThread], [NSThread currentThread], @"Asynchronous test starting with testAsyncMain should be running on the main thread");
  XCTAssertTrue([self.invocation isMemberOfClass:NSClassFromString(@"_WJHXCTestInvocation")], @"Any asynchronous test should use _WJHXCTestInvocation");
  XCTFinished();
}

- (void)testIsAsynchronousTestAsync
{
  XCTAssertNotEqualObjects([NSThread mainThread], [NSThread currentThread], @"Asynchronous test should not be running on the main thread");
  XCTAssertTrue([self.invocation isMemberOfClass:NSClassFromString(@"_WJHXCTestInvocation")], @"Any asynchronous test should use _WJHXCTestInvocation");
  XCTFinished();
}

- (void)testIsAsynchronousTestRunningOnMainThreadAsyncmain
{
  XCTAssertEqualObjects([NSThread mainThread], [NSThread currentThread], @"Asynchronous test ending with AsyncMain should be running on the main thread");
  XCTAssertTrue([self.invocation isMemberOfClass:NSClassFromString(@"_WJHXCTestInvocation")], @"Any asynchronous test should use _WJHXCTestInvocation");
  XCTFinished();
}

- (void)testAsyncTimeout
{
  self.expectTimeout = YES;
  self.wjhTimeoutInterval = 0.1;
  usleep(0.15 * 1000000);
  XCTAssertTrue(self.testDidTimeout, @"The test did not timeout as expected");
}

- (void)testAsyncAutoFinishDoesNotTimeout
{
  self.wjhFinishOnExit = YES;
}
@end



// Simple test to make sure TestObserver notifications are being sent.
@interface WJHXCTestObserverTests : XCTestCase
@end

@implementation WJHXCTestObserverTests

static BOOL didStartObserving;
+ (void)load
{
  __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:WJHXCTestDidStartObservingNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
    didStartObserving = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
  }];
}

- (void)testDidStartObservingNotification
{
  XCTAssertTrue(didStartObserving, @"We did not receive a WJHXCTestDidStartObservingNotification");
}

- (void)testWeAreATestObserver
{
  XCTAssertTrue([[XCTestObserver wjhObservingClasses] containsObject:NSClassFromString(@"_WJHXCTestObserver")], @"Our _WJHXCTestObserver is not in the list of observing test classes");
}

@end
