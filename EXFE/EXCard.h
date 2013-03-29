//
//  EXCard.h
//  EXHereDemo
//
//  Created by 0day on 13-3-29.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    kEXCardArrowDirectionUp = 0,
    kEXCardArrowDirectionDown,
    kEXCardArrowDirectionLeft,
    kEXCardArrowDirectionRight
} EXCardArrowDirection;

@interface EXCard : UIView

- (id)initWithUser:(id)user;

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view arrowDirection:(EXCardArrowDirection)direction animated:(BOOL)animated complete:(void (^)(void))handler;

- (void)dismissWithAnimated:(BOOL)animated complete:(void (^)(void))handler;

@end
