//
//  ExfeeRsvpCell.h
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "TTTAttributedLabel.h"
#import "Invitation+EXFE.h"


@interface ExfeeRsvpCell : UITableViewCell{
    UILabel *invName;
    UIImageView *invHostFlag;
    UILabel *invHostText;
    UIImageView *invRsvpImage;
    TTTAttributedLabel *invRsvpLabel;
    UILabel *invRsvpAltLabel;
    
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, assign) BOOL unreachable;
@property (nonatomic, assign) RsvpCode rsvp;
@property (nonatomic, assign) NSInteger mates;
@property (nonatomic, copy) NSString *additionalText;

@end
