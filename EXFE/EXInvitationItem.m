//
//  EXImagesItem.m
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import "EXInvitationItem.h"

@implementation EXInvitationItem
@synthesize avatar;
@synthesize isHost;
@synthesize isSelected;
@synthesize mates;
@synthesize rsvp_status;
@synthesize isMe;
//@synthesize name;
@synthesize invitation;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithInvitation:(Invitation*)_invitation{
    self = [super init];
    if (self) {
        self.invitation=_invitation;
        if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
            self.backgroundColor=[UIColor colorWithRed:58.0/255.0f green:110.0/255.0f blue:165.0/255.0f alpha:0.2];
        else
            self.backgroundColor=[UIColor clearColor];

    }
    return self;
    
}

- (void)drawRect:(CGRect)rect
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect imagerect=rect;
    imagerect.size.height=rect.size.height-15;
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imagerect cornerRadius:3];
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
//        CGContextBeginPath(currentContext);
//        CGContextAddPath(currentContext, maskPath.CGPath);
//        CGContextClosePath(currentContext);
//        CGContextClip(currentContext);
//    
        CGContextTranslateCTM(currentContext, 0, self.bounds.size.height);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
//        if(![self.rsvp_status isEqualToString:@"ACCEPTED"])
//            CGContextSetAlpha(currentContext, 0.50);

        if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
//            if(app.userid ==[invitation.identity.connected_user_id intValue]){
            if(isMe){
                avatar=[avatar roundedCornerImage:40 borderSize:0];
            }
            CGImageRef ximageref = CGImageRetain(avatar.CGImage);
            CGContextDrawImage(currentContext,CGRectMake(5, 5, rect.size.width-10, rect.size.height-10) , ximageref);
            CGImageRelease(ximageref);
            if(isMe){
                UIImage *rsvpicon;
                if ([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                    rsvpicon=[UIImage imageNamed:@"rsvp_accepted_stroke_26blue.png"];
                else if ([invitation.rsvp_status isEqualToString:@"INTERESTED"])
                    rsvpicon=[UIImage imageNamed:@"rsvp_pending_stroke_26g5.png"];
                else if ([invitation.rsvp_status isEqualToString:@"DECLINED"])
                    rsvpicon=[UIImage imageNamed:@"rsvp_unavailable_stroke_26g5.png"];
                
                CGImageRef ximageref = CGImageRetain(rsvpicon.CGImage);
                CGContextDrawImage(currentContext,CGRectMake(rect.size.width-26, 0, 26,26   ) , ximageref);
                CGImageRelease(ximageref);
            }

        }
    if(!isMe){
        NSString *portrait_frame=@"portrait_frame_50.png";
        if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
            portrait_frame=@"portrait_frame_accept_50.png";
            
        CGImageRef frameimageref = CGImageRetain([UIImage imageNamed:portrait_frame].CGImage);
        CGContextDrawImage(currentContext,CGRectMake(5, 5, rect.size.width-10, rect.size.height-10) , frameimageref);
        CGImageRelease(frameimageref);
    }
    if([invitation.identity.unreachable boolValue]==YES){
        CGImageRef frameimageref = CGImageRetain([UIImage imageNamed:@"exfee_unreachable.png"].CGImage);
        CGContextDrawImage(currentContext,CGRectMake(rect.size.width-20, 0, 20,20) , frameimageref);
        CGImageRelease(frameimageref);
        
    }
    

    if([invitation.mates intValue]>0){
        CGImageRef triimageref = CGImageRetain([UIImage imageNamed:@"portrait_tri_26"].CGImage);
        CGContextDrawImage(currentContext,CGRectMake(rect.size.width-13-5, rect.size.height-5-13, 13, 13) , triimageref);
        CGImageRelease(triimageref);
        
        CTFontRef matesfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 10.0, NULL);

        NSMutableAttributedString *matesattribstring=[[NSMutableAttributedString alloc] initWithString:[invitation.mates stringValue]];
        [matesattribstring addAttribute:(NSString*)kCTFontAttributeName value:(id)matesfontref range:NSMakeRange(0,[matesattribstring length])];
        [matesattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0,[matesattribstring length])];
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting setting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(setting, 1);
        [matesattribstring addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[matesattribstring length])];
        CFRelease(paragraphstyle);
        
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)matesattribstring);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(rect.size.width-13, rect.size.height-3-13, 13, 13));
        CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [matesattribstring length]), path, NULL);
        CFRelease(framesetter);
        CFRelease(path);
        CFRelease(matesfontref);
        CTFrameDraw(theFrame, currentContext);
        [matesattribstring release];
    }

    CGContextRestoreGState(currentContext);
    


    if(!isMe){
        NSString *name=invitation.identity.name;
        if(name==nil)
            name=invitation.identity.external_username;
        if(name==nil)
            name=invitation.identity.external_id;
        if(name!=nil){
            [[UIColor whiteColor] set];
            UIFont *font=[UIFont fontWithName:@"HelveticaNeue" size:11];
            [name drawInRect:CGRectMake(5, rect.size.height-5-15+2, rect.size.width-10, 15) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        }
    }
    


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
//    Identity *identity=self.invitation.identity;
//    NSString *name=identity.name;
//    if(name==nil)
//        name=identity.external_username;
//    if(name==nil)
//        name=identity.external_id;
//
//        if(name!=nil){
//            [[UIColor blackColor] set];
//            UIFont *font=[UIFont fontWithName:@"HelveticaNeue" size:11];
//            if(isSelected==YES)
//                font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
//
//                [name drawInRect:CGRectMake(rect.origin.x, rect.size.height-15, rect.size.width, 15) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
//
//        }
}

@end
