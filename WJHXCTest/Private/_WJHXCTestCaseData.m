//
//  _WJHXCTestCaseData.m
//  WJHXCTest
//
//  Created by Jody Hagins on 1/26/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import "_WJHXCTestCaseData.h"
#import <objc/runtime.h>

@implementation _WJHXCTestCaseData

- (id)init
{
  if (self = [super init]) {
    self.timeoutInterval = 10.0;
    self.runLoopInterval = 0.01;
    self.hasBeenMarkedFinished = NO;
    self.invocationHasCompleted = NO;
    self.seenFailure = NO;
    self.finishOnExit = NO;
  }
  return self;
}

+ (_WJHXCTestCaseData*)dataFor:(id)object
{
  static char const key[1];
  if (object == nil) return nil;
  id result = objc_getAssociatedObject(object, key);
  if (result == nil) {
    @synchronized([_WJHXCTestCaseData class]) {
      result = objc_getAssociatedObject(object, key);
      if (result == nil) {
        result = [_WJHXCTestCaseData new];
        objc_setAssociatedObject(object, key, result, OBJC_ASSOCIATION_RETAIN);
      }
    }
  }
  return result;
}

@end
