//
//  EFWarningHandlerCenter.h
//  EXFE
//
//  Created by 0day on 13-5-7.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

typedef enum {
    kEFWarningHandlerCenterTypeAlert = 0,
    kEFWarningHandlerCenterTypeBanner
} EFWarningHandlerCenterType;

@interface EFWarningHandlerCenter : NSObject
<
UIAlertViewDelegate
>

@property (nonatomic, assign) NSTimeInterval autoDismissTimeInterval;   // avaliable for banner only, default as 2.33 secs

+ (EFWarningHandlerCenter *)defaultCenter;

- (void)showWarningWithType:(EFWarningHandlerCenterType)type Title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancel otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end
