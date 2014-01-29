WJHXCTest
=========

__WJHXCTest__ extends XCTest to enable asynchronous testing.  Individual tests can be run synchronously on the main thread (just like the existing mechanism), or asynchronously on either the main thread or a separate thread.  This allows for great flexibility in testing various asynchronous APIs.


## Installing the library

The code most be compiled and linked into your test.  The project provides a cocoapod spec file, so you can either install __WJHXCTest__ using cocoapods, or copy the files directly into your test target.  For example:

```ruby
target :MyTestTarget, :exclusive => true do
    pod 'WJHXCTest'
end
```
## Using the library

Check out the [documentation](http://cocoadocs.org/docsets/WJHXCTest/0.0.2/) for a detail description of the API.

The easiest way is to just include the main header file:

    #import <WJHXCTest/WJHXCTest.h>

This file "pollutes" the `XCT` namespace by defining `XCTFinished` so if you don't want that macro, or if you only want to use the Observer or TestCase categories you just need to include either of those:

    #import <WJHXCTest/XCTestObserver+WJHObserver.h>
    #import <WJHXCTest/XCTestCase+WJHAsync.h>

All relevant code is written as an extension on the `XCTest` framework.  Thus, you do not need to inherit from a special class.  You only need to include the category headers to access the methods.  The only method you must use is [XCTestCase wjhFinished].  The others are optional.

### Running a test asynchronously in its own thread

If a test method name starts with `testAsync` or ends with `Async` the test will be executed in a separate thread.
While the test is running, the main thread will be executing the main run loop at intervals on `wjhRunLoopInterval` seconds.
After `wjhTimeoutInterval` seconds, the test will fail due to a timeout error.

A test notifies the framework that it is finished by calling `wjhFinished` on the current test case.  Alternatively, `WJHXCTest.h` defines the `XCTFinished()` macro which finishes the current test.

### Running a test asynchronously in the main thread

If a test method name starts with `testAsyncmain` or ends with `Asyncmain` the test will run as described for an asynchronous test, except the test method will be enqueued on the main GCD queue, and will thus run on the main thread.
Thus, the test method is still truly asynchronous, except it runs on the main thread.  When the test method returns, the framework will continue to run the main run loop until the test fails or times out.

### Running a traditional synchronous test

If a test method name does not fit any of the cases described above, the test will run exactly as a traditional XCTest test.

## Examples

```objc
- (void)testAsyncMainLoopStillExecutesWhileTestDoesSomethingElse
{
  self.wjhFinishOnExit = YES;
  __block BOOL ranOnMain = NO;
  dispatch_async(dispatch_get_main_queue(), ^{
    ranOnMain = YES;
  });
  usleep(0.1 * 1000000);
  XCTAssertTrue(ranOnMain, @"Expect the dispatched block to have run on the main thread while sleeping");
}

- (void)testAsyncOnSeparateThreadFinishesOnMainThread
{
  dispatch_async(dispatch_get_main_queue(), ^{
    XCTFinished();
  });
}

- (void)testAsyncmainFinishesOnMainThread
{
  dispatch_async(dispatch_get_main_queue(), ^{
    XCTFinished();
  });
}

- (void)testAsyncmainFinishesOnSomeOtherThread
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    XCTFinished();
  });
}
```

## Observing test progress with notifications

The `XCTest` framework provides a mechanism to observe test progress by registering an `XCTestObserver`.  However, it is a bit tricky to do.  Thus, `WJHXCTest` installs an observer that sends notifications via the default NSNotificationCenter.

If you want a simple way to observe test progress, register with the default NSNotificationCenter for any of the following notifications.

    WJHXCTestDidStartObservingNotification
    WJHXCTestDidStopObservingNotification
    WJHXCTestSuiteDidStartNotification
    WJHXCTestSuiteDidStopNotification
    WJHXCTestCaseDidStartNotification
    WJHXCTestCaseDidStopNotification
    WJHXCTestCaseDidFailNotification

---

Copyright (c) 2013 Jody Hagins
All rights reserved.

