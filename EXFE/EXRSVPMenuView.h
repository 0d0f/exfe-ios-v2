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
@optional
- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPPendingMenuView:(EXRSVPMenuView *) menu;
- (void)RSVPRemoveMenuView:(EXRSVPMenuView *) menu;
@end


@interface EXRSVPMenuView : UIView{
    id <EXRSVPMenuDelegate>delegate;
}

@property (nonatomic,retain) Invitation *invitation;

- (id)initWithFrame:(CGRect)frame withDelegate:(id)_delegate items:(NSArray*)itemlist showTitleBar:(BOOL)showtitlebar;
- (void) setRsvpAccepted;
- (void) setRsvpUnavailable;
- (void) setRsvpPending;
- (void) setRsvpRemove;
- (BOOL) Itemscontain:(NSArray*)items string:(NSString*)item;
@end
