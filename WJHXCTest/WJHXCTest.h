// WJHXCTest/WJHXCTest.h
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
#import "XCTestCase+WJHAsync.h"

/** Convenience wrapper for marking an asynchronous test as finished */
#define WJHXCTFinished() ([self wjhFinished])

/** Convenience wrapper to wait for a simple condition, failing the test on timeout */
#define WJHXCTFailUnless(_Condition_) XCTAssertTrue([self waitUntil:^BOOL{ return _Condition_; }], @"waitUntil timed out")

/** Convenience wrapper to wait N seconds for a simple condition to become true, failing the test on a timeout */
#define WJHXCTFailInTimeUnless(_Seconds_, _Condition_) XCTAssertTrue([self waitFor:_Seconds_ orUntil:^BOOL{ return _Condition_; }], @"waitUntil timed out")


// For convenience with the rest of XCTest macros, we optionally drag these macros into that namespace
#if !defined(WJHXCT_NO_CONVENIENCE)
#define XCTFinished() WJHXCTFinished()
#define XCTFailUnless(_Condition_) WJHXCTFailUnless(_Condition_)
#define XCTFailInTimeUnless(_Seconds_, _Condition_) WJHXCTFailInTimeUnless(_Seconds_, _Condition_)
#endif
