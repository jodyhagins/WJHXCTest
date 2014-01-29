// WJHXCTestTests/WJHXCTestTests.m
//
// Copyright (c) 2013 Jody Hagins
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
