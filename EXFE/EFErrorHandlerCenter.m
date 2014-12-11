//
//  EFErrorHandlerCenter.m
//  EXFE
//
//  Created by 0day on 13-5-7.
//
//

#import "EFErrorHandlerCenter.h"

@interface EFErrorHandlerCenter ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableArray *errorQueue;
@property (nonatomic, copy) EFErrorMessage *presentingErrorMessage;
@end

@interface EFErrorHandlerCenter (Private)
- (void)_enqueueErrorMessage:(EFErrorMessage *)errorMessage;
- (EFErrorMessage *)_dequeueAnErrorMessage;
- (void)_removeAllErrorMessages;
- (void)_showErrorMessage:(EFErrorMessage *)errorMessage;
- (void)_showNextErrorMessage;
@end

@implementation EFErrorHandlerCenter

#pragma mark - Memory

+ (EFErrorHandlerCenter *)defaultCenter {
    static EFErrorHandlerCenter *StaticCenter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        StaticCenter = [[self alloc] init];
    });
    
    return StaticCenter;
}

- (id)init {
    self = [super init];
    if (self) {
        _errorQueue = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - Public

- (void)presentErrorMessage:(EFErrorMessage *)errorMessage {
    [self _enqueueErrorMessage:errorMessage];
}

- (void)cancelAllErrorMessages {
    [self _removeAllErrorMessages];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self _showNextErrorMessage];
}

#pragma mark - EFNotificationBannerViewDelegate

- (void)notificationBannerViewDidDismiss:(EFNotificationBannerView *)view {
    [self _showNextErrorMessage];
}

#pragma mark - Private

- (void)_enqueueErrorMessage:(EFErrorMessage *)errorMessage {
    [_errorQueue addObject:errorMessage];
    [self _showErrorMessage:errorMessage];
}

- (EFErrorMessage *)_dequeueAnErrorMessage {
    if ([_errorQueue count]) {
        return _errorQueue[0];
    }
    
    return nil;
}

- (void)_showErrorMessage:(EFErrorMessage *)errorMessage {
    if (!_presentingErrorMessage) {
        self.presentingErrorMessage = errorMessage;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (errorMessage.errorMessageStyle) {
                case kEFErrorMessageStyleAlert:
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorMessage.title
                                                                        message:errorMessage.message
                                                                       delegate:self
                                                              cancelButtonTitle:errorMessage.buttonTitle
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                    break;
                case kEFErrorMessageStyleBanner:
                {
                    EFNotificationBannerView *bannerView = [[EFNotificationBannerView alloc] initWithTitle:errorMessage.title
                                                                                                   message:errorMessage.message
                                                                                      bannerPressedHandler:errorMessage.bannerPressedHandler
                                                                                      buttonPressedHandler:errorMessage.buttonPressedHandler
                                                                                                 needRetry:errorMessage.needRetry];
                    bannerView.delegate = self;
                    [bannerView show];
                }
                    break;
                default:
                    break;
            }
            [_errorQueue removeObject:errorMessage];
        });
    }
}

- (void)_showNextErrorMessage {
    if (_presentingErrorMessage) {
        _presentingErrorMessage = nil;
    }
    EFErrorMessage *errorMessage = [self _dequeueAnErrorMessage];
    if (errorMessage) {
        [self _showErrorMessage:errorMessage];
    }
}

- (void)_removeAllErrorMessages {
    [_errorQueue removeAllObjects];
}

@end
