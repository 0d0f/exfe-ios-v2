//
//  EFPopoverController.h
//  EXFE
//
//  Created by 0day on 13-4-4.
//
//

#import <Foundation/Foundation.h>

#import "EFArrowView.h"

@interface EFPopoverController : NSObject
<
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, assign) CGSize    contentSize;
@property (nonatomic, strong) EFArrowView   *backgroundArrowView;

- (id)initWithContentViewController:(UIViewController *)controller;

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view containRect:(CGRect)frame arrowDirection:(EFArrowDirection)direction animated:(BOOL)animated complete:(void (^)(void))handler;
- (void)dismissWithAnimated:(BOOL)animated complete:(void (^)(void))handler;

- (void)setContentSize:(CGSize)contentSize animated:(BOOL)animated;

@end
