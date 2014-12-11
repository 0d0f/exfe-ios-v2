//
//  EFMapColorButton.m
//  MarauderMap
//
//  Created by 0day on 13-7-10.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapColorButton.h"

#import <QuartzCore/QuartzCore.h>

#define kDefaultColorLayerHeight    (6.0f)

@interface EFMapColorButton ()

@property (nonatomic, strong) CALayer   *colorLayer;

@end

@interface EFMapColorButton (Private)

- (void)_updateUI;

@end

@implementation EFMapColorButton (Private)

- (void)_updateUI {
    if (!self.colorLayer) {
        CALayer *colorLayer = [CALayer layer];
        colorLayer.cornerRadius = kDefaultColorLayerHeight * 0.5f;
        colorLayer.shadowOpacity = 1.0f;
        colorLayer.shadowRadius = 2.0f;
        colorLayer.shadowOffset = (CGSize){0.0f, 0.0f};
        colorLayer.borderWidth = 0.5f;
        colorLayer.borderColor = [UIColor whiteColor].CGColor;
        self.colorLayer = colorLayer;
        [self.layer addSublayer:colorLayer];
    }
    
    self.colorLayer.backgroundColor = self.color.CGColor;
    self.colorLayer.shadowColor = self.color.CGColor;
}

@end

@implementation EFMapColorButton

+ (EFMapColorButton *)buttonWithColor:(UIColor *)color {
    EFMapColorButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.color = color;
    return button;
}

- (void)layoutSubviews {
    CGRect viewBounds = self.bounds;
    CGRect colorLayerFrame = (CGRect){{0.0f, CGRectGetMidY(viewBounds) - kDefaultColorLayerHeight * 0.5f}, {CGRectGetWidth(viewBounds), kDefaultColorLayerHeight}};
    self.colorLayer.frame = colorLayerFrame;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self _updateUI];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.colorLayer.shadowRadius = 2.0f;
        self.colorLayer.opacity = 1.0f;
    } else {
        self.colorLayer.shadowRadius = 0.0f;
        self.colorLayer.opacity = 0.5f;
    }
}

@end
