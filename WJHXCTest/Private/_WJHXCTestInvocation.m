//
//  _WJHXCTestInvocation.m
//  WJHXCTest
//
//  Created by Jody Hagins on 1/26/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import "_WJHXCTestInvocation.h"
#import "_WJHXCTestCaseData.h"
#import <XCTest/XCTest.h>

// Silence the compiler about sending this method
@interface XCTestCase (WJHAsync)
- (void)wjhTestDidTimeout;
@end


@implementation _WJHXCTestInvocation

- (void)superInvoke
{
  [super invoke];
}

static void asyncInvoke(XCTestCase*, _WJHXCTestInvocation*);
- (void)invoke
{
  asyncInvoke(self.target, self);
}
@end


static dispatch_queue_t
invocationQueue(NSInvocation *invocation)
{
  NSString *selectorName = NSStringFromSelector(invocation.selector);
  if ([selectorName hasPrefix:@"testAsyncmain"] || [selectorName hasSuffix:@"Asyncmain"]) {
    return dispatch_get_main_queue();
  }

  NSString *queueName = [NSString stringWithFormat:@"%@.%@", [invocation.target class], NSStringFromSelector(invocation.selector)];
  return dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
}

static void
dispatchInvocation(_WJHXCTestCaseData *data,_WJHXCTestInvocation *invocation)
{
  data.invocationHasCompleted = NO;
  dispatch_async(invocationQueue(invocation), ^{
    [invocation superInvoke];
    data.invocationHasCompleted = YES;
  });
}

enum RunLoopResult {
  RLR_Done,
  RLR_Timeout
};
static enum RunLoopResult
runLoopUntilDoneOrTimeout(_WJHXCTestCaseData *data)
{
  NSDate *startTime = [NSDate date];
  // NSDate *expireTime = [NSDate dateWithTimeIntervalSinceNow:data.timeoutInterval];
  for (;;) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:data.runLoopInterval]];
#if 0
    if (data.invocationHasCompleted && (data.hasBeenMarkedFinished /*|| self.wjhSeenFailure*/ || fabs([startTime timeIntervalSinceNow]) >= data.timeoutInterval)) {
      break;
    }
#else
    if (data.invocationHasCompleted && (data.hasBeenMarkedFinished || data.finishOnExit)) {
      return RLR_Done;
    }
    if (fabs([startTime timeIntervalSinceNow]) >= data.timeoutInterval) {
      return RLR_Timeout;
    }
#endif
  }
}

static void
asyncInvoke(XCTestCase *testCase, _WJHXCTestInvocation *invocation)
{
  _WJHXCTestCaseData *data = [_WJHXCTestCaseData dataFor:testCase];
  dispatchInvocation(data, invocation);
  if (runLoopUntilDoneOrTimeout(data) == RLR_Timeout) {
    [testCase wjhTestDidTimeout];
  }
}
