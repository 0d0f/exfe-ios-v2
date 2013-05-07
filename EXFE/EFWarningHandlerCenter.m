//
//  EFWarningHandlerCenter.m
//  EXFE
//
//  Created by 0day on 13-5-7.
//
//

#import "EFWarningHandlerCenter.h"

#define kDefaultAutoDismissTimeInterval     (2.33f)

@implementation EFWarningHandlerCenter

#pragma mark - Memory

+ (EFWarningHandlerCenter *)defaultCenter {
    static EFWarningHandlerCenter *StaticCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        StaticCenter = [[self alloc] init];
    });
    
    return StaticCenter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.autoDismissTimeInterval = kDefaultAutoDismissTimeInterval;
    }
    
    return self;
}

#pragma mark - Public

- (void)showWarningWithType:(EFWarningHandlerCenterType)type Title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancel otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case kEFWarningHandlerCenterTypeAlert:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:self
                                                          cancelButtonTitle:cancel
                                                          otherButtonTitles:otherButtonTitles, nil];
                [alertView show];
                [alertView release];
            }
                break;
            case kEFWarningHandlerCenterTypeBanner:
                break;
            default:
                break;
        }
    });
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {}
- (void)alertViewCancel:(UIAlertView *)alertView {}
- (void)willPresentAlertView:(UIAlertView *)alertView {}
- (void)didPresentAlertView:(UIAlertView *)alertView {}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    return YES;
}

@end
