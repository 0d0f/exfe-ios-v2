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

@class EXRSVPStatusView;


@protocol EXRSVPStatusViewDelegate <NSObject>

@required
- (void)RSVPStatusView:(EXRSVPStatusView*)view clickfor:(Invitation*)invitation;

@end

@interface EXRSVPStatusView : UIView{
    UILabel *namelabel;
    UILabel *rsvplabel;
    UIImageView *rsvpbadge;
    UIImageView *background;
}

@property (nonatomic, strong) Invitation *invitation;
@property (nonatomic, unsafe_unretained) id<EXRSVPStatusViewDelegate> delegate;
@property (nonatomic, strong) UIButton *next;

- (id)initWithFrame:(CGRect)frame;
@end
