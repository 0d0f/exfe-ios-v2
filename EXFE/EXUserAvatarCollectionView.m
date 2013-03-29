//
//  UserAvatarCollection.m
//  EXFE
//
//  Created by huoju on 3/29/13.
//
//

#import "EXUserAvatarCollectionView.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

// 640 1036 1676
#define kRadius1 (160)
#define kRadius2 (259)
#define kRadius3 (419)

@interface EXUserAvatarCollectionView (Private)
- (NSArray *)_circleCenterPositions;
@end

@implementation EXUserAvatarCollectionView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
      _cellCenterPositions = [[self _circleCenterPositions] retain];
  }
  
  return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat lengths[2];
    lengths[0] = 1;
    lengths[1] = 2;
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 0.5f);
    CGContextSetLineDash(context, 0.0f, lengths, 2);
    
    CGPoint center = (CGPoint){0.5f * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)};
    CGContextSetRGBStrokeColor(context, 0xB2 / 255.0f, 0xB2 / 255.0f, 0xB2 / 255.0f, 1.0f);
    CGContextAddArc(
                    context,
                    center.x,
                    center.y,
                    kRadius1,
                    -M_PI_2,
                    M_PI + M_PI_2,
                    1);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextAddArc(
                    context,
                    center.x,
                    center.y,
                    kRadius2,
                    -M_PI_2,
                    M_PI + M_PI_2,
                    1);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextAddArc(
                    context,
                    center.x,
                    center.y,
                    kRadius3,
                    -M_PI_2,
                    M_PI + M_PI_2,
                    1);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextRestoreGState(context);
}

- (void)dealloc {
    [_cellCenterPositions release];
    [super dealloc];
}

- (void)reloadData {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[EXCircleItemCell class]])
            [view removeFromSuperview];
    }
    
    int count= [_dataSource numberOfCircleItemInAvatarCollectionView:self];
    for (int i = 0; i < count; i++) {
        EXCircleItemCell *cell = [_dataSource circleItemForAvatarCollectionView:self atIndex:i];
        cell.avatarCenter = [_cellCenterPositions[i] CGPointValue];
        
        // block
        if (i) {
            cell.tapBlock = ^{
                [cell setSelected:!cell.isSelected animated:YES complete:nil];
                [_delegate avatarCollectionView:self didSelectCircleItemAtIndex:cell.index];
            };
        } else {
            cell.tapBlock = ^{
                [_delegate avatarCollectionView:self didSelectCircleItemAtIndex:cell.index];
            };
        }
        
        
        cell.longPressBlock = ^{
            [_delegate avatarCollectionView:self didLongPressCircleItemAtIndex:cell.index];
        };
        
        // animation
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.3, 0.3, 1);
        CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
        CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);

        NSArray *frameValues = [NSArray arrayWithObjects:
                              [NSValue valueWithCATransform3D:scale1],
                              [NSValue valueWithCATransform3D:scale2],
                              [NSValue valueWithCATransform3D:scale3],
                              [NSValue valueWithCATransform3D:scale4],
                              nil];
        [animation setValues:frameValues];

        NSArray *frameTimes = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.5],
                             [NSNumber numberWithFloat:0.9],
                             [NSNumber numberWithFloat:1.0],
                             nil];
        [animation setKeyTimes:frameTimes];

        animation.fillMode = kCAFillModeForwards;
        animation.duration = .2;

        [cell.layer addAnimation:animation forKey:nil];

        [self addSubview:cell];
        [cell setNeedsDisplay];
    }
}

#pragma mark - Private
- (NSArray *)_circleCenterPositions {
    CGRect viewBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(viewBounds);
    CGFloat height = CGRectGetHeight(viewBounds);
    CGFloat y = self.frame.origin.y;
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        y += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    }
    
    NSValue *value = nil;
    NSMutableArray *tempPositions = [[NSMutableArray alloc] initWithCapacity:12];
    
    CGPoint point11 = (CGPoint){floor(width * 0.5f), floor(height * 0.88f) - y};
    value = [NSValue valueWithCGPoint:point11];
    [tempPositions addObject:value];
    
    CGPoint point21 = (CGPoint){floor(width * 0.25f) - 5.0f, floor(height * 0.66f) + 30.0f - y};
    value = [NSValue valueWithCGPoint:point21];
    [tempPositions addObject:value];
    
    CGPoint point22 = (CGPoint){floor(width * 0.5f), floor(height * 0.66f) - y};
    value = [NSValue valueWithCGPoint:point22];
    [tempPositions addObject:value];
    
    CGPoint point23 = (CGPoint){floor(width * 0.75f) + 5.0f, floor(height * 0.66f) + 30.0f - y};
    value = [NSValue valueWithCGPoint:point23];
    [tempPositions addObject:value];
    
    CGPoint point31 = (CGPoint){floor(width * 0.125f) + 5.0f, floor(height * 0.44f) + 40.0f - y};
    value = [NSValue valueWithCGPoint:point31];
    [tempPositions addObject:value];
    
    CGPoint point32 = (CGPoint){floor(width * 0.375f), floor(height * 0.44f) - y};
    value = [NSValue valueWithCGPoint:point32];
    [tempPositions addObject:value];
    
    CGPoint point33 = (CGPoint){floor(width * 0.625f), floor(height * 0.44f) - y};
    value = [NSValue valueWithCGPoint:point33];
    [tempPositions addObject:value];
    
    CGPoint point34 = (CGPoint){floor(width * 0.875f) - 5.0f, floor(height * 0.44f) + 40.0f - y};
    value = [NSValue valueWithCGPoint:point34];
    [tempPositions addObject:value];
    
    CGPoint point41 = (CGPoint){floor(width * 0.125f), floor(height * 0.22f) + 40.0f - y};
    value = [NSValue valueWithCGPoint:point41];
    [tempPositions addObject:value];
    
    CGPoint point42 = (CGPoint){floor(width * 0.375f), floor(height * 0.22f) - y};
    value = [NSValue valueWithCGPoint:point42];
    [tempPositions addObject:value];
    
    CGPoint point43 = (CGPoint){floor(width * 0.625f), floor(height * 0.22f) - y};
    value = [NSValue valueWithCGPoint:point43];
    [tempPositions addObject:value];
    
    CGPoint point44 = (CGPoint){floor(width * 0.875f), floor(height * 0.22f) + 40.0f - y};
    value = [NSValue valueWithCGPoint:point44];
    [tempPositions addObject:value];
    
    NSArray *result = [[tempPositions copy] autorelease];
    [tempPositions release];
    
    return result;
}

@end
