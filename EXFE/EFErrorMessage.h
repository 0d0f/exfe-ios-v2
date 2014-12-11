//
//  EFErrorMessage.h
//  EXFE
//
//  Created by 0day on 13-5-13.
//
//

#import <Foundation/Foundation.h>

typedef void (^EFErrorMessageActionBlock)(void);
typedef enum {
    kEFErrorMessageStyleAlert = 0,
    kEFErrorMessageStyleBanner
} EFErrorMessageStyle;


@interface EFErrorMessage : NSObject
<
NSCopying
>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) EFErrorMessageStyle errorMessageStyle;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, copy) EFErrorMessageActionBlock bannerPressedHandler;
@property (nonatomic, copy) EFErrorMessageActionBlock buttonPressedHandler;
@property (nonatomic, assign) BOOL  needRetry;

- (id)initWithStyle:(EFErrorMessageStyle)style title:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle bannerPressedHandler:(EFErrorMessageActionBlock)bannerHandler buttonPressedHandler:(EFErrorMessageActionBlock)handler needRetry:(BOOL)needRetry;
- (id)initAlertMessageWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle buttonPressedHandler:(EFErrorMessageActionBlock)buttonPressedHandler;
- (id)initBannerMessageWithTitle:(NSString *)title message:(NSString *)message bannerPressedHandler:(EFErrorMessageActionBlock)bannerHandler buttonPressedHandler:(EFErrorMessageActionBlock)handler needRetry:(BOOL)needRetry;

@end
