//
//  EXInvitationQuoteView.m
//  EXFE
//
//  Created by huoju on 8/18/12.
//
//

#import "EXInvitationQuoteView.h"

@implementation EXInvitationQuoteView
@synthesize invitation;
@synthesize Line1;
@synthesize Line2;
@synthesize Line3;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    NSString *rsvp_status=@"Pending";
    if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
        rsvp_status=@"Accepted";
    else if([invitation.rsvp_status isEqualToString:@"INTERESTED"])
        rsvp_status=@"Interested";
    else if([invitation.rsvp_status isEqualToString:@"DECLINED"])
        rsvp_status=@"Unavailable";
    
    NSString *mate=@"";
    if([invitation.mates intValue]>0)
    {
        mate=[mate stringByAppendingFormat:@" with %u mate.",[invitation.mates intValue]];
    }
    else
        rsvp_status=[rsvp_status stringByAppendingString:@"."];
    NSString *host=@"";
    if([invitation.host boolValue]==YES)
        host=@"Host. ";

//    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",host,rsvp_status,mate]];
//    [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14] range:NSMakeRange(0,[title length])];
//    [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0,[host length])];
//    [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0+[host length],[rsvp_status length])];
//    if([mate length]>10){
//        [title addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0+[host length]+[rsvp_status length],[mate length])];
//
//        [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0+[host length]+[rsvp_status length]+6,[[invitation.mates stringValue] length])];
//    }
//        
////    [title drawInRect:titlerect];
//    [title release];
    CGRect titlerect=CGRectMake(10, 3, 160, 16);
    if([mate length]>10){
        titlerect.size.width=162;
    }

    [Line1 drawInRect:titlerect];
    NSString *iconname=[NSString stringWithFormat:@"identity_%@_18.png",invitation.identity.provider];
    UIImage *icon=[UIImage imageNamed:iconname];
    [icon drawAtPoint:CGPointMake(11, 19)];
    NSString *identity_name=invitation.identity.external_username;
    if([invitation.identity.provider isEqualToString:@"twitter"])
        identity_name=[@"@" stringByAppendingString:identity_name];

    if(identity_name==nil)
        identity_name=invitation.identity.external_id;

    NSMutableAttributedString *identity_name_attributed = [[NSMutableAttributedString alloc] initWithString:identity_name];
    [identity_name_attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Italic" size:11] range:NSMakeRange(0,[identity_name length])];
    [identity_name_attributed addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_FA range:NSMakeRange(0,[identity_name length])];
    NSMutableAttributedString *temp=[identity_name_attributed mutableCopy];
    CGSize identity_name_size=[CTUtil CTSizeOfString:temp minLineHeight:15 linespacing:1 constraint:CGSizeMake(rect.size.width, 15)];
    [temp release];
    [identity_name_attributed drawInRect:CGRectMake(32, 19, identity_name_size.width, 15)];
    [identity_name_attributed release];

    NSString *by_name=invitation.by_identity.name;
    if(by_name==nil)
        by_name=invitation.by_identity.external_username;
    if(by_name==nil)
        by_name=invitation.by_identity.external_id;
    
    NSString *create_at_and_by=[NSString stringWithFormat:@"%@ by %@",[Util formattedDateRelativeToNow:invitation.created_at],by_name];
    NSMutableAttributedString *create_at_and_by_attributed = [[NSMutableAttributedString alloc] initWithString:create_at_and_by];
    [create_at_and_by_attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:11] range:NSMakeRange(0,[create_at_and_by_attributed length])];
    [create_at_and_by_attributed addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_FA range:NSMakeRange(0,[create_at_and_by_attributed length])];

    temp=[create_at_and_by_attributed mutableCopy];
    CGSize create_at_and_by_attributed_size=[CTUtil CTSizeOfString:temp minLineHeight:15 linespacing:1 constraint:CGSizeMake(350, 15)];
    [temp release];

    [create_at_and_by_attributed drawInRect:CGRectMake(rect.size.width-5-create_at_and_by_attributed_size.width, 19+16, create_at_and_by_attributed_size.width, 15)];
    
    [create_at_and_by_attributed release];
    
}

@end
