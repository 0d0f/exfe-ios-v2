//
//  EFTabBarItem.h
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kEFTabBarItemLevelNormal = 0,   // Show when taped
    kEFTabBarItemLevelLow,          // Hide when taped, swipe to show
    kEFTabBarItemLevelDefault
} EFTabBarItemLevel;

typedef enum {
    kEFTabBarItemStateNormal = 0,
    kEFTabBarItemStateHighlight
} EFTabBarItemState;

@interface EFTabBarItem : NSObject

@property (nonatomic, assign, getter = isTitleEnable) BOOL titleEnable;   // Default as NO, even set title, you should set this to YES to show title
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightImage;

@property (nonatomic, assign) BOOL shouldPop;   // Default as NO. when set to YES, the tab button will pop to left.

@property (nonatomic, assign) EFTabBarItemState tabBarItemState;    // default as kEFTabBarItemStateNormal
@property (nonatomic, assign) EFTabBarItemLevel tabBarItemLevel;    // default as kEFTabBarItemLevelNormal
@property (nonatomic, assign) NSUInteger defaultOrder;

+ (EFTabBarItem *)tabBarItemWithImage:(UIImage *)image;
- (id)initWithImage:(UIImage *)image;

@end
