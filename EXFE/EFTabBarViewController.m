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
@property (weak, nonatomic) EFTabBar *tabBar;
@property (nonatomic, strong) UIView *containView;
@property (nonatomic, weak) UIViewController<EFTabBarDataSource> *preSelectedViewController;
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
        EFTabBar *tabBar = [[EFTabBar alloc] initWithStyle:((UIViewController<EFTabBarDataSource> *)viewControllers[0]).tabBarStyle];
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
    self.tabBar.tabBarViewController = nil;
    self.tabBar = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_viewWillAppearHandler) {
        self.viewWillAppearHandler();
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_viewDidAppearHandler) {
        self.viewDidAppearHandler();
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_viewWillDisappearHandler) {
        self.viewWillDisappearHandler();
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (_viewDidDisappearHandler) {
        self.viewDidDisappearHandler();
    }
    
    [super viewDidDisappear:animated];
}


#pragma mark - Getter && Setter

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers == _viewControllers)
        return;
    
    if (_viewControllers) {
        _viewControllers = nil;
        _selectedIndex = NSNotFound;
        _selectedViewController = nil;
    }
    if (viewControllers && viewControllers.count) {
        // tabBarItems
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithCapacity:[viewControllers count]];
        for (UIViewController<EFTabBarDataSource> *viewController in viewControllers) {
            [tabBarItems addObject:viewController.customTabBarItem];
            viewController.tabBarViewController = self;
        }
        
        _tabBar.tabBarItems = tabBarItems;
        
        // own it
        _viewControllers = viewControllers;
        
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

- (void)setTitlePressedHandler:(EFTabBarTitlePressedBlock)titlePressedHandler {
    if (_titlePressedHandler == titlePressedHandler)
        return;
    
    [self.tabBar performSelector:@selector(setTitlePressedBlock:)
                      withObject:titlePressedHandler];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    NSParameterAssert(self.viewControllers.count);
    NSParameterAssert(selectedIndex >= 0 && selectedIndex < self.viewControllers.count);
    
    if (_selectedIndex == selectedIndex) {
        return;
    }
    
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
    [self _resizeContainViewAnimated:animated];
    
    self.preSelectedViewController = _selectedViewController;
    
    [self willChangeValueForKey:@"selectedViewController"];
    _selectedViewController = selectedViewController;
    [self didChangeValueForKey:@"selectedViewController"];
    
    [self _layoutSelectedViewController];
}

- (NSArray *)viewControllersForClass:(Class)controllerClass {
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithCapacity:[self.viewControllers count]];
    
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:controllerClass]) {
            [viewControllers addObject:viewController];
        }
    }
    
    return [viewControllers copy];
}

- (NSUInteger)indexOfViewControllerForClass:(Class)viewControllerClass {
    NSParameterAssert(viewControllerClass);
    
    NSUInteger index = NSNotFound;
    NSUInteger currentIndex = 0;
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:viewControllerClass]) {
            index = currentIndex;
            break;
        }
        
        currentIndex++;
    }
    
    return index;
}

- (NSUInteger)indexOfViewController:(UIViewController<EFTabBarDataSource> *)viewController {
    NSParameterAssert(viewController);
    
    return [self indexOfViewControllerForClass:[viewController class]];
}

#pragma mark - Private

- (void)_layoutSelectedViewController {
    UIViewController<EFTabBarDataSource> *viewController = self.selectedViewController;
    
    CGFloat subviewY = CGRectGetHeight(self.tabBar.frame) - CGRectGetMinY(self.containView.frame) - 20.0f;
    CGRect subviewFrame = (CGRect){{0.0f, subviewY}, {CGRectGetWidth(self.containView.frame), CGRectGetHeight(self.containView.frame) - subviewY}};
    viewController.initFrame = subviewFrame;
    viewController.view.frame = subviewFrame; // self.containView.bounds;
    
    // trasition
    [UIView transitionWithView:self.containView
                      duration:0.233f
                       options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.preSelectedViewController willMoveToParentViewController:nil];
                        [self.preSelectedViewController.view removeFromSuperview];
                        [self.preSelectedViewController removeFromParentViewController];
                        
                        [self addChildViewController:viewController];
                        [self.containView addSubview:viewController.view];
                        [viewController didMoveToParentViewController:self];
                    }
                    completion:^(BOOL finished){
                        self.containView.backgroundColor = viewController.view.backgroundColor;
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
