// WJHXCTestTests/ExampleTests.m
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
