//
//  EFTouchDownGestureRecognizer.h
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface EFTouchDownGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) NSUInteger        minimumNumberOfTouches; // Default as 1.
@property (nonatomic, assign) NSUInteger        maximumNumberOfTouches; // Default as UINT_MAX.

@property (nonatomic, strong) TouchesEventBlock touchesBeganCallback;
@property (nonatomic, strong) TouchesEventBlock touchesMovedCallback;
@property (nonatomic, strong) TouchesEventBlock touchesEndedCallback;
@property (nonatomic, strong) TouchesEventBlock touchesCancelledCallback;

@end
