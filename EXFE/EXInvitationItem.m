//
//  EXImagesItem.m
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import "EXInvitationItem.h"

#import <CoreText/CoreText.h>
#import "UIImage+RoundedCorner.h"
#import "Util.h"

@implementation EXInvitationItem
@synthesize avatar;
@synthesize isHost;
@synthesize isSelected;
@synthesize mates;
@synthesize rsvp_status;
@synthesize isMe;
@synthesize isGather;
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
            self.backgroundColor=[UIColor colorWithRed:0xd2/255.0f green:0xe2/255.0f blue:0xf4/255.0f alpha:1];
        else
            self.backgroundColor=[UIColor clearColor];

    }
    return self;
    
}

- (void)drawRect:(CGRect)rect
{
    //AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    CGRect imagerect=rect;
    imagerect.size.height=rect.size.height-15;
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        CGContextTranslateCTM(currentContext, 0, self.bounds.size.height);
        CGContextScaleCTM(currentContext, 1.0, -1.0);

        if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
            CGImageRef ximageref = CGImageRetain(avatar.CGImage);
            CGContextDrawImage(currentContext,CGRectMake(5, 5, rect.size.width-10, rect.size.height-10) , ximageref);
            CGImageRelease(ximageref);
            if(isMe){
                NSString *portrait_frame=@"portrait_circle.png";
                if([invitation.rsvp_status isEqualToString:@"ACCEPTED"]&& !isGather)
                    portrait_frame=@"portrait_circle_accepted.png";
                CGImageRef frameimageref = CGImageRetain([UIImage imageNamed:portrait_frame].CGImage);
                CGContextDrawImage(currentContext,CGRectMake(5, 5, rect.size.width-10, rect.size.height-10) , frameimageref);
                CGImageRelease(frameimageref);
                
            }

            if(isMe && !isGather){
                UIImage *rsvpicon = nil;
                if ([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                    rsvpicon=[UIImage imageNamed:@"rsvp_accepted_stroke_26blue.png"];
                else if ([invitation.rsvp_status isEqualToString:@"DECLINED"])
                    rsvpicon=[UIImage imageNamed:@"rsvp_unavailable_stroke_26g5.png"];
                else
                    rsvpicon=[UIImage imageNamed:@"rsvp_pending_stroke_26g5.png"];
                
                if (rsvpicon != nil){
                    CGImageRef ximageref = CGImageRetain(rsvpicon.CGImage);
                    CGContextDrawImage(currentContext,CGRectMake(rect.size.width-26, 0, 26,26   ) , ximageref);
                    CGImageRelease(ximageref);
                }
            }

        }
        if(!isMe){
            NSString *portrait_frame=@"portrait_frame_50.png";
            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                portrait_frame=@"portrait_frame_accepted_50.png";
            CGImageRef frameimageref = CGImageRetain([UIImage imageNamed:portrait_frame].CGImage);
            CGContextDrawImage(currentContext,CGRectMake(5, 5, rect.size.width-10, rect.size.height-10) , frameimageref);
            CGImageRelease(frameimageref);
        }

    if([invitation.mates intValue]>0){
        if(!isMe){

        CGImageRef triimageref = CGImageRetain([UIImage imageNamed:@"portrait_tri.png"].CGImage);
        CGContextDrawImage(currentContext,CGRectMake(rect.size.width-13-5, rect.size.height-5-13, 13, 13) , triimageref);
        CGImageRelease(triimageref);
        }else{
            CGImageRef triimageref = CGImageRetain([UIImage imageNamed:@"portrait_circle_tri.png"].CGImage);
            CGContextDrawImage(currentContext,CGRectMake(5, 5, rect.size.width-10, rect.size.height-10) , triimageref);
            CGImageRelease(triimageref);
        }
        
        CTFontRef matesfontref= CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 9.0, NULL);

        NSMutableAttributedString *matesattribstring=[[NSMutableAttributedString alloc] initWithString:[invitation.mates stringValue]];
        [matesattribstring addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)matesfontref range:NSMakeRange(0,[matesattribstring length])];
        [matesattribstring addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0,[matesattribstring length])];
        
        CTTextAlignment alignment = kCTCenterTextAlignment;
        CTParagraphStyleSetting setting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
        };
        CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(setting, 1);
        [matesattribstring addAttribute:(id)kCTParagraphStyleAttributeName value:(__bridge id)paragraphstyle range:NSMakeRange(0,[matesattribstring length])];
        CFRelease(paragraphstyle);
        
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)matesattribstring);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(rect.size.width-14, rect.size.height-3-13.5, 13, 13));
        CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [matesattribstring length]), path, NULL);
        CFRelease(framesetter);
        CFRelease(path);
        CFRelease(matesfontref);
        CTFrameDraw(theFrame, currentContext);
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
            [name drawInRect:CGRectMake(5, rect.size.height-5-15+2, rect.size.width-10, 15) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
        }
    }
    
    if([invitation.identity.unreachable boolValue]==YES){
        CGContextTranslateCTM(currentContext, 0, self.bounds.size.height);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        CGImageRef frameimageref = CGImageRetain([UIImage imageNamed:@"portrait_exclaim.png"].CGImage);
        CGContextDrawImage(currentContext,CGRectMake(rect.size.width-20, 0, 20,20) , frameimageref);
        CGImageRelease(frameimageref);
    }
}

@end
