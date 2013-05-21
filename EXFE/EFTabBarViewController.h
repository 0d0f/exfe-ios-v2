//
//  EFTabBarViewController.h
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EFTabBar.h"

typedef void (^EFTabBarBackButtonBlock)(void);

@class EFTabBarItem;
@protocol EFTabBarDataSource <NSObject>
@required
@property (nonatomic, retain) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@end

@class EFTabBar;
@interface EFTabBarViewController : UIViewController

@property (nonatomic, readonly) EFTabBar *tabBar;
@property (nonatomic, strong) NSArray *viewControllers; // should sorted by yourself, and set the tabBarItem level

@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex; // Init as NSNotFound

@property (nonatomic, assign) NSUInteger defaultIndex;
@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *defaultViewController;

@property (nonatomic, copy) EFTabBarBackButtonBlock backButtonActionHandler;    // Default as nil, if you set it, you should handle the dismiss or pop action

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)setSelectedViewController:(UIViewController<EFTabBarDataSource> *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end
