//
//  EFMapEditingPathView.h
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EFMapEditingPathView : UIView

@property (nonatomic, assign) NSUInteger    selectedIndex;      // Default as 0.
@property (nonatomic, weak)   UIColor       *selectedColor;     // can't be nil. Default as the first color.

- (UIColor *)colorAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfColor:(UIColor *)color;

@end
