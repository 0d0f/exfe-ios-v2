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

- (id)initWithFrame:(CGRect)frame withImages:(NSArray*)imgs;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        for (NSUInteger i = 0; i < imgs.count; i++) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
            [btn setImage:[imgs objectAtIndex:i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(widgetClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [self addSubview:btn];
        }
        
        currentIndex = 0;
        gravity = 1; // right to left
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
        return CGPointMake(5, CGRectGetWidth(self.bounds) - (30 + 8) * (idx));
    }
    return CGPointZero;
}

- (void)widgetClick:(id)sender{
    UIButton* btn = sender;
    NSUInteger idx = btn.tag;
    
    if (idx == currentIndex) {
        NSTimeInterval time = 0.2;
        if (self.delegate) {
            if([self.delegate respondsToSelector:@selector(updateLayout:animationWithParam:)]){
                NSDictionary * dict = [NSDictionary dictionaryWithKeysAndObjects:@"width", 100, @"animationTime", time nil];
                [self.delegate performSelector:@selector(updateLayout:animationWithParam:) withObject:self withObject:dict];
            }
        }
        
        
        UIButton * another = [buttons objectAtIndex:1 - idx];
        another.hidden = YES;
        CGRect aStart = another.frame;
        aStart.origin.x = CGRectGetWidth(self.bounds);
        aStart.origin.y = CGRectGetMinY(btn.frame);
        another.frame = aStart;
        
        [UIView animateWithDuration:0.233
                              delay:time
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             // move hidden icon in
                         }
                         completion:^(BOOL finished){
                            
                         } ];
        
        [UIView animateWithDuration:0.233
                              delay:time + 0.233
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             // move the current icon out
                             // move the hidden icon to the position 1
                         }
                         completion:^(BOOL finished){
                             if (self.delegate) {
                                 if([self.delegate respondsToSelector:@selector(widgetClick:withButton:)]){
                                     [self.delegate performSelector:@selector(widgetClick:withButton:) withObject:self withObject:sender];
                                 }
                             }
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
