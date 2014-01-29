// WJHXCTest/Private/_WJHXCTestObserver.m
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
