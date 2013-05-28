//
//  EFTabBarViewController.h
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EFTabBar.h"

typedef void (^EFTabBarTitlePressedBlock)(void);
typedef void (^EFTabBarBackButtonBlock)(void);

typedef void (^EFTabBarViewControllerBehaviorBlock)(void);

@class EFTabBarItem, EFTabBarViewController;
@protocol EFTabBarDataSource <NSObject>
@required
@property (nonatomic, retain) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@property (nonatomic, assign) EFTabBarViewController *tabBarViewController;     // You DON'T need to set this, tabBarViewController will set it.
@property (nonatomic, copy) UIImage *shadowImage;
@end

@class EFTabBar;
@interface EFTabBarViewController : UIViewController

@property (nonatomic, readonly) EFTabBar *tabBar;
@property (nonatomic, strong) NSArray *viewControllers; // should sorted by yourself, and set the tabBarItem level

@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex; // Init as NSNotFound

@property (nonatomic, assign) NSUInteger defaultIndex;
@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *defaultViewController;

// action handler
@property (nonatomic, copy) EFTabBarTitlePressedBlock titlePressedHandler;      // Default as nil.
@property (nonatomic, copy) EFTabBarBackButtonBlock backButtonActionHandler;    // Default as nil, if you set it, you should handle the dismiss or pop action.

// behavior handler
@property (nonatomic, copy) EFTabBarViewControllerBehaviorBlock viewWillAppearHandler;
@property (nonatomic, copy) EFTabBarViewControllerBehaviorBlock viewDidAppearHandler;
@property (nonatomic, copy) EFTabBarViewControllerBehaviorBlock viewWillDisappearHandler;
@property (nonatomic, copy) EFTabBarViewControllerBehaviorBlock viewDidDisappearHandler;

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)setSelectedViewController:(UIViewController<EFTabBarDataSource> *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (NSArray *)viewControllersForClass:(Class)controllerClass;    // return an empty array if has not found.
- (NSUInteger)indexOfViewControllerForClass:(Class)viewControllerClass; // start from 0, return the first index that found. NOTE: viewControllerClass CANNOT be nil!
- (NSUInteger)indexOfViewController:(UIViewController<EFTabBarDataSource> *)viewController; // start from 0, return the first index that found. NOTE: viewController CANNOT be nil!

@end
