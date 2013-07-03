//
//  EFNotificationBannerView.h
//  EXFE
//
//  Created by 0day on 13-5-8.
//
//

#import <UIKit/UIKit.h>

@class EFNotificationBannerView;
@protocol EFNotificationBannerViewDelegate <NSObject>
@optional
- (void)notificationBannerViewDidDismiss:(EFNotificationBannerView *)view;
@end

@interface EFNotificationBannerView : UIView

@property (nonatomic, assign) NSTimeInterval autoDismissTimeInterval;   // when has button, default as -1; otherwise, 4.33 secs
@property (nonatomic, weak) id<EFNotificationBannerViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonPressedHandler:(void (^)(void))handler;

- (void)show;
- (void)dismiss;

@end
