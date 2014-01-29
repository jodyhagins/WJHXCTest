// WJHXCTest/XCTestCase+WJHAsync.h
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

#import <XCTest/XCTest.h>

/**
 A category on `XCTestCase` to add support for running asynchronous tests.
 */
@interface XCTestCase (WJHAsync)

/**
 Default: 10.0.  The number of seconds to wait for an asynchronous test to complete before failing the test due to timing out.
 */
@property NSTimeInterval wjhTimeoutInterval;

/**
 Default: 0.01.  The number of seconds for each run of the loop while waiting for an asynchronous test to complete.
 */
@property NSTimeInterval wjhRunLoopInterval;

/**
 Default: `NO`.  The framework will consider the test to be finished when the test returns, without requiring a call to wjhFinished.
 */
@property BOOL wjhFinishOnExit;


///-------------------------------------
/// @name Finishing an asynchronous test
///-------------------------------------

/**
 Notify the receiver that the current test has finished.
 
 An asynchronous test is run in its own thread of control, and will be waited for until it has exited and either a test failure has occurred, or the test has been marked as finished.  Call this method when your asynchronous test has finished executing.
  
    - (void)testAsyncRunSomeTestOnASeparateThread
    {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do your specific test
        [self wjhFinished];
      });
    }
 
 The macro XCTFinished() is a look-alike convenience for [self wjhFinished].
 */
- (void)wjhFinished;


///-------------------------------------
/// @name Notification callbacks
///-------------------------------------

/**
 Handle the timeout of an asynchronous test.
 
 This callback method is called by the testing framework when an asynchronous test times-out.  By default, it calls XCTestFail() to fail the test due to the timeout.  TestCase subclasses may want to override the method to handle the timeout differently than the default, which is to call XCTFail().
 */
- (void)wjhTestDidTimeout;

@end
