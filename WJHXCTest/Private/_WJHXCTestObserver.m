//
//  _WJHXCTestObserver.m
//  WJHXCTest
//
//  Created by Jody Hagins on 1/25/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import "_WJHXCTestObserver.h"
#import "XCTestObserver+WJHObserver.h"

@implementation _WJHXCTestObserver

// Make sure any queued log messages are processed and the output FILEs are flushed.
static void flush(NSTimeInterval interval)
{
  [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:interval]];
  fflush(stdout);
  fflush(stderr);
}

+ (void)load;
{
  [self wjhAddObservingClass:[XCTestLog class]];
  [self wjhAddObservingClass:[_WJHXCTestObserver class]];
}

- (void) startObserving;
{
  [super startObserving];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestDidStartObservingNotification object:self];
}

- (void) stopObserving;
{
  [super stopObserving];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestDidStopObservingNotification object:self];
  flush(0.10);
}

- (void) testSuiteDidStart:(XCTestRun *) testRun;
{
  [super testSuiteDidStart:testRun];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestSuiteDidStartNotification object:self userInfo:@{@"testRun": testRun}];
}

- (void) testSuiteDidStop:(XCTestRun *) testRun;
{
  [super testSuiteDidStop:testRun];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestSuiteDidStopNotification object:self userInfo:@{@"testRun": testRun}];
}

- (void) testCaseDidStart:(XCTestRun *) testRun;
{
  [super testCaseDidStart:testRun];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestCaseDidStartNotification object:self userInfo:@{@"testRun": testRun}];
}

- (void) testCaseDidStop:(XCTestRun *) testRun;
{
  [super testCaseDidStop:testRun];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestCaseDidStopNotification object:self userInfo:@{@"testRun": testRun}];
  flush(0.01);
}

- (void) testCaseDidFail:(XCTestRun *) testRun withDescription:(NSString *)description inFile:(NSString *) filePath atLine:(NSUInteger) lineNumber;
{
  [super testCaseDidFail:testRun withDescription:description inFile:filePath atLine:lineNumber];
  [[NSNotificationCenter defaultCenter] postNotificationName:WJHXCTestCaseDidFailNotification object:self userInfo:@{@"testRun": testRun, @"description": description, @"inFile": filePath, @"atLine": @(lineNumber)}];
}

@end
