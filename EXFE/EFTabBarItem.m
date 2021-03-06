//
//  EFTabBarItem.m
//  EFHeaderBarDemo
//
//  Created by 0day on 13-5-16.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import "EFTabBarItem.h"

@implementation EFTabBarItem

+ (EFTabBarItem *)tabBarItemWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.titleEnable = NO;
        self.image = image;
        self.shouldPop = NO;
    }
    
    return self;
}


@end
