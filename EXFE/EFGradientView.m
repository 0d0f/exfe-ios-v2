//
//  EFGradientView.m
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import "EFGradientView.h"

@interface EFGradientView ()

@property (nonatomic, strong) NSMutableArray   *cgColors;

@end

@interface EFGradientView (Private)

- (void)_colorsDidChange;

@end

@implementation EFGradientView (Private)

- (void)_colorsDidChange {
    NSMutableArray *cgColors = [[NSMutableArray alloc] initWithCapacity:self.colors.count];
    for (UIColor *color in self.colors) {
        id cgColor = (id)color.CGColor;
        [cgColors addObject:cgColor];
    }
    
    self.cgColors = cgColors;
    [self setNeedsDisplay];
}

@end

@implementation EFGradientView

- (void)setColors:(NSArray *)colors {
    [self willChangeValueForKey:@"colors"];
    
    _colors = colors;
    [self _colorsDidChange];
    
    [self didChangeValueForKey:@"colors"];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = NULL;
    NSArray *colors = self.cgColors;
    CGFloat gradientLocations[] = {0, 1};
    gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, gradientLocations);
    
    CGContextDrawLinearGradient(context, gradient, (CGPoint){CGRectGetWidth(self.frame) * 0.5f, 0.0f}, (CGPoint){CGRectGetWidth(self.frame) * 0.5f, CGRectGetHeight(self.frame)}, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
