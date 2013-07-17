//
//  EFMapEditingAnnotationView.m
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapEditingAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFMapColorButton.h"

@interface EFMapEditingAnnotationView ()

@property (nonatomic, strong) EFMapColorButton  *blueButton;
@property (nonatomic, strong) EFMapColorButton  *redButton;
@property (nonatomic, strong) UIView            *panView;
@property (nonatomic, strong) UILabel           *label;

@end

@implementation EFMapEditingAnnotationView

- (void)_init {
    CGRect viewBounds = self.bounds;
    CGRect panViewFrame = (CGRect){CGPointZero, {30.0f, 30.0f}};
    
    UIView *panView = [[UIView alloc] initWithFrame:panViewFrame];
    panView.center = (CGPoint){CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds)};
    panView.backgroundColor = [UIColor colorWithRed:(51.0f / 255.0f) green:(51.0f / 255.0f) blue:(51.0f / 255.0f) alpha:0.8f];
    panView.layer.cornerRadius = 2.0f;
    [self addSubview:panView];
    self.panView = panView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:panView.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"P";
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    label.textColor = [UIColor whiteColor];
    [panView addSubview:label];
    self.label = label;
    
    CGRect buttonFrame = (CGRect){CGPointZero, {CGRectGetMidX(viewBounds) - 20.0f, CGRectGetHeight(viewBounds)}};
    EFMapColorButton *blueButton = [EFMapColorButton buttonWithColor:[UIColor colorWithRed:0.0f green:(123.0f / 255.0f) blue:1.0f alpha:1.0f]];
    blueButton.frame = buttonFrame;
    [self addSubview:blueButton];
    self.blueButton = blueButton;
    
    buttonFrame.origin = (CGPoint){CGRectGetWidth(viewBounds) - CGRectGetWidth(buttonFrame), 0.0f};
    EFMapColorButton *redButton = [EFMapColorButton buttonWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:(51.0f / 255.0f) alpha:1.0f]];
    redButton.frame = buttonFrame;
    [self addSubview:redButton];
    self.redButton = redButton;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

@end
