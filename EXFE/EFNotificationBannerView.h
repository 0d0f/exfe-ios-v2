//
//  EFNotificationBannerView.h
//  EXFE
//
//  Created by 0day on 13-5-8.
//
//

#import <UIKit/UIKit.h>

/**
 * @note You will NEVER use this class directly. This is private for you!
 */

@class EFNotificationBannerView;
@protocol EFNotificationBannerViewDelegate <NSObject>
@optional
- (void)notificationBannerViewDidDismiss:(EFNotificationBannerView *)view;
@end

@interface EFNotificationBannerView : UIView

@property (nonatomic, assign) NSTimeInterval autoDismissTimeInterval;   // when has button, default as -1; otherwise, 4.33 secs
@property (nonatomic, weak) id<EFNotificationBannerViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(void (^)(void))bannerHandler buttonPressedHandler:(void (^)(void))handler needRetry:(BOOL)needRetry;
- (id)initWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(void (^)(void))bannerHandler buttonPressedHandler:(void (^)(void))handler;  // retry
- (id)initWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(void (^)(void))bannerHandler;    // no retry


- (void)show;
- (void)dismiss;

@end
