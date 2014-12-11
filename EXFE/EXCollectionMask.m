//
//  EXCollectionMask.m
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import "EXCollectionMask.h"

@implementation EXCollectionMask
@synthesize itemsCache;

@synthesize maxColumn;
@synthesize maxRow;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize nameHeight;
@synthesize imageXmargin;
@synthesize imageYmargin;
@synthesize hiddenAddButton;


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
    int x_count=0;
    int y_count=0;
    int count=[itemsCache count];
    if(itemsCache!=nil)
    {
        for (int i=0;i<[itemsCache count];i++)
        {
            if( x_count==maxColumn){
                x_count=0;
                y_count++;
            }
            int x=x_count*(imageWidth+imageXmargin*2)+imageXmargin;
            int y=y_count*(imageHeight+15+imageYmargin)+imageYmargin;
            EXInvitationItem *item=[itemsCache objectForKey:[NSNumber numberWithInt:i]];
            if(item.isHost==YES)
                [[UIImage imageNamed:@"exfee_frame.png"] drawInRect:CGRectMake(x-1, y-1, 42, 42)];
            if(item.mates>0)
            {
                [[UIImage imageNamed:@"exfee_frame_mates.png"] drawInRect:CGRectMake(x-3, y-3, 46, 44)];
            }
            if(item.isSelected==YES)
            {
                if([item.rsvp_status isEqualToString:@"ACCEPTED"])
                    [[UIImage imageNamed:@"rsvp_accept_badge.png"] drawInRect:CGRectMake(x-4, y-4, 52, 52)];
                else if([item.rsvp_status isEqualToString:@"INTERESTED"])
                    [[UIImage imageNamed:@"rsvp_interested_badge.png"] drawInRect:CGRectMake(x-4, y-4, 52, 52)];
                else if([item.rsvp_status isEqualToString:@"NORESPONSE"])
                    [[UIImage imageNamed:@"rsvp_pending_badge.png"] drawInRect:CGRectMake(x-4, y-4, 52, 52)];
                else if([item.rsvp_status isEqualToString:@"DECLINED"])
                    [[UIImage imageNamed:@"rsvp_unavailable_badge.png"] drawInRect:CGRectMake(x-4, y-4, 52, 52)];
            }
            x_count++;
        }
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
    }
    if(hiddenAddButton==NO)
        if(count<maxColumn*maxRow) {
            int x=x_count*(imageWidth+imageXmargin*2)+imageXmargin;
            int y=y_count*(imageHeight+imageYmargin+15)+imageYmargin;
            [[UIImage imageNamed:@"gather_add_exfee.png"] drawInRect:CGRectMake(x,y,140,40)];
        }
    // Drawing code
}

@end
