// WJHXCTest/Private/_WJHXCTestCaseData.m
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
