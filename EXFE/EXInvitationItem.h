//
//  EXImagesItem.h
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import <Foundation/Foundation.h>
#import "Invitation.h"
#import "Identity.h"
#import "UIImage+RoundedCorner.h"
#import "AppDelegate.h"
#import "Util.h"

@interface EXInvitationItem : UIView{
    Invitation *invitation;
    UIImage *avatar;
    BOOL isHost;
    BOOL isSelected;
    int mates;
    NSString *rsvp_status;
    BOOL isMe;
//    NSString *name;
}

@property (nonatomic,retain) UIImage *avatar;
@property BOOL isHost;
@property BOOL isSelected;
@property BOOL isMe;
@property int mates;
@property (nonatomic,retain) NSString *rsvp_status;
//@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) Invitation *invitation;

- (id)initWithInvitation:(Invitation*)_invitation;

@end
