// WJHXCTest/XCTestObserver+WJHObserver.h
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
 A category on `XCTestObserver` to provide convenience methods for managing observer subclasses.  In addition, tests can now be observed by registering for notifications with the default notification center.
 
 When XCTest starts, it will create "singleton" instances of each class listed in the user defaults for key XCTestObserverClassKey.
 However, the timing for this is a bit tricky.  Basically, if you want to add an observer class, it needs to be done in a +load method.
 
 ## Notifications
 
 Notifications sent to allow test observation without having to subclass XCTestObserver.
 
 ### WJHXCTestDidStartObservingNotification
 
 Test observation has started.  No user info.
 
 ### WJHXCTestDidStopObservingNotification
 
 Test observation has stopped.  No user info.
 
 ### WJHXCTestSuiteDidStartNotification
 
 A test suite has started.  User info contains the `XCTestRun` object for this test suite run, accessed by key @"testRun".
 
 ### WJHXCTestSuiteDidStopNotification
 
 A test suite has stopped.  User info contains the `XCTestRun` object for this test suite run, accessed by key @"testRun".

 ### WJHXCTestCaseDidStartNotification
 
 A test case has started.  User info contains the `XCTestRun` object for this test case run, accessed by key @"testRun".

 ### WJHXCTestCaseDidStopNotification

 A test case has stopped.  User info contains the `XCTestRun` object for this test case run, accessed by key @"testRun".
 
 ### WJHXCTestCaseDidFailNotification
 
 A test case has failed.  User info contains the following key/value pairs.
 
 + @"testRun": (XCTestRun*) the test case run
 + @"description": (NSString*) description of the failure
 + @"inFile": (NSString*) the name of the file in which the failure happened (NSString*)
 + @"atLine": (NSNumber*) the line number of the failure

 */
@interface XCTestObserver (WJHObserver)

/** Get the classes registered to be XCTest observers.
 @result Array of class objects
 */
+ (NSArray*)wjhObservingClasses;

/** Set the classes to be registered as XCTest observers.
 @param observers Array of class objects
 */
+ (void)wjhSetObservingClasses:(NSArray*)observers;

/** Add a class to be an XCTest observer.
 @param class The class to be added as an XCTest observer
 */
+ (void)wjhAddObservingClass:(Class)class;

/** Remove a class from the list of XCTest observers.
 @param class The class to be removed.
 */
+ (void)wjhRemoveObservingClass:(Class)class;

@end


extern NSString * const WJHXCTestDidStartObservingNotification;
extern NSString * const WJHXCTestDidStopObservingNotification;
extern NSString * const WJHXCTestSuiteDidStartNotification;
extern NSString * const WJHXCTestSuiteDidStopNotification;
extern NSString * const WJHXCTestCaseDidStartNotification;
extern NSString * const WJHXCTestCaseDidStopNotification;
extern NSString * const WJHXCTestCaseDidFailNotification;

