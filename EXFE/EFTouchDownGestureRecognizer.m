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
//    if (touches.count >= self.minimumNumberOfTouches &&
//        touches.count <= self.maximumNumberOfTouches &&
//        self.state == UIGestureRecognizerStatePossible) {
        self.state = UIGestureRecognizerStateRecognized;
//        if (_touchesBeganCallback) {
//            _touchesBeganCallback(touches, event);
//        }
//    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (touches.count >= self.minimumNumberOfTouches && touches.count <= self.maximumNumberOfTouches) {
//        if (_touchesMovedCallback) {
//            _touchesMovedCallback(touches, event);
//        }
//    }
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (touches.count >= self.minimumNumberOfTouches && touches.count <= self.maximumNumberOfTouches) {
//        if (_touchesEndedCallback) {
//            _touchesEndedCallback(touches, event);
//        }
//    }
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (touches.count >= self.minimumNumberOfTouches && touches.count <= self.maximumNumberOfTouches) {
//        if (_touchesCancelledCallback) {
//            _touchesCancelledCallback(touches, event);
//        }
//    }
    self.state = UIGestureRecognizerStateFailed;
}

#pragma mark - Override

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return YES;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    return YES;
}


@end
