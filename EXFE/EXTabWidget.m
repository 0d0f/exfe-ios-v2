//
//  EXTabWidget.m
//  EXFE
//
//  Created by Stony Wang on 13-3-1.
//
//

#import "EXTabWidget.h"
#import "Util.h"

#define kStageNormal 0
#define kStageSelect 1
#define kStageNotification 2


@implementation EXTabWidget

// TODO: under coding
- (id)initWithFrame:(CGRect)frame withItems:(NSArray*)items current:(NSInteger)index;
{
    self = [super initWithFrame:frame];
    if (self) {
        currentIndex = index;
        gravity = 1; // right to left
        _enable = YES;
        _stage = kStageNormal;
        // Initialization code
        CGRect frame = CGRectMake(0, 0, 50, 30);
        for (NSUInteger i = 0; i < items.count; i++) {
            EXTabWidgetItem *item = [items objectAtIndex:i];
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            
            btn.backgroundColor = [UIColor clearColor];
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            [btn setImage:item.image forState:UIControlStateNormal];
            if (item.highlightedImage) {
                [btn setImage:item.highlightedImage forState:UIControlStateApplication];
            }
            [btn addTarget:self action:@selector(widgetClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i + 1;
            
            if (i != currentIndex) {
                btn.hidden = YES;
            } else {
                CGPoint topleft = [self positionOfButton:0];
                btn.frame = CGRectOffset(frame, topleft.x, topleft.y);
            }
            [self addSubview:btn];
            total = btn.tag;
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withImages:(NSArray*)imgs current:(NSInteger)index;
{
    self = [super initWithFrame:frame];
    if (self) {
        currentIndex = index;
        gravity = 1; // right to left
        _enable = YES;
        _stage = kStageNormal;
        // Initialization code
        CGRect frame = CGRectMake(0, 0, 50, 30);
        for (NSUInteger i = 0; i < imgs.count; i++) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btn.backgroundColor = [UIColor clearColor];
            btn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            [btn setImage:[imgs objectAtIndex:i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(widgetClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i + 1;
            
            if (i != currentIndex) {
                CGPoint topleft = [self positionOfButton:-1];
                btn.frame = CGRectOffset(frame, topleft.x, topleft.y);
            } else {
                CGPoint topleft = [self positionOfButton:0];
                btn.frame = CGRectOffset(frame, topleft.x, topleft.y);
            }
            [self addSubview:btn];
            total = btn.tag;
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGPoint)positionOfButton:(NSUInteger)pos{
    if (gravity == 1){
        return CGPointMake(CGRectGetWidth(self.bounds) - (50) * (pos + 1) + + 2, 3);
    }
    return CGPointZero;
}

- (void)rereshUIwithCurrent:(NSUInteger)index hiddens:(NSArray*)array1 notifications:(NSArray*)array2{
    
}

- (void)switchTo:(NSUInteger)tag animated:(BOOL)animated
{
    if (animated) {
        // todo
    } else {
        if (currentIndex + 1 != tag) {
            _stage = kStageNormal;
            NSUInteger animCount = 0;
            for (UIView *view in self.subviews) {
                if (view.tag == tag) {
                    CGRect aStart = view.frame;
                    aStart.origin = [self positionOfButton:0];
                    view.frame = aStart;
                }else if (view.tag - 1 == currentIndex){
                    CGRect aStart = view.frame;
                    aStart.origin = [self positionOfButton:0 - total];
                    view.frame = aStart;
                }else{
                    animCount ++;
                    CGRect aStart = view.frame;
                    aStart.origin = [self positionOfButton:0 - animCount];
                    view.frame = aStart;
                }
            }
            currentIndex = tag - 1;
        }
    }
}

- (void)widgetClick:(id)sender{
    if (_enable == NO) {
        return;
    }
    
    UIButton* btn = sender;
    NSUInteger idx = btn.tag - 1;
//    NSLog(@"widget clicked: index %i when current is %i/%i", idx, currentIndex, total);
    if (idx == currentIndex) {
        if (_stage == kStageNormal) {
            _enable = NO;
            _stage = kStageSelect;
            if (self.delegate) {
                if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                    [self.delegate performSelector:@selector(updateLayout:animationWithParam:)
                                        withObject:self
                                        withObject:@{
                     @"width": @"98",
                     @"animationTime": [NSString stringWithFormat:@"%f", 0.2]}];
                }
            }
            
            NSUInteger animCount = 0;
            for (UIView *view in self.subviews) {
                if (view.tag - 1 != currentIndex) {
                    animCount ++;
                    CGRect aStart = view.frame;
                    aStart.origin = [self positionOfButton:0 - animCount];
                    view.frame = aStart;
                }
            }
            
            [UIView animateWithDuration:0.233
                             animations:^{
                                 // move hidden icon in
                                 NSUInteger count = 0;
                                 for (UIView *view in self.subviews) {
                                     if (view.tag - 1 != currentIndex) {
                                         count ++;
                                         CGRect aStart = view.frame;
                                         aStart.origin = [self positionOfButton:total - count];
                                         view.frame = aStart;
                                     }
                                 }
                             }
                             completion:^(BOOL finished){
                                 _enable = YES;
                             } ];
        } else {
            _enable = NO;
            _stage = kStageNormal;
            
            // move hidden icon in
            NSUInteger count = 0;
            for (UIView *view in self.subviews) {
                if (view.tag - 1 != currentIndex) {
                    count ++;
                    CGRect aStart = view.frame;
                    aStart.origin = [self positionOfButton:total - count];
                    view.frame = aStart;
                }
            }
            if (self.delegate) {
                if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                    [self.delegate performSelector:@selector(updateLayout:animationWithParam:)
                                        withObject:self
                                        withObject:@{
                     @"width": @"198",
                     @"animationTime": [NSString stringWithFormat:@"%f", 0.3]
                     }];
                }
            }
            
            [UIView animateWithDuration:0.233
                             animations:^{
                                 NSUInteger animCount = 0;
                                 for (UIView *view in self.subviews) {
                                     if (view.tag - 1 != currentIndex) {
                                         animCount ++;
                                         CGRect aStart = view.frame;
                                         aStart.origin = [self positionOfButton:0 - animCount];
                                         view.frame = aStart;
                                     }
                                 }
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 _enable = YES;
                             } ];
        }
    } else {
        if (_stage == kStageSelect) {
            _enable = NO;
            _stage = kStageNormal;
            [UIView animateWithDuration:0.233
                             animations:^{
                                 
                                 NSUInteger animCount = 0;
                                 for (UIView *view in self.subviews) {
                                     if (view.tag - 1 == idx) {
                                     }else if (view.tag - 1 == currentIndex){
                                         CGRect aStart = view.frame;
                                         aStart.origin = [self positionOfButton:0 - total];
                                         view.frame = aStart;
                                     }else{
                                         animCount ++;
                                         CGRect aStart = view.frame;
                                         aStart.origin = [self positionOfButton:0 - animCount];
                                         view.frame = aStart;
                                     }
                                 }
                                 currentIndex = idx;
                             }
                             completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.233 animations:^{
                                     
                                     CGRect aStart = btn.frame;
                                     aStart.origin = [self positionOfButton:0];
                                     btn.frame = aStart;
                                     
                                     if (self.delegate) {
                                         if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                                             NSDictionary * dict = @{@"width": @"198", @"animationTime": [NSString stringWithFormat:@"%f", 0.4]};
                                             [self.delegate performSelector:@selector(updateLayout:animationWithParam:) withObject:self withObject:dict];
                                         }
                                     }
                                 }
                                                  completion:^(BOOL finished){
                                                      _enable = YES;
                                                      if (self.delegate) {
                                                          if([self.delegate respondsToSelector:@selector(widgetClick:withButton:)]){
                                                              [self.delegate performSelector:@selector(widgetClick:withButton:) withObject:self withObject:sender];
                                                          }
                                                      }
                                                  }];
                             } ];
        }
    }
}


@end
