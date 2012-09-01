//
//  EXImagesItem.m
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import "EXImagesItem.h"

@implementation EXImagesItem
@synthesize avatar;
@synthesize isHost;
@synthesize isSelected;
@synthesize mates;
@synthesize rsvp_status;
@synthesize name;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    CGRect imagerect=rect;
    imagerect.size.height=rect.size.height-15;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imagerect cornerRadius:3];
//
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        CGContextBeginPath(currentContext);
        CGContextAddPath(currentContext, maskPath.CGPath);
        CGContextClosePath(currentContext);
        CGContextClip(currentContext);
        if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
            [avatar drawInRect:imagerect];
        }

        [[UIImage imageNamed:@"avatar_effect.png"] drawInRect:imagerect];
        CGContextRestoreGState(currentContext);

//        if(self.isHost==YES)
//            [[UIImage imageNamed:@"exfee_frame.png"] drawInRect:CGRectMake(rect.origin.x-1, rect.origin.y-1, 42, 42)];
//        if(self.mates>0)
//        {
//            [[UIImage imageNamed:@"exfee_frame_mates.png"] drawInRect:CGRectMake(rect.origin.x-3, rect.origin.y-3, 46, 44)];
//        }
//        if(isSelected==YES)
//        {
//            if([self.rsvp_status isEqualToString:@"ACCEPTED"])
//                [[UIImage imageNamed:@"rsvp_accept_badge.png"] drawInRect:CGRectMake(rect.origin.x-4, rect.origin.y-4, 52, 52)];
//            else if([self.rsvp_status isEqualToString:@"INTERESTED"])
//                [[UIImage imageNamed:@"rsvp_interested_badge.png"] drawInRect:CGRectMake(rect.origin.x-4, rect.origin.y-4, 52, 52)];
//            else if([self.rsvp_status isEqualToString:@"NORESPONSE"])
//                [[UIImage imageNamed:@"rsvp_pending_badge.png"] drawInRect:CGRectMake(rect.origin.x-4, rect.origin.y-4, 52, 52)];
//            else if([self.rsvp_status isEqualToString:@"DECLINED"])
//                [[UIImage imageNamed:@"rsvp_unavailable_badge.png"] drawInRect:CGRectMake(rect.origin.x-4, rect.origin.y-4, 52, 52)];
//
//        }
        if(self.name!=nil){
            [[UIColor blackColor] set];
            UIFont *font=[UIFont fontWithName:@"HelveticaNeue" size:11];
            if(isSelected==YES)
                font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:11];

                [self.name drawInRect:CGRectMake(rect.origin.x, rect.size.height-15, rect.size.width, 15) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];

        }
}

@end
