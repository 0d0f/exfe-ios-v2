//
//  EXRSVPMenuView.h
//  EXFE
//
//  Created by huoju on 12/27/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "Invitation.h"
#import "Identity.h"

@class EXRSVPMenuView;

@protocol EXRSVPMenuDelegate<NSObject>
@required
- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPPendinMenuView:(EXRSVPMenuView *) menu;
@end


@interface EXRSVPMenuView : UIView{
    Invitation *invitation;
    id <EXRSVPMenuDelegate>delegate;
}

@property (nonatomic,retain) Invitation *invitation;

- (id)initWithFrame:(CGRect)frame withDelegate:(id)_delegate;
- (void) setRsvpAccepted;
- (void) setRsvpUnavailable;
- (void) setRsvpPending;
@end
