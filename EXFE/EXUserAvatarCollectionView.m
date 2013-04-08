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

#define kPageWidth          floor(CGRectGetWidth([UIScreen mainScreen].bounds) * 0.25f)
#define kMaxNumberOfCells   (12)

#pragma mark - EXUserAvatarCollectionViewBackgroundView
@interface EXUserAvatarCollectionViewBackgroundView : UIView
@end

@implementation EXUserAvatarCollectionViewBackgroundView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGFloat lengths[2];
    lengths[0] = 1;
    lengths[1] = 1;
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

@end

#pragma mark - EXUserAvatarCollectionView
@interface EXUserAvatarCollectionView (Private)
- (NSArray *)_circleCenterPositions;

- (BOOL)_isCircleItemCellExistAtIndexPath:(NSIndexPath *)indexPath;
- (void)_addCircleItemCellAtIndexPath:(NSIndexPath *)indexPath;
- (void)_removeCircleItemCell:(EXCircleItemCell *)cell;
- (CGPoint)_positionForIndexPath:(NSIndexPath *)indexPath alpha:(CGFloat *)alpha;

- (void)_reloadFlags;
- (void)_layoutCells;
@end

@implementation EXUserAvatarCollectionView {
    NSMutableSet *_visibleCells;
    NSMutableSet *_reusebaleCells;
    
    NSArray *_cellCenterPositions;
    CGFloat _horizontalOffset;
    
    id<UserAvatarCollectionDelegate> _outsideDelegate;
    
    struct {
        NSUInteger numberOfCells;
    }_flags;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _cellCenterPositions = [[self _circleCenterPositions] retain];
        _visibleCells = [[NSMutableSet alloc] initWithCapacity:kMaxNumberOfCells];
        _reusebaleCells = [[NSMutableSet alloc] init];
        
        // bg Color
        UIImage *bgColorImage = [UIImage imageNamed:@"home_bg.png"];
        if ([bgColorImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            bgColorImage = [bgColorImage resizableImageWithCapInsets:(UIEdgeInsets){20, 1, 20, 1}];
        } else {
            bgColorImage = [bgColorImage stretchableImageWithLeftCapWidth:1 topCapHeight:20];
        }
        
        self.backgroundView = [[[EXUserAvatarCollectionViewBackgroundView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:bgColorImage];//[UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];
        
        self.pageHorizontalWidth = floor(CGRectGetWidth(frame) * 0.125f);
        
        _delegate = self;
    }
    
    return self;
}

- (void)dealloc {
    [_visibleCells release];
    [_reusebaleCells release];
    [_cellCenterPositions release];
    [super dealloc];
}

#pragma mark - Getter && Setter
- (void)setDelegate:(id<UserAvatarCollectionDelegate>)delegate {
    if (delegate == _outsideDelegate)
        return;
    _outsideDelegate = delegate;
}

- (id<UserAvatarCollectionDelegate>)delegate {
    return _outsideDelegate;
}

#pragma mark - EXCircleScrollViewDelegate
- (void)circleViewWillScroll:(EXCircleScrollView *)scrollView {
    if ([_outsideDelegate respondsToSelector:@selector(circleViewWillScroll:)]) {
        [_outsideDelegate circleViewWillScroll:self];
    }
}

- (void)circleViewDidScroll:(EXCircleScrollView *)scrollView {
    CGFloat offset = scrollView.pageHorizontalOffset;
    EXCircleItemCell *meCell = [self circleItemCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGPoint meCellCenter = meCell.center;
    meCellCenter.x = CGRectGetMidX(self.frame) + 2 * offset;
    meCell.center = meCellCenter;
    
    [self _layoutCells];
    
    if ([_outsideDelegate respondsToSelector:@selector(circleViewDidScroll:)]) {
        [_outsideDelegate circleViewDidScroll:self];
    }
}

#pragma mark - Public
- (NSArray *)visibleCircleItemCells {
    NSArray *cells = [_visibleCells allObjects];
    cells = [cells sortedArrayUsingComparator:^(id obj1, id obj2){
        EXCircleItemCell *cell1 = (EXCircleItemCell *)obj1;
        EXCircleItemCell *cell2 = (EXCircleItemCell *)obj2;
        if (NSOrderedAscending == [cell1.indexPath compare:cell2.indexPath])
            return NSOrderedAscending;
        else if (NSOrderedDescending == [cell1.indexPath compare:cell2.indexPath])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    return cells;
}

- (void)reloadData {
    [self _reloadFlags];
    [self _layoutCells];
}

- (EXCircleItemCell *)circleItemCellAtIndexPath:(NSIndexPath *)indexPath {
    EXCircleItemCell *cell = nil;
    for (EXCircleItemCell *aCell in _visibleCells) {
        if (NSOrderedSame == [aCell.indexPath compare:indexPath]) {
            cell = aCell;
            break;
        }
    }
    
    return cell;
}

- (EXCircleItemCell *)dequeueReusableCircleItemCell {
    EXCircleItemCell *cell = [_reusebaleCells anyObject];
    if (cell) {
        [cell.avatarBaseView.layer removeAllAnimations];
        [cell.layer removeAllAnimations];
        cell.layer.transform = CATransform3DIdentity;
        cell.avatarBaseView.layer.transform = CATransform3DIdentity;
        cell.indexPath = nil;
        if (cell.superview) {
            [cell removeFromSuperview];
        }
        
        cell.avatarBaseView.alpha = 1.0f;
        cell.titleLabel.alpha = 1.0f;
    }
    
    return cell;
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
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:4];
    
    // [0, 0]
    NSMutableArray *ring0Positions = [[NSMutableArray alloc] initWithCapacity:1];
    CGPoint point00 = (CGPoint){floor(width * 0.5f), floor(height * 0.88f) - y};
    [ring0Positions addObject:[NSValue valueWithCGPoint:point00]];
    [temp addObject:ring0Positions];
    [ring0Positions release];
    
    // [1, 0] ~ [1, 4]
    NSMutableArray *ring1Positions = [[NSMutableArray alloc] initWithCapacity:5];
    
    CGPoint point10 = (CGPoint){0, floor(height * 0.66f) + 100.0f - y};
    [ring1Positions addObject:[NSValue valueWithCGPoint:point10]];
    
    CGPoint point11 = (CGPoint){floor(width * 0.25f) - 5.0f, floor(height * 0.66f) + 30.0f - y};
    [ring1Positions addObject:[NSValue valueWithCGPoint:point11]];
    
    CGPoint point12 = (CGPoint){floor(width * 0.5f), floor(height * 0.66f) - y};
    [ring1Positions addObject:[NSValue valueWithCGPoint:point12]];
    
    CGPoint point13 = (CGPoint){floor(width * 0.75f) + 5.0f, floor(height * 0.66f) + 30.0f - y};
    [ring1Positions addObject:[NSValue valueWithCGPoint:point13]];
    
    CGPoint point14 = (CGPoint){width, floor(height * 0.66f) + 100.0f - y};
    [ring1Positions addObject:[NSValue valueWithCGPoint:point14]];
    
    [temp addObject:ring1Positions];
    [ring1Positions release];
    
    
    // [2, 0] ~ [2, 5]
    NSMutableArray *ring2Positions = [[NSMutableArray alloc] initWithCapacity:6];
    
    CGPoint point20 = (CGPoint){-floor(width * 0.125f) + 10.0f, floor(height * 0.44f) + 80.0f - y};
    [ring2Positions addObject:[NSValue valueWithCGPoint:point20]];
    
    CGPoint point21 = (CGPoint){floor(width * 0.125f) + 5.0f, floor(height * 0.44f) + 40.0f - y};
    [ring2Positions addObject:[NSValue valueWithCGPoint:point21]];
    
    CGPoint point22 = (CGPoint){floor(width * 0.375f), floor(height * 0.44f) - y};
    [ring2Positions addObject:[NSValue valueWithCGPoint:point22]];
    
    CGPoint point23 = (CGPoint){floor(width * 0.625f), floor(height * 0.44f) - y};
    [ring2Positions addObject:[NSValue valueWithCGPoint:point23]];
    
    CGPoint point24 = (CGPoint){floor(width * 0.875f) - 5.0f, floor(height * 0.44f) + 40.0f - y};
    [ring2Positions addObject:[NSValue valueWithCGPoint:point24]];
    
    CGPoint point25 = (CGPoint){floor(width * 1.125f) - 10.0f, floor(height * 0.44f) + 80.0f - y};
    [ring2Positions addObject:[NSValue valueWithCGPoint:point25]];
    
    [temp addObject:ring2Positions];
    [ring2Positions release];
    
    // [3, 0] ~ [3, 5]
    NSMutableArray *ring3Positions = [[NSMutableArray alloc] initWithCapacity:6];
    
    CGPoint point30 = (CGPoint){-floor(width * 0.125f), floor(height * 0.22f) + 80.0f - y};
    [ring3Positions addObject:[NSValue valueWithCGPoint:point30]];
    
    CGPoint point31 = (CGPoint){floor(width * 0.125f), floor(height * 0.22f) + 40.0f - y};
    [ring3Positions addObject:[NSValue valueWithCGPoint:point31]];
    
    CGPoint point32 = (CGPoint){floor(width * 0.375f), floor(height * 0.22f) - y};
    [ring3Positions addObject:[NSValue valueWithCGPoint:point32]];
    
    CGPoint point33 = (CGPoint){floor(width * 0.625f), floor(height * 0.22f) - y};
    [ring3Positions addObject:[NSValue valueWithCGPoint:point33]];
    
    CGPoint point34 = (CGPoint){floor(width * 0.875f), floor(height * 0.22f) + 40.0f - y};
    [ring3Positions addObject:[NSValue valueWithCGPoint:point34]];
    
    CGPoint point35 = (CGPoint){floor(width * 1.125f), floor(height * 0.22f) + 80.0f - y};
    [ring3Positions addObject:[NSValue valueWithCGPoint:point35]];
    
    [temp addObject:ring3Positions];
    [ring3Positions release];
    
    NSArray *result = [[temp copy] autorelease];
    [temp release];
    
    return result;
}

- (void)_layoutCells {
    // remove useless
    for (EXCircleItemCell *cell in _visibleCells) {
        if ([self.dataSource shouldCircleItemCell:cell removeFromAvatarCollectionView:self]) {
            [self _removeCircleItemCell:cell];
        }
    }
    [_visibleCells minusSet:_reusebaleCells];
    
    [self.dataSource reloadCircleItemCells:_visibleCells];
    
    // add new
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if (![self _isCircleItemCellExistAtIndexPath:indexPath]) {
        [self _addCircleItemCellAtIndexPath:indexPath];
        [_reusebaleCells minusSet:_visibleCells];
    }
    
    NSUInteger count = (_flags.numberOfCells > 12) ? 12 : _flags.numberOfCells;
    NSUInteger numberOfNewCellToAdd = count - [_visibleCells count];
    
    int remainCount = 0;
    int ring = 1;
    int index = 1;
    int ringSize[] = {1, 3, 4, 4};
    while (remainCount < numberOfNewCellToAdd) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:ring];
        if (![self _isCircleItemCellExistAtIndexPath:indexPath]) {
            [self _addCircleItemCellAtIndexPath:indexPath];
            [_reusebaleCells minusSet:_visibleCells];
            ++remainCount;
        }
        
        if (++index > ringSize[ring]) {
            ++ring;
            index = 1;
        }
    }
    
//    for (int i = 0; i < 5; i++) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:1];
//        if (![self _isCircleItemCellExistAtIndexPath:indexPath]) {
//            [self _addCircleItemCellAtIndexPath:indexPath];
//        } else {
//            EXCircleItemCell *cell = [self circleItemCellAtIndexPath:indexPath];
//            CGFloat alpha = 1.0f;
//            cell.avatarCenter = [self _positionForIndexPath:indexPath alpha:&alpha];
//            cell.alpha = alpha;
//        }
//    }
//    
//    for (int i = 2; i < 4; i++) {
//        for (int j = 0; j < 6; j++) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
//            if (![self _isCircleItemCellExistAtIndexPath:indexPath]) {
//                [self _addCircleItemCellAtIndexPath:indexPath];
//            } else {
//                EXCircleItemCell *cell = [self circleItemCellAtIndexPath:indexPath];
//                CGFloat alpha = 1.0f;
//                cell.avatarCenter = [self _positionForIndexPath:indexPath alpha:&alpha];
//                cell.alpha = alpha;
//            }
//        }
//    }
}

- (BOOL)_isCircleItemCellExistAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isExist = NO;
    for (EXCircleItemCell *cell in _visibleCells) {
        if (NSOrderedSame == [cell.indexPath compare:indexPath]) {
            isExist = YES;
            break;
        }
    }
    
    return isExist;
}

- (void)_reloadFlags {
    CGRect viewBounds = self.bounds;
    _flags.numberOfCells = [self.dataSource numberOfCircleItemInAvatarCollectionView:self];
    self.pageHorizontalWidth = floor(CGRectGetWidth(viewBounds) * 0.125f);
    
    NSUInteger restCellNumber = ((_flags.numberOfCells - 1) % 11);
    NSUInteger numberOfPages = ((_flags.numberOfCells - 1) / 11) * 8;
    if (restCellNumber) {
        numberOfPages += restCellNumber / 3;
        numberOfPages += (restCellNumber % 3) ? 1 : 0;
    }
    self.contentHorizontalWidth = numberOfPages * self.pageHorizontalWidth;
}

- (void)_addCircleItemCellAtIndexPath:(NSIndexPath *)indexPath {
    EXCircleItemCell *cell = [_dataSource circleItemForAvatarCollectionView:self atIndexPath:indexPath];
    CGFloat alpha = 1.0f;
    cell.avatarCenter = [self _positionForIndexPath:indexPath alpha:&alpha];
    cell.alpha = alpha;
    cell.indexPath = indexPath;
    
    [_visibleCells addObject:cell];
    
    // block
    if (NSOrderedSame != [indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        cell.tapBlock = ^{
            [cell setSelected:!cell.isSelected animated:YES complete:nil];
            [self.delegate avatarCollectionView:self didSelectCircleItemAtIndexPath:cell.indexPath];
        };
    } else {
        cell.alpha = 1.0f;
        cell.tapBlock = ^{
            [self.delegate avatarCollectionView:self didSelectCircleItemAtIndexPath:cell.indexPath];
        };
    }
    
    cell.longPressBlock = ^{
        [self.delegate avatarCollectionView:self didLongPressCircleItemAtIndexPath:cell.indexPath];
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
                           [NSNumber numberWithFloat:0.7],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 0.3f;
    
    [cell.layer addAnimation:animation forKey:@"animation.pop"];
    
    [self addSubview:cell];
}

- (void)_removeCircleItemCell:(EXCircleItemCell *)cell {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
    CATransform3D scale2 = CATransform3DMakeScale(0.0, 0.0, 1);
    
    NSArray *frameValues = [NSArray arrayWithObjects:
                            [NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            nil];
    [animation setValues:frameValues];
    
    NSArray *frameTimes = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:0.5],
                           [NSNumber numberWithFloat:1.0],
                           nil];
    [animation setKeyTimes:frameTimes];
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.25f;
    
    [cell.avatarBaseView.layer addAnimation:animation forKey:nil];
    cell.indexPath = nil;
    [_reusebaleCells addObject:cell];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         cell.avatarBaseView.alpha = 0.5f;
                         cell.titleLabel.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [cell removeFromSuperview];
                         
                         cell.avatarBaseView.alpha = 1.0f;
                         cell.titleLabel.alpha = 1.0f;
                     }];
}

- (CGPoint)_positionForIndexPath:(NSIndexPath *)indexPath alpha:(CGFloat *)alpha {
    CGFloat pageWidth = self.pageHorizontalWidth;
    CGFloat offset = self.pageHorizontalOffset;
    
    NSInteger numberOfPastPages = (offset < 0) ? ceil(offset / pageWidth) : floor(offset / pageWidth);
    CGFloat pastPageWidth = numberOfPastPages * pageWidth;
    offset -= pastPageWidth;
    
    NSArray *positions = [_cellCenterPositions objectAtIndex:indexPath.section];
    NSInteger index = indexPath.row - numberOfPastPages;
    
    if (index < 0) {
        CGPoint originPosition = [positions[0] CGPointValue];
        originPosition.x += self.pageHorizontalOffset;
        return originPosition;
    }
    
    if (index >= [positions count]) {
        CGPoint originPosition = [[positions lastObject] CGPointValue];
        originPosition.x += self.pageHorizontalOffset;
        return originPosition;
    }
    
    CGPoint originPosition = [positions[index] CGPointValue];
    CGPoint resultPosition;
    
    *alpha = 1.0f;
    CGFloat percent = 1.0f;
    
    if (self.pageHorizontalOffset >= 0) {
        if (index == 0) {
            resultPosition = originPosition;
            percent = 0.0f;
        } else if (index == [positions count] - 1) {
            CGPoint preOriginPosition = [positions[index - 1] CGPointValue];
            CGFloat factor = (originPosition.x - preOriginPosition.x) / pageWidth;
            resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y - (originPosition.y - preOriginPosition.y) / (originPosition.x - preOriginPosition.x) * offset * factor};
            percent = (offset * factor) / (originPosition.x - preOriginPosition.x);
        } else {
            CGPoint preOriginPosition = [positions[index - 1] CGPointValue];
            CGFloat factor = (originPosition.x - preOriginPosition.x) / pageWidth;
            if (preOriginPosition.y < originPosition.y) {
                resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y - (originPosition.y - preOriginPosition.y) / (originPosition.x - preOriginPosition.x) * offset * factor};
            } else if (preOriginPosition.y > originPosition.y) {
                resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y + (preOriginPosition.y - originPosition.y) / (originPosition.x - preOriginPosition.x) * offset * factor};
            } else {
                resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y};
            }
        }
        
        resultPosition.x += self.pageHorizontalOffset;
    } else {
        if (index == 0) {
            CGPoint forwardOriginPosition = [positions[index + 1] CGPointValue];
            CGFloat factor = (forwardOriginPosition.x - originPosition.x) / pageWidth;
            resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y + (originPosition.y - forwardOriginPosition.y) / (forwardOriginPosition.x - originPosition.x) * offset * factor};
            percent = (offset * factor) / (forwardOriginPosition.x - originPosition.x);
        } else if (index == [positions count] - 1) {
            resultPosition = originPosition;
            percent = 0.0f;
        } else {
            CGPoint forwardOriginPosition = [positions[index + 1] CGPointValue];
            CGFloat factor = (forwardOriginPosition.x - originPosition.x) / pageWidth;
            if (forwardOriginPosition.y < originPosition.y) {
                resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y + (originPosition.y - forwardOriginPosition.y) / (forwardOriginPosition.x - originPosition.x) * offset * factor};
            } else if (forwardOriginPosition.y > originPosition.y) {
                resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y - (forwardOriginPosition.y - originPosition.y) / (forwardOriginPosition.x - originPosition.x) * offset * factor};
            } else {
                resultPosition = (CGPoint){originPosition.x - offset * factor, originPosition.y};
            }
        }
        
        resultPosition.x += self.pageHorizontalOffset;
    }
    
    *alpha *= fabs(percent);
    
    return resultPosition;
}

@end
