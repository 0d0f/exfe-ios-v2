//
//  EFErrorHandlerCenter.m
//  EXFE
//
//  Created by 0day on 13-5-7.
//
//

#import "EFErrorHandlerCenter.h"

@interface EFErrorHandlerCenter ()
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *errorQueue;
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

- (void)dealloc {
    [_errorQueue release];
    [super dealloc];
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
                    [alertView release];
                }
                    break;
                case kEFErrorMessageStyleBanner:
                {
                    EFNotificationBannerView *bannerView = [[EFNotificationBannerView alloc] initWithTitle:errorMessage.title
                                                                                                   message:errorMessage.message
                                                                                               buttonTitle:errorMessage.buttonTitle
                                                                                      buttonPressedHandler:errorMessage.actionHandler];
                    bannerView.delegate = self;
                    [bannerView show];
                    [bannerView release];
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
    if (self.presentingErrorMessage.actionHandler) {
        self.presentingErrorMessage.actionHandler();
    }
    
    if (_presentingErrorMessage) {
        [_presentingErrorMessage release];
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
