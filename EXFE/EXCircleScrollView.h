//
//  EXCircleScrollView.h
//  EXFE
//
//  Created by 0day on 13-4-1.
//
//

#import <UIKit/UIKit.h>

@class EXCircleScrollView;
@protocol EXCircleScrollViewDelegate <NSObject>
@optional
- (void)circleViewWillScroll:(EXCircleScrollView *)scrollView;
- (void)circleViewDidScroll:(EXCircleScrollView *)scrollView;
@end

@interface EXCircleScrollView : UIView
<
UIGestureRecognizerDelegate
> {
    id<EXCircleScrollViewDelegate> _delegate;
}

@property (nonatomic, assign) id<EXCircleScrollViewDelegate> delegate;
@property (nonatomic, assign, getter = isScrollEnable) BOOL scrollEnable;   // Default as YES.
@property (nonatomic, assign, getter = isPageEnable) BOOL pageEnable;   // Default as NO.

@property (nonatomic, assign) CGFloat pageHorizontalWidth;    // if pageEnabel == YES, this will work.
@property (nonatomic, assign) CGFloat contentHorizontalWidth;
@property (nonatomic, assign) CGFloat pageHorizontalOffset;

@property (nonatomic, retain) UIView *backgroundView;

- (void)setPageHorizontalOffset:(CGFloat)pageHorizontalOffset animated:(BOOL)animated completion:(void (^)(void))handler;

@end
