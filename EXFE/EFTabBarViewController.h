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
typedef void (^EFTabBarWillDisappearBlock)(void);

@class EFTabBarItem, EFTabBarViewController;
@protocol EFTabBarDataSource <NSObject>
@required
@property (nonatomic, retain) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@property (nonatomic, assign) EFTabBarViewController *tabBarViewController;     // You DON'T need to set this, tabBarViewController will set it.
@property (nonatomic, copy) UIColor *shadowColor;   // outer shadow color
@end

@class EFTabBar;
@interface EFTabBarViewController : UIViewController

@property (nonatomic, readonly) EFTabBar *tabBar;
@property (nonatomic, strong) NSArray *viewControllers; // should sorted by yourself, and set the tabBarItem level

@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex; // Init as NSNotFound

@property (nonatomic, assign) NSUInteger defaultIndex;
@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *defaultViewController;

@property (nonatomic, copy) EFTabBarTitlePressedBlock titlePressedHandler;      // Default as nil.
@property (nonatomic, copy) EFTabBarBackButtonBlock backButtonActionHandler;    // Default as nil, if you set it, you should handle the dismiss or pop action.
@property (nonatomic, copy) EFTabBarWillDisappearBlock tabBarWillDisappearHandler;    // Default as nil, called when tabBarViewController will dismiss.

- (id)initWithViewControllers:(NSArray *)viewControllers;

- (void)setSelectedViewController:(UIViewController<EFTabBarDataSource> *)selectedViewController animated:(BOOL)animated;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

- (NSArray *)viewControllersForClass:(Class)controllerClass;    // return an empty array if has not found.

@end
