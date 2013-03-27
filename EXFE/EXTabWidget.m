//
//  EXTabWidget.m
//  EXFE
//
//  Created by Stony Wang on 13-3-1.
//
//

#import "EXTabWidget.h"
#import "Util.h"

@implementation EXTabWidget

// TODO: under coding
- (id)initWithFrame:(CGRect)frame withItems:(NSArray*)items current:(NSInteger)index;
{
    self = [super initWithFrame:frame];
    if (self) {
        currentIndex = index;
        gravity = 1; // right to left
        _enable = YES;
        // Initialization code
        CGRect frame = CGRectMake(0, 0, 30, 30);
        for (NSUInteger i = 0; i < items.count; i++) {
            EXTabWidgetItem *item = [items objectAtIndex:i];
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            CGPoint topleft = [self positionOfButton:i];
            
            btn.backgroundColor = [UIColor clearColor];
            
            [btn setImage:item.image forState:UIControlStateNormal];
            if (item.highlightedImage) {
                [btn setImage:item.highlightedImage forState:UIControlStateApplication];
            }
            [btn addTarget:self action:@selector(widgetClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i + 1;
            
            btn.frame = CGRectOffset(frame, topleft.x, topleft.y);
            if (i != currentIndex) {
                btn.hidden = YES;
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
        // Initialization code
        CGRect frame = CGRectMake(0, 0, 30, 30);
        for (NSUInteger i = 0; i < imgs.count; i++) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            CGPoint topleft = [self positionOfButton:i];
            
            btn.backgroundColor = [UIColor clearColor];
            [btn setImage:[imgs objectAtIndex:i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(widgetClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i + 1;
            
            btn.frame = CGRectOffset(frame, topleft.x, topleft.y);
            if (i != currentIndex) {
                btn.hidden = YES;
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
        return CGPointMake(CGRectGetWidth(self.bounds) - (30 + 20) * (pos + 1) + 10, 3);
    }
    return CGPointZero;
}

- (void)rereshUIwithCurrent:(NSUInteger)index hiddens:(NSArray*)array1 notifications:(NSArray*)array2{
    
}

- (void)widgetClick:(id)sender{
    if (_enable == NO) {
        return;
    }
    
    UIButton* btn = sender;
    NSUInteger idx = btn.tag - 1;
    NSLog(@"widget clicked: index %i when current is %i/%i", idx, currentIndex, total);
    if (idx == currentIndex) {
        _enable = NO;
        if (self.delegate) {
            if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                NSDictionary * dict = @{@"width": @"98", @"animationTime": [NSString stringWithFormat:@"%f", 0.2]};
                [self.delegate performSelector:@selector(updateLayout:animationWithParam:) withObject:self withObject:dict];
            }
        }
        
        NSUInteger animCount = 0;
        for (UIView *view in self.subviews) {
            if (view.tag - 1 != currentIndex) {
                animCount ++;
                CGRect aStart = view.frame;
                aStart.origin = [self positionOfButton:0 - animCount];
                view.frame = aStart;
                view.hidden = NO;
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
                                     view.hidden = NO;
                                 }
                             }
                         }
                         completion:^(BOOL finished){
                             _enable = YES;
                             
                         } ];
    } else {
        _enable = NO;
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


@end
