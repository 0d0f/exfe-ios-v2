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

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",host,rsvp_status,mate]];

    //Accepted with 1 mate.
    
    [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14] range:NSMakeRange(0,[title length])];
    [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0,[host length])];
//    [title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14] range:NSMakeRange(0+[host length],[rsvp_status length])];
    [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0+[host length],[rsvp_status length])];
    if([mate length]>10){
        [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_FA range:NSMakeRange(0+[host length]+[rsvp_status length],[mate length])];

        [title addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0+[host length]+[rsvp_status length]+6,[[invitation.mates stringValue] length])];
    }
        
    CGRect titlerect=CGRectMake(10, 3, 160, 16);
    if([mate length]>10){
        titlerect.size.width=162;
    }
    [title drawInRect:titlerect];
    [title release];
}

@end
