//
//  EXRSVPStatusView.h
//  EXFE
//
//  Created by huoju on 12/26/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Invitation.h"
#import "Identity.h"
#import "Util.h"

@interface EXRSVPStatusView : UIView{
    Invitation *invitation;
    UILabel *namelabel;
    UILabel *rsvplabel;
    UIImageView *rsvpbadge;

    id delegate;
}

@property (nonatomic,retain) Invitation *invitation;
- (id)initWithFrame:(CGRect)frame withDelegate:(id)_delegate;
- (void) showMenu;
//- (void) setDelegate:(id)_delegate;
@end
