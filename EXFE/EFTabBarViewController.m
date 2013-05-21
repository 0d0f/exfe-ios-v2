//
//  EFTabBarViewController.m
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import "EFTabBarViewController.h"

#import "EFTabBarItem.h"

@interface EFTabBarViewController ()
@property (nonatomic, retain) UIView *containView;
@property (nonatomic, assign) UIViewController<EFTabBarDataSource> *preSelectedViewController;
@end

@interface EFTabBarViewController (Private)
- (void)_layoutSelectedViewController;
- (void)_resizeContainViewAnimated:(BOOL)animated;
@end

@implementation EFTabBarViewController {
    struct {
        CGRect appFrame;
    } _cache;
}

- (id)initWithViewControllers:(NSArray *)viewControllers {
    self = [super init];
    if (self) {
        // self.view frame
        CGRect appFrame = [UIScreen mainScreen].applicationFrame;
        self.view.frame = appFrame;
        
        _cache.appFrame = appFrame;
        
        // tabBar
        EFTabBar *tabBar = [[EFTabBar alloc] initWithStyle:kEFTabBarStyleNormal];
        tabBar.tabBarViewController = self;
        [self.view addSubview:tabBar];
        _tabBar = tabBar;
        
        // containView
        CGFloat containViewY = CGRectGetHeight(tabBar.frame) - 20.0f;
        UIView *containView = [[UIView alloc] initWithFrame:(CGRect){{0, containViewY}, CGRectGetWidth(appFrame), CGRectGetHeight(appFrame) - containViewY}];
        [self.view insertSubview:containView belowSubview:tabBar];
        _containView = containView;
        
        // view controllers
        _selectedIndex = NSNotFound;
        self.viewControllers = viewControllers;
    }
    
    return self;
}

- (void)dealloc {
    [_containView release];
    [_tabBar release];
    [_viewControllers release];
    [super dealloc];
}

#pragma mark - Getter && Setter

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers == _viewControllers)
        return;
    
    if (_viewControllers) {
        [_viewControllers release];
        _viewControllers = nil;
        _selectedIndex = NSNotFound;
        _selectedViewController = nil;
    }
    if (viewControllers && viewControllers.count) {
        // tabBarItems
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithCapacity:[viewControllers count]];
        for (UIViewController<EFTabBarDataSource> *viewController in viewControllers) {
            [tabBarItems addObject:viewController.customTabBarItem];
        }
        _tabBar.tabBarItems = tabBarItems;
        [tabBarItems release];
        
        // own it
        _viewControllers = [viewControllers retain];
        
        // select
        self.selectedIndex = 0;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedViewController:(UIViewController<EFTabBarDataSource> *)selectedViewController {
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.tabBar.titleLabel.text = title;
}

- (void)setDefaultIndex:(NSUInteger)defaultIndex {
    NSParameterAssert(self.viewControllers.count);
    NSParameterAssert(defaultIndex >= 0 && defaultIndex < self.viewControllers.count);
    
    if (_defaultIndex == defaultIndex)
        return;
    
    [self willChangeValueForKey:@"defaultIndex"];
    _defaultIndex = defaultIndex;
    UIViewController<EFTabBarDataSource> *viewController = self.viewControllers[defaultIndex];
    [self setDefaultViewController:viewController];
    [self didChangeValueForKey:@"defaultIndex"];
}

- (void)setDefaultViewController:(UIViewController<EFTabBarDataSource> *)defaultViewController {
    NSParameterAssert(defaultViewController);
    
    if (_defaultViewController == defaultViewController)
        return;
    
    [self willChangeValueForKey:@"defaultViewController"];
    _defaultViewController = defaultViewController;
    [self didChangeValueForKey:@"defaultViewController"];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    NSParameterAssert(self.viewControllers.count);
    NSParameterAssert(selectedIndex >= 0 && selectedIndex < self.viewControllers.count);
    
    if (_selectedIndex == selectedIndex)
        return;
    
    [self willChangeValueForKey:@"selectedIndex"];
    _selectedIndex = selectedIndex;
    [self didChangeValueForKey:@"selectedIndex"];
    
    UIViewController<EFTabBarDataSource> *viewController = self.viewControllers[selectedIndex];
    [self setSelectedViewController:viewController animated:animated];
}

- (void)setSelectedViewController:(UIViewController<EFTabBarDataSource> *)selectedViewController animated:(BOOL)animated {
    NSParameterAssert(selectedViewController);
    
    if (_selectedViewController == selectedViewController)
        return;
    
    self.tabBar.tabBarStyle = selectedViewController.tabBarStyle;
    [self _resizeContainViewAnimated:YES];
    
    self.preSelectedViewController = selectedViewController;
    
    [self willChangeValueForKey:@"selectedViewController"];
    _selectedViewController = selectedViewController;
    [self didChangeValueForKey:@"selectedViewController"];
    
    [self _layoutSelectedViewController];
}

#pragma mark - Private

- (void)_layoutSelectedViewController {
    UIViewController<EFTabBarDataSource> *viewController = self.selectedViewController;
    
    CGFloat subviewY = CGRectGetHeight(self.tabBar.frame) - CGRectGetMinY(self.containView.frame) - 20.0f;
    CGRect subviewFrame = (CGRect){{0.0f, subviewY}, {CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.frame) - subviewY}};
    viewController.view.frame = subviewFrame; // self.containView.bounds;
    
    // trasition
    [UIView transitionWithView:self.containView
                      duration:0.233f
                       options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.preSelectedViewController.view removeFromSuperview];
                        [self.containView addSubview:viewController.view];
                    }
                    completion:^(BOOL finished){
                    }];
}

- (void)_resizeContainViewAnimated:(BOOL)animated {
    CGFloat containViewY = 50.0f; //CGRectGetHeight(self.tabBar.frame) - 20.0f;
    CGRect containFrame = (CGRect){{0, containViewY}, CGRectGetWidth(_cache.appFrame), CGRectGetHeight(_cache.appFrame) - containViewY};
    
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.containView.frame = containFrame;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                     }];
}

@end
