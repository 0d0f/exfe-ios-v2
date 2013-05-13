//
//  EFErrorHandlerCenter.h
//  EXFE
//
//  Created by 0day on 13-5-7.
//
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>
#import "EFErrorMessage.h"
#import "EFNotificationBannerView.h"

@class EFErrorMessage;
@interface EFErrorHandlerCenter : NSObject
<
UIAlertViewDelegate,
EFNotificationBannerViewDelegate
>

+ (EFErrorHandlerCenter *)defaultCenter;
- (void)presentErrorMessage:(EFErrorMessage *)error;
- (void)cancelAllErrorMessages;

@end
