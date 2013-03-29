//
//  EXCard.m
//  EXHereDemo
//
//  Created by 0day on 13-3-29.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import "EXCard.h"

#import <QuartzCore/QuartzCore.h>

@interface EXCard ()
@property (nonatomic, retain) UIView *bottomView;
@end

@implementation EXCard

- (id)initWithUser:(id)user {
    self = [super init];
    if (self) {
        self.frame = (CGRect){{20, 20}, {280, 50}};
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.layer.cornerRadius = 5;
    }
    
    return self;
}

static BOOL IsPresented = NO;
- (void)presentFromRect:(CGRect)rect inView:(UIView *)view arrowDirection:(EXCardArrowDirection)direction animated:(BOOL)animated complete:(void (^)(void))handler {
    if (IsPresented)
        return;
    IsPresented = YES;
    
    [self retain];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *rootView = window.rootViewController.view;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:rootView.bounds];
    bottomView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    [bottomView addGestureRecognizer:tap];
    [tap release];
    
    [rootView addSubview:bottomView];
    self.bottomView = bottomView;
    [bottomView release];
    
    self.alpha = 0.0f;
    
    [self.bottomView addSubview:self];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.alpha = 1.0f;
                     }];
}

- (void)dismissWithAnimated:(BOOL)animated complete:(void (^)(void))handler {
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [self.bottomView removeFromSuperview];
                         [self release];
                         IsPresented = NO;
                     }];
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    [self dismissWithAnimated:YES complete:nil];
}

@end
