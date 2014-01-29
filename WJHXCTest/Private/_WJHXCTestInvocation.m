// WJHXCTest/Private/_WJHXCTestInvocation.m
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
    if (data.invocationHasCompleted && (data.hasBeenMarkedFinished || data.finishOnExit)) {
      return RLR_Done;
    }
    if (fabs([startTime timeIntervalSinceNow]) >= data.timeoutInterval) {
      return RLR_Timeout;
    }
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
