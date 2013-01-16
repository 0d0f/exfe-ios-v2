//
//  EXWidgetTabBar.h
//  EXFE
//
//  Created by Stony Wang on 13-1-16.
//
//

#import <UIKit/UIKit.h>

@interface EXWidgetTabBar : UIView<UIGestureRecognizerDelegate>{
    
    NSArray * widgets;
    id tar;
    SEL act;
}

@property (nonatomic, retain) NSArray* widgets;

- (void)addTarget:(id)target action:(SEL)action;
- (void)clearDelegate;


@end
