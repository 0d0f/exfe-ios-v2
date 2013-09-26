//
//  EFTouchDownGestureRecognizer.m
//  MarauderMap
//
//  Created by 0day on 13-7-11.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFTouchDownGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation EFTouchDownGestureRecognizer

- (id)init {
    if (self = [super init]) {
        self.cancelsTouchesInView = NO;
        self.minimumNumberOfTouches = 1;
        self.maximumNumberOfTouches = UINT_MAX;
    }
    
    return self;
}

#pragma mark - Respionder Callback

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchesBeganCallback) {
        _touchesBeganCallback(touches, event);
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchesMovedCallback) {
        _touchesMovedCallback(touches, event);
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchesEndedCallback) {
        _touchesEndedCallback(touches, event);
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_touchesCancelledCallback) {
        _touchesCancelledCallback(touches, event);
    }
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark - Override

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return YES;
}


@end
