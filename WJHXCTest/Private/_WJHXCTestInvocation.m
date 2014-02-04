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
#import "../XCTestCase+WJHAsync.h"
#import <XCTest/XCTest.h>

@implementation _WJHXCTestInvocation

- (void)_invokeTest
{
  _WJHXCTestCaseData *data = [_WJHXCTestCaseData dataFor:self.target];
  @autoreleasepool {
    [super invoke];
    data.invocationHasCompleted = YES;
  }
}

static void asyncInvoke(XCTestCase*, _WJHXCTestInvocation*);
- (void)invoke
{
  asyncInvoke(self.target, self);
}
@end

static BOOL
shouldInvokeOnMain(NSInvocation *invocation)
{
  NSString *selectorName = NSStringFromSelector(invocation.selector);
  return [selectorName hasPrefix:@"testAsyncmain"] || [selectorName hasSuffix:@"Asyncmain"];
}

static dispatch_queue_t
invocationQueue(NSInvocation *invocation)
{
  NSString *queueName = [NSString stringWithFormat:@"%@.%@", [invocation.target class], NSStringFromSelector(invocation.selector)];
  return dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
}

static void
dispatchInvocation(_WJHXCTestCaseData *data, _WJHXCTestInvocation *invocation)
{
  data.invocationHasCompleted = NO;
  if (shouldInvokeOnMain(invocation)) {
    [invocation performSelectorOnMainThread:@selector(_invokeTest) withObject:nil waitUntilDone:NO];
  } else {
    dispatch_async(invocationQueue(invocation), ^{
      [invocation _invokeTest];
    });
  }
}

static void
asyncInvoke(XCTestCase *testCase, _WJHXCTestInvocation *invocation)
{
  _WJHXCTestCaseData *data = [_WJHXCTestCaseData dataFor:testCase];
  dispatchInvocation(data, invocation);
  
  data.testStartTime = [NSDate date];
  BOOL success = [testCase waitFor:DISPATCH_TIME_FOREVER orUntil:^BOOL{
    return (data.invocationHasCompleted && (data.hasBeenMarkedFinished || data.finishOnExit));
  }];
  
  if (!success || fabs([data.testStartTime timeIntervalSinceNow]) >= data.timeoutInterval) {
    [testCase wjhTestDidTimeout];
  }
}
