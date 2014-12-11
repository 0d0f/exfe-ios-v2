//
//  EFMapColorButton.h
//  MarauderMap
//
//  Created by 0day on 13-7-10.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EFMapColorButton : UIButton

@property (nonatomic, strong) UIColor *color;

+ (EFMapColorButton *)buttonWithColor:(UIColor *)color;

@end
