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
#import <CoreText/CoreText.h>

@interface EXInvitationItem : UIView{
    Invitation *invitation;
    UIImage *avatar;
    BOOL isHost;
    BOOL isSelected;
    BOOL isGather;
    int mates;
    NSString *rsvp_status;
    BOOL isMe;
//    NSString *name;
}

@property (nonatomic,strong) UIImage *avatar;
@property BOOL isHost;
@property BOOL isSelected;
@property BOOL isMe;
@property BOOL isGather;
@property int mates;
@property (nonatomic,strong) NSString *rsvp_status;
//@property (nonatomic,retain) NSString *name;
@property (nonatomic,strong) Invitation *invitation;

- (id)initWithInvitation:(Invitation*)_invitation;

@end
