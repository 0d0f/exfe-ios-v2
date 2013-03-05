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

- (id)initWithFrame:(CGRect)frame withImages:(NSArray*)imgs current:(NSInteger)index;
{
    self = [super initWithFrame:frame];
    if (self) {
        currentIndex = 0;
        gravity = 1; // right to left
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
        return CGPointMake(CGRectGetWidth(self.bounds) - (30 + 8) * (pos + 1), 5);
    }
    return CGPointZero;
}

- (void)rereshUIwithCurrent:(NSUInteger)index hiddens:(NSArray*)array1 notifications:(NSArray*)array2{
    
}

- (void)widgetClick:(id)sender{
    UIButton* btn = sender;
    NSUInteger idx = btn.tag - 1;
    
    if (idx == currentIndex) {
        NSTimeInterval time = 0.2;
        if (self.delegate) {
            if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                NSDictionary * dict = [NSDictionary dictionaryWithKeysAndObjects:@"width", @"239", @"animationTime", [NSString stringWithFormat:@"%f", time], nil];
                [self.delegate performSelector:@selector(updateLayout:animationWithParam:) withObject:self withObject:dict];
            }
        }
        
        CGPoint outofView = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetMinY(btn.frame));
        CGPoint target = [self positionOfButton:1];
        CGPoint last = [self positionOfButton:0];
        
        UIButton * another = (UIButton*)[self viewWithTag: 3 - btn.tag]; // tricks!!!
        //UIButton * another = [buttons objectAtIndex:1 - idx];
        CGRect aStart = another.frame;
        aStart.origin = outofView;
        //aStart.origin = target;
        another.frame = aStart;
        another.hidden = NO;
        
        //[self bringSubviewToFront:btn];
        
        [UIView animateWithDuration:0.233
                         animations:^{
                             // move hidden icon in
                             CGRect aNew = another.frame;
                             aNew.origin = target;
                             another.frame = aNew;
                         }
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.233
                                              animations:^{
                                                  CGRect aNew = another.frame;
                                                  aNew.origin = last;
                                                  another.frame = aNew;
                                                  
                                                  CGRect bOld = btn.frame;
                                                  bOld.origin = outofView;
                                                  btn.frame = bOld;
                                                  
                                                  currentIndex = another.tag - 1;
                                                  
                                                  if (self.delegate) {
                                                      if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                                                          NSDictionary * dict = [NSDictionary dictionaryWithKeysAndObjects:@"width", @"269", @"animationTime", [NSString stringWithFormat:@"%f", time + 0.2], nil];
                                                          [self.delegate performSelector:@selector(updateLayout:animationWithParam:) withObject:self withObject:dict];
                                                      }
                                                  }
                                              }
                                              completion:^(BOOL finished){
                                                  if (self.delegate) {
                                                      if([self.delegate respondsToSelector:@selector(widgetClick:withButton:)]){
                                                          [self.delegate performSelector:@selector(widgetClick:withButton:) withObject:self withObject:sender];
                                                      }
                                                  }
                                              } ];
                         } ];
        
       
        
       
        
    }
//    else{
//
//        switch (idx) {
//            case <#constant#>:
//                <#statements#>
//                break;
//                
//            default:
//                break;
//        }
//    }
}


@end
