//
//  XCTestObserver+WJHObserver.m
//  WJHXCTest
//
//  Created by Jody Hagins on 1/25/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

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
