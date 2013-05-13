//
//  EFErrorMessage.m
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import "EFErrorMessage.h"

@implementation EFErrorMessage

+ (EFErrorMessage *)errorMessageWithStyle:(EFErrorMessageStyle)style title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonActionHandler:(EFErrorMessageActionBlock)handler {
    return [[[self alloc] initWithStyle:style title:title message:message buttonTitle:buttonTitle buttonActionHandler:handler] autorelease];
}

- (id)initWithStyle:(EFErrorMessageStyle)style title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonActionHandler:(EFErrorMessageActionBlock)handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.errorMessageStyle = style;
        self.buttonTitle = buttonTitle;
        self.actionHandler = handler;
    }
    
    return self;
}

- (void)dealloc {
    [_title release];
    [_message release];
    [_buttonTitle release];
    [super dealloc];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    EFErrorMessage *copy = [[EFErrorMessage alloc] initWithStyle:self.errorMessageStyle
                                                           title:self.title
                                                         message:self.message
                                                     buttonTitle:self.buttonTitle
                                             buttonActionHandler:self.actionHandler];
    return copy;
}

@end
