//
//  XCTestCase+WJHAsync.m
//  WJHXCTest
//
//  Created by Jody Hagins on 1/26/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

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
