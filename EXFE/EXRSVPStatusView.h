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
    UIImageView *background;

}

@property (nonatomic, retain) Invitation *invitation;
@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, retain) UIButton *next;

- (id)initWithFrame:(CGRect)frame;


//- (void) showMenu;
@end
