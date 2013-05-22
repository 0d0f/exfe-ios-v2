//
//  EFTabBar.h
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kEFTabBarStyleNormal = 0,   // height 70
    kEFTabBarStyleDoubleHeight  // height 100
} EFTabBarStyle;

@class EFTabBarViewController;
@interface EFTabBar : UIView

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic, retain) NSArray *tabBarItems;
@property (nonatomic, assign) EFTabBarViewController *tabBarViewController;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;

- (id)initWithStyle:(EFTabBarStyle)style;

- (void)setSelectedIndex:(NSUInteger)index;

@end
