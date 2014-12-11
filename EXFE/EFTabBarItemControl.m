//
//  EFTabBarItemControl.m
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-17.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import "EFTabBarItemControl.h"

#import "EFTabBarItem.h"

#define kDefaultFrame       ((CGRect){{-10.0f, 0.0f}, {54.0f, 44.0f}})
#define kDefaultImageFrame  ((CGRect){{17.0f, 10.0f}, {30.0f, 30.0f}})
#define kDefaultLabelFrame  ((CGRect){{15.0f, 14.5f}, {28.0f, 18.0f}})

@interface EFTabBarItemControl ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@interface EFTabBarItemControl (Private)
- (void)_tabBarItemTitleDidChange;
- (void)_tabBarItemStateDidChange;
- (void)_tabBarItemImageDidChange;
- (void)_tabBarItemHighlightImageDidChange;
- (void)_tabBarItemTitleEnableDidChange;
- (void)_tabBarItemShouldPopDidChange;
@end

@implementation EFTabBarItemControl

+ (EFTabBarItemControl *)controlWithTabBarItem:(EFTabBarItem *)item {
    return [[self alloc] initWithTabBarItem:item];
}

- (id)initWithTabBarItem:(EFTabBarItem *)item {
    self = [super initWithFrame:kDefaultFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // imageView
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:kDefaultImageFrame];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // title
        UILabel *label = [[UILabel alloc] initWithFrame:kDefaultLabelFrame];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        label.shadowOffset = (CGSize){0, 0.5f};
        [self addSubview:label];
        self.titleLabel = label;
        
        // tap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(touchUpInside:)];
        [self addGestureRecognizer:tap];
        
        // Pan
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(panHandler:)];
        [self addGestureRecognizer:pan];
        
        [tap requireGestureRecognizerToFail:pan];
        
        self.panGesture = pan;
        
        self.touchEnable = YES;
        self.swipeEnable = YES;
        
        self.tabBarItem = item;
    }
    return self;
}

- (void)dealloc {
    self.tabBarItem = nil;
}

#pragma mark - Action

- (void)touchUpInside:(EFTabBarItemControl *)sender {
    if (self.touchEnable && _touchUpInsideActionHandler) {
        self.touchUpInsideActionHandler(self);
    }
}

#pragma mark - Gesture

- (void)panHandler:(UIPanGestureRecognizer *)gesture {
    if (self.swipeEnable &&
        _swipeActionHandler &&
        UIGestureRecognizerStateEnded == gesture.state) {
        CGPoint velocity = [gesture velocityInView:self];
        
        if (velocity.x > 150.0f) {
            self.swipeActionHandler(self, UISwipeGestureRecognizerDirectionRight);
        } else if (velocity.x < -150.0f) {
            self.swipeActionHandler(self, UISwipeGestureRecognizerDirectionLeft);
        }
    }
}

#pragma mark - Getter && Setter

- (void)setSwipeEnable:(BOOL)swipeEnable {
    [self willChangeValueForKey:@"swipeEnable"];
    
    _swipeEnable = swipeEnable;
    
    self.panGesture.enabled = swipeEnable;
    
    [self didChangeValueForKey:@"swipeEnable"];
}

- (void)setTabBarItem:(EFTabBarItem *)tabBarItem {
    if (_tabBarItem == tabBarItem)
        return;
    
    [self willChangeValueForKey:@"tabBarItem"];
    if (_tabBarItem) {
        [_tabBarItem removeObserver:self
                         forKeyPath:@"title"];
        [_tabBarItem removeObserver:self
                         forKeyPath:@"tabBarItemState"];
        [_tabBarItem removeObserver:self
                         forKeyPath:@"image"];
        [_tabBarItem removeObserver:self
                         forKeyPath:@"highlightImage"];
        [_tabBarItem removeObserver:self
                         forKeyPath:@"titleEnable"];
        [_tabBarItem removeObserver:self
                         forKeyPath:@"shouldPop"];
        _tabBarItem = nil;
    }
    if (tabBarItem) {
        _tabBarItem = tabBarItem;
        [tabBarItem addObserver:self
                     forKeyPath:@"title"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:NULL];
        [tabBarItem addObserver:self
                     forKeyPath:@"tabBarItemState"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:NULL];
        [tabBarItem addObserver:self
                     forKeyPath:@"image"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:NULL];
        [tabBarItem addObserver:self
                     forKeyPath:@"highlightImage"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:NULL];
        [tabBarItem addObserver:self
                     forKeyPath:@"titleEnable"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:NULL];
        [tabBarItem addObserver:self
                     forKeyPath:@"shouldPop"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:NULL];
    }
    [self didChangeValueForKey:@"tabBarItem"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.tabBarItem) {
        if ([keyPath isEqualToString:@"title"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _tabBarItemTitleDidChange];
            });
        } else if ([keyPath isEqualToString:@"tabBarItemState"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _tabBarItemStateDidChange];
            });
        } else if ([keyPath isEqualToString:@"image"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _tabBarItemImageDidChange];
            });
        } else if ([keyPath isEqualToString:@"highlightImage"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _tabBarItemHighlightImageDidChange];
            });
        } else if ([keyPath isEqualToString:@"titleEnable"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _tabBarItemTitleEnableDidChange];
            });
        } else if ([keyPath isEqualToString:@"shouldPop"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _tabBarItemShouldPopDidChange];
            });
        }
    }
}

#pragma mark - Private

- (void)_tabBarItemTitleDidChange {
    self.titleLabel.text = self.tabBarItem.title;
    
    if (self.tabBarItem.titleEnable) {
        if (self.tabBarItem.title.length) {
            self.tabBarItem.tabBarItemState = kEFTabBarItemStateHighlight;
        } else {
            self.tabBarItem.tabBarItemState = kEFTabBarItemStateNormal;
        }
    } else {
        self.tabBarItem.tabBarItemState = kEFTabBarItemStateNormal;
    }

    if (_tabBarItemTitleDidChangeHandler && self.tabBarItem.titleEnable) {
        self.tabBarItemTitleDidChangeHandler(self);
    }
}

- (void)_tabBarItemStateDidChange {
    if (kEFTabBarItemStateNormal == self.tabBarItem.tabBarItemState && self.tabBarItem.image) {
        self.imageView.image = self.tabBarItem.image;
    } else if (kEFTabBarItemStateHighlight == self.tabBarItem.tabBarItemState && self.tabBarItem.highlightImage) {
        self.imageView.image = self.tabBarItem.highlightImage;
    }
}

- (void)_tabBarItemImageDidChange {
    if (kEFTabBarItemStateNormal == self.tabBarItem.tabBarItemState && self.tabBarItem.image) {
        self.imageView.image = self.tabBarItem.image;
    }
}

- (void)_tabBarItemHighlightImageDidChange {
    if (kEFTabBarItemStateHighlight == self.tabBarItem.tabBarItemState && self.tabBarItem.highlightImage) {
        self.imageView.image = self.tabBarItem.highlightImage;
    }
}

- (void)_tabBarItemTitleEnableDidChange {
    self.titleLabel.hidden = !self.tabBarItem.isTitleEnable;
}

- (void)_tabBarItemShouldPopDidChange {
    if (self.tabBarItem.shouldPop) {
        self.tabBarItem.tabBarItemState = kEFTabBarItemStateHighlight;
    } else {
        self.tabBarItem.tabBarItemState = kEFTabBarItemStateNormal;
    }
}

@end
