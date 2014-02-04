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


@interface WaitTests : XCTestCase
@property dispatch_group_t group;
@property (readonly) NSUInteger completionCount;
@property NSUInteger expectedCount;
@end

@implementation WaitTests
@synthesize completionCount = _completionCount;
- (NSUInteger)completionCount
{
  @synchronized(self) {
    return _completionCount;
  }
}

- (NSUInteger)done
{
  @synchronized(self) {
    return ++_completionCount;
  }
}

- (NSArray*)createQueues {
  NSMutableArray *allQueues = [NSMutableArray array];
  for (int i = 0; i < 100; ++i) {
    char buffer[64];
    sprintf(buffer, "queue %d", i);
    dispatch_queue_t q;
    switch (i % 6) {
      case 0: q = dispatch_get_main_queue(); break;
      case 1: q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      case 2: q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
      case 3: q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
      case 4: q = dispatch_queue_create(buffer, DISPATCH_QUEUE_CONCURRENT);
      case 5: q = dispatch_queue_create(buffer, DISPATCH_QUEUE_SERIAL);
    }
    [allQueues addObject:q];
  }
  return [allQueues copy];
}

- (NSUInteger)spawnTasksWithQueues:(NSArray*)queues {
  dispatch_group_t group = self.group;
  NSUInteger const limit = 1000;
  for (NSUInteger i = 0; i < limit; ++i) {
    dispatch_queue_t queue = queues[arc4random_uniform(queues.count)];
    dispatch_group_async(group, queue, ^{
      for (NSUInteger i = 0; i < limit; ++i) {
        dispatch_queue_t queue = queues[arc4random_uniform(queues.count)];
        dispatch_group_async(group, queue, ^{
          [self done];
        });
      }
    });
  }
  return limit * limit;
}

- (void)setUp {
  // Setting this means that the test should pass if it exits without any errors, without waiting on any other asynchronous actions.
  self.wjhFinishOnExit = YES;
  
  self.group = dispatch_group_create();
  self.expectedCount = [self spawnTasksWithQueues:[self createQueues]];
}

- (void)testAsyncWaitForGroupForever
{
  dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
  XCTAssertEqual(self.expectedCount, self.completionCount, @"All blocks did not run");
}

- (void)testAsyncmainWaitForGroupInMainThreadWithBlocksQueuedToBeProcessed
{
  XCTFailUnless(dispatch_group_wait(self.group, DISPATCH_TIME_NOW) == 0);
  XCTAssertEqual(self.expectedCount, self.completionCount, @"All blocks did not run");
}

@end
