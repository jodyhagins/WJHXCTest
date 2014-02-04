// WJHXCTest/XCTestCase+WJHAsync.m
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

#import "XCTestCase+WJHAsync.h"
#import "Private/_WJHXCTestCaseData.h"
#import "Private/_WJHXCTestInvocation.h"
#import <objc/runtime.h>

@implementation XCTestCase (WJHAsync)

#define DATA ([_WJHXCTestCaseData dataFor:self])
- (void)wjhFinished
{
  DATA.hasBeenMarkedFinished = YES;
}

- (void)wjhTestDidTimeout
{
  XCTFail(@"Asynchronous test timed out");
}

#pragma mark - Public Properties
- (void)setWjhRunLoopInterval:(NSTimeInterval)runLoopInterval
{
  DATA.runLoopInterval = runLoopInterval;
}
- (NSTimeInterval)wjhRunLoopInterval
{
  return DATA.runLoopInterval;
}

- (void)setWjhTimeoutInterval:(NSTimeInterval)timeoutInterval
{
  DATA.timeoutInterval = timeoutInterval;
}
- (NSTimeInterval)wjhTimeoutInterval
{
  return DATA.timeoutInterval;
}

- (void)setWjhFinishOnExit:(BOOL)wjhFinishOnExit
{
  DATA.finishOnExit = wjhFinishOnExit;
}
- (BOOL)wjhFinishOnExit
{
  return DATA.finishOnExit;
}

#pragma mark - Waiting for a condition
- (BOOL)waitUntil:(BOOL(^)(void))conditionBlock
{
  return [self waitFor:DISPATCH_TIME_FOREVER orUntil:conditionBlock];
}

- (BOOL)waitFor:(NSTimeInterval)seconds orUntil:(BOOL (^)(void))conditionBlock
{
  _WJHXCTestCaseData *data = DATA;
  
  NSDate *testStartTime = data.testStartTime;
  NSDate *startTime = [NSDate date];
  for (;;) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:data.runLoopInterval]];
    
    if (conditionBlock()) {
      return YES;
    }
    
    if (fabs([startTime timeIntervalSinceNow]) >= seconds || fabs([testStartTime timeIntervalSinceNow]) >= data.timeoutInterval) {
      return NO;
    }
  }
}


#pragma mark - Load/Swizzle
/*
 WARNING: This code depends on the current implementation of XCTestCase.  While unlikely to change, it may...
 The idea is to swizzle the setInvocation: method, as it is called to tell the test case which test method to run.  I have determined that the method is also called from the initializers as well.
 The replacement setInvocation: will class-swizzle the passed-in invocation to make it be an instance of _WJHXCTestInvocation, whose invoke method will manage the asynchronous invocation of the test method.
 */

static IMP
swizzle(Class class, SEL selector, IMP newImp)
{
  Method origMethod = class_getInstanceMethod(class, selector);
  IMP origImp = method_getImplementation(origMethod);
  if (!class_addMethod(class, selector, newImp, method_getTypeEncoding(origMethod))) {
    method_setImplementation(origMethod, newImp);
  }
  return origImp;
}

static BOOL
isAsynchronousTest(NSInvocation *invocation)
{
  NSString *selectorName = NSStringFromSelector(invocation.selector);
  return [selectorName hasPrefix:@"testAsync"] || [selectorName hasSuffix:@"Async"] || [selectorName hasSuffix:@"Asyncmain"];
}

static void
swizzleSetInvocation(Class class)
{
  typedef void (*Impl)(XCTestCase*, SEL, NSInvocation*);
  SEL _cmd = @selector(setInvocation:);
  __block Impl origImpl = (Impl)swizzle(class, _cmd, imp_implementationWithBlock(^(XCTestCase * self, NSInvocation *invocation) {
    if (isAsynchronousTest(invocation)) {
      object_setClass(invocation, [_WJHXCTestInvocation class]);
    }
    origImpl(self, _cmd, invocation);
  }));
}

static void
invokeOnMainThread(void(^block)(void))
{
  if ([NSThread isMainThread]) {
    block();
  }
  else {
    dispatch_sync(dispatch_get_main_queue(), block);
  }
}

static void
swizzleRecordFailure(Class class)
{
  typedef void (*Impl)(XCTestCase*, SEL, NSString*, NSString*, NSUInteger, BOOL);
  SEL _cmd = @selector(recordFailureWithDescription:inFile:atLine:expected:);
  __block Impl origImpl = (Impl)swizzle(class, _cmd, imp_implementationWithBlock(^(XCTestCase *self, NSString * description, NSString *filename, NSUInteger lineNumber, BOOL expected) {
    invokeOnMainThread(^{
      DATA.seenFailure = YES;
      origImpl(self, _cmd, description, filename, lineNumber, expected);
    });
  }));
}

+ (void)load
{
  swizzleSetInvocation(self);
  swizzleRecordFailure(self);
}

@end
