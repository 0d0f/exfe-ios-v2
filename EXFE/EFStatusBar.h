//
//  EFStatusBar.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import <UIKit/UIKit.h>

@interface EFStatusBar : UIView

@property (nonatomic, readonly, copy) NSString *currentPresentedMessage;

+ (EFStatusBar *)defaultStatusBar;

- (void)presentMessage:(NSString *)message;
- (void)presentMessage:(NSString *)message withTextColor:(UIColor *)textColor backgroundColor:(UIColor *)bgColor;

- (void)dismiss;

@end
