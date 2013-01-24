//
//  EXWidgetTabBar.h
//  EXFE
//
//  Created by Stony Wang on 13-1-16.
//
//

#import <UIKit/UIKit.h>

@interface EXWidgetTabBar : UIView<UIGestureRecognizerDelegate>{
    CGRect CurveFrame;
    NSArray * widgets;
    NSArray * contents;
    id tar;
    SEL act;
}

@property (nonatomic, retain) NSArray* widgets;
@property (nonatomic, retain) NSArray* contents;
@property (nonatomic) CGRect CurveFrame;

- (id)initWithFrame:(CGRect)frame withCurveFrame:(CGRect)curveFrame;

- (void)addTarget:(id)target action:(SEL)action;
- (void)clearDelegate;


@end
