//
//  _WJHXCTestCaseData.h
//  WJHXCTest
//
//  Created by Jody Hagins on 1/26/14.
//  Copyright (c) 2014 Jody Hagins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _WJHXCTestCaseData : NSObject
@property NSTimeInterval timeoutInterval;
@property NSTimeInterval runLoopInterval;
@property BOOL hasBeenMarkedFinished;
@property BOOL invocationHasCompleted;
@property BOOL seenFailure;
@property BOOL finishOnExit;
+ (_WJHXCTestCaseData*)dataFor:(id)object;
@end
