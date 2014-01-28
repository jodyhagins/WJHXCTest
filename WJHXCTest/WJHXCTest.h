//
//  WJHXCTest.h
//  WJHXCTest
//
//  Created by Jody Hagins on 1/25/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import "XCTestObserver+WJHObserver.h"
#import "XCTestCase+WJHAsync.h"

/** Convenience wrapper for marking an asynchronous test as finished */
#define XCTFinished() ([self wjhFinished])
