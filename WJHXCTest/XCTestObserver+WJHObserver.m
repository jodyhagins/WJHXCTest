// WJHXCTest/XCTestObserver+WJHObserver.m
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

#import "XCTestObserver+WJHObserver.h"

@implementation XCTestObserver (WJHObserver)

+ (NSArray*)wjhObservingClasses
{
  NSArray *observerClassNames = [[[NSUserDefaults standardUserDefaults] stringForKey:XCTestObserverClassKey] componentsSeparatedByString:@","];
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:observerClassNames.count];
  for (NSString *name in observerClassNames) {
    Class class = NSClassFromString(name);
    if (class) [result addObject:class];
  }
  return [result copy];
}

static NSArray *
filteredObservingClasses(NSArray *observersIn)
{
  NSArray *result = [NSArray array];
  for (id object in observersIn) {
    Class class = Nil;
    
    if ([object respondsToSelector:@selector(class)]) {
      class = [object class];
    } else if ([object respondsToSelector:@selector(description)]) {
      class = NSClassFromString([object description]);
    }
    
    if ([class isSubclassOfClass:[XCTestObserver class]]) {
      result = [result arrayByAddingObject:class];
    }
  }
  return result;
}

+ (void)wjhSetObservingClasses:(NSArray *)observers
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[filteredObservingClasses(observers) componentsJoinedByString:@","] forKey:XCTestObserverClassKey];
  [defaults synchronize];
}

+ (void)wjhAddObservingClass:(Class)class
{
  NSArray *observers = [self wjhObservingClasses];
  if (class && ![observers containsObject:class]) {
    [self wjhSetObservingClasses:[observers arrayByAddingObject:class]];
  }
}

+ (void)wjhRemoveObservingClass:(Class)class
{
  NSMutableArray *observers = [[self wjhObservingClasses] mutableCopy];
  [observers removeObject:class];
  [self wjhSetObservingClasses:observers];
}

@end


NSString * const WJHXCTestDidStartObservingNotification = @"WJHXCTestDidStartObservingNotification";
NSString * const WJHXCTestDidStopObservingNotification = @"WJHXCTestDidStopObservingNotification";
NSString * const WJHXCTestSuiteDidStartNotification = @"WJHXCTestSuiteDidStartNotification";
NSString * const WJHXCTestSuiteDidStopNotification = @"WJHXCTestSuiteDidStopNotification";
NSString * const WJHXCTestCaseDidStartNotification = @"WJHXCTestCaseDidStartNotification";
NSString * const WJHXCTestCaseDidStopNotification = @"WJHXCTestCaseDidStopNotification";
NSString * const WJHXCTestCaseDidFailNotification = @"WJHXCTestCaseDidFailNotification";
