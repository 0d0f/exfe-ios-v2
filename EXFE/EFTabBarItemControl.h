//
//  EFTabBarItemControl.h
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-17.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EFTabBarItemControl;
typedef void (^TouchUpInsideBlock)(EFTabBarItemControl *control);
typedef void (^SwipeBlock)(EFTabBarItemControl *control, UISwipeGestureRecognizerDirection direction);
typedef void (^TabBarItemTitleDidChangeBlock)(EFTabBarItemControl *control);

@class EFTabBarItem;
@interface EFTabBarItemControl : UIView

@property (nonatomic, strong) EFTabBarItem *tabBarItem;

@property (nonatomic, assign) BOOL touchEnable; // Default as YES
@property (nonatomic, copy) TouchUpInsideBlock touchUpInsideActionHandler;

@property (nonatomic, assign) BOOL swipeEnable; // Default as YES
@property (nonatomic, copy) SwipeBlock swipeActionHandler;

@property (nonatomic, copy) TabBarItemTitleDidChangeBlock tabBarItemTitleDidChangeHandler;

+ (EFTabBarItemControl *)controlWithTabBarItem:(EFTabBarItem *)item;
- (id)initWithTabBarItem:(EFTabBarItem *)item;

@end
