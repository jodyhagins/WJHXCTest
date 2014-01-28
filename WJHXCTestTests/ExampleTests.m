//
//  ExampleTests.m
//  WJHXCTest
//
//  Created by Jody Hagins on 1/26/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import "WJHXCTest.h"

@interface ExampleTests : XCTestCase

@end

@implementation ExampleTests

- (void)testAsyncMainLoopStillExecutesWhileTestDoesSomethingElse
{
  self.wjhFinishOnExit = YES;
  __block BOOL ranOnMain = NO;
  dispatch_async(dispatch_get_main_queue(), ^{
    ranOnMain = YES;
  });
  usleep(0.1 * 1000000);
  XCTAssertTrue(ranOnMain, @"Expect the dispatched block to have run on the main thread while sleeping");
}

- (void)testAsyncOnSeparateThreadFinishesOnMainThread
{
  dispatch_async(dispatch_get_main_queue(), ^{
    XCTFinished();
  });
}

- (void)testAsyncmainFinishesOnMainThread
{
  dispatch_async(dispatch_get_main_queue(), ^{
    XCTFinished();
  });
}

- (void)testAsyncmainFinishesOnSomeOtherThread
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    XCTFinished();
  });
}

@end
