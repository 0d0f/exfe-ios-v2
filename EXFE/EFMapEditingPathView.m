//
//  EFMapEditingPathView.m
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapEditingPathView.h"
#import "EFMapColorButton.h"

@interface EFMapEditingPathView ()

@property (nonatomic, strong) NSArray           *colors;
@property (nonatomic, strong) NSMutableArray    *buttons;

@end

@implementation EFMapEditingPathView

- (void)_init {
    self.colors = @[[UIColor colorWithRed:0.0f green:(123.0f / 255.0f) blue:1.0f alpha:1.0f],
                    [UIColor colorWithRed:1.0f green:0.0f blue:(51.0f / 255.0f) alpha:1.0f],
                    [UIColor colorWithRed:0.0f green:(151.0f / 255.0f) blue:0.0f alpha:1.0f],
                    [UIColor colorWithRed:(204.0f / 255.0f) green:0.0f blue:1.0f alpha:1.0f],
                    [UIColor colorWithRed:(95.0f / 255.0f) green:(127.0f / 255.0f) blue:(127.0f / 255.0f) alpha:1.0f]];
    
    NSUInteger count = self.colors.count;
    CGRect viewFrame = self.frame;
    CGSize buttonSize = (CGSize){floor(CGRectGetWidth(viewFrame) / count), CGRectGetHeight(viewFrame)};
    
    self.buttons = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < self.colors.count; i++) {
        EFMapColorButton *button = [EFMapColorButton buttonWithColor:self.colors[i]];
        button.frame = (CGRect){{buttonSize.width * i, 0.0f}, buttonSize};
        [self addSubview:button];
        [self.buttons addObject:button];
    }
    
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    
    return self;
}

#pragma mark - Property Accessor

- (UIColor *)selectedColor {
    return [self colorAtIndex:self.selectedIndex];
}

- (void)setSelectedColor:(UIColor *)color {
    NSParameterAssert(color);
    
    [self willChangeValueForKey:@"selectedColor"];
    
    NSUInteger index = [self indexOfColor:color];
    NSAssert(index != NSNotFound, @"Must be in the color collection");
    
    self.selectedIndex = index;
    
    [self didChangeValueForKey:@"selectedColor"];
}

- (void)setSelectedIndex:(NSUInteger)index {
    NSParameterAssert(index != NSNotFound && index < self.colors.count);
    
    [self willChangeValueForKey:@"selectedIndex"];
    
    _selectedIndex = index;
    
    for (EFMapColorButton *button in self.buttons) {
        button.selected = NO;
    }
    
    ((EFMapColorButton *)self.buttons[index]).selected = YES;
    
    [self didChangeValueForKey:@"selectedIndex"];
}

- (UIColor *)colorAtIndex:(NSUInteger)index {
    NSParameterAssert(index != NSNotFound && index < self.colors.count);
    
    return self.colors[index];
}

- (NSUInteger)indexOfColor:(UIColor *)color {
    return [self.colors indexOfObject:color];
}

@end
