//
//  XCTestCase+WJHAsync.h
//  WJHXCTest
//
//  Created by Jody Hagins on 1/26/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

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
