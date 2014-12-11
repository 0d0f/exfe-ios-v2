//
//  EFErrorMessage.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFErrorMessage.h"

@implementation EFErrorMessage

- (id)initWithStyle:(EFErrorMessageStyle)style title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle bannerPressedHandler:(EFErrorMessageActionBlock)bannerHandler
buttonPressedHandler:(EFErrorMessageActionBlock)handler needRetry:(BOOL)needRetry {
    switch (style) {
        case kEFErrorMessageStyleBanner:
            return [[EFErrorMessage alloc] initBannerMessageWithTitle:title message:message bannerPressedHandler:bannerHandler buttonPressedHandler:handler needRetry:needRetry];
            break;
        case kEFErrorMessageStyleAlert:
            return [[EFErrorMessage alloc] initAlertMessageWithTitle:title message:message buttonTitle:buttonTitle buttonPressedHandler:handler];
            break;
        default:
            break;
    }
}

- (id)initAlertMessageWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonPressedHandler:(EFErrorMessageActionBlock)buttonPressedHandler {
    self = [super init];
    if (self) {
        self.errorMessageStyle = kEFErrorMessageStyleAlert;
        self.title = title;
        self.message = message;
        self.buttonTitle = buttonTitle;
        self.buttonPressedHandler = buttonPressedHandler;
    }
    
    return self;
}

- (id)initBannerMessageWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(EFErrorMessageActionBlock)bannerHandler buttonPressedHandler:(EFErrorMessageActionBlock)handler needRetry:(BOOL)needRetry {
    self = [super init];
    if (self) {
        self.errorMessageStyle = kEFErrorMessageStyleBanner;
        self.title = title;
        self.message = message;
        self.bannerPressedHandler = bannerHandler;
        self.buttonPressedHandler = handler;
        self.needRetry = needRetry;
    }
    
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    EFErrorMessage *copy = [[EFErrorMessage alloc] initWithStyle:self.errorMessageStyle
                                                           title:self.title
                                                         message:self.message
                                                     buttonTitle:self.buttonTitle
                                            bannerPressedHandler:self.bannerPressedHandler
                                            buttonPressedHandler:self.buttonPressedHandler
                                                       needRetry:self.needRetry];
    return copy;
}

@end
