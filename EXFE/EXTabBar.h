//
//  EXTabBar.h
//  EXFE
//
//  Created by Stony Wang on 13-1-24.
//
//

#import <UIKit/UIKit.h>

@interface EXTabBar : UIView<UIGestureRecognizerDelegate>{
    NSArray * widgets;
    NSArray * contents;
    id tar;
    SEL act;
}

@property (nonatomic, retain) NSArray* widgets;
@property (nonatomic, retain) NSArray* contents;

- (void)addTarget:(id)target action:(SEL)action;
- (void)clearDelegate;

@end
