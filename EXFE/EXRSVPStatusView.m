//
//  EXRSVPStatusView.m
//  EXFE
//
//  Created by huoju on 12/26/12.
//
//

#import "EXRSVPStatusView.h"

@implementation EXRSVPStatusView
@synthesize invitation;

- (id)initWithFrame:(CGRect)frame withDelegate:(id)_delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        delegate=_delegate;
        self.backgroundColor=[UIColor clearColor];
//        self.layer.shadowColor=[UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 1;
//        self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        
        background= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        background.image=[[UIImage imageNamed:@"x_exfee_tip.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9,9)];
        [self addSubview:background];
//        UIButton *next=[UIButton buttonWithType:UIButtonTypeCustom];
//        
//        [next setFrame:CGRectMake(165.0f, 7.0f, 10.0f, 30.0f)];
//        [next setBackgroundColor:[UIColor greenColor]];
//        [next addTarget:delegate action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:next];
        
        UIImageView *arrow=[[UIImageView alloc] initWithFrame:CGRectMake(165.0f, (frame.size.height-15)/2, 12, 15)];
        arrow.image=[UIImage imageNamed:@"arrow.png"];
//        [self addSubview:arrow];
        [arrow release];
        
        namelabel=[[UILabel alloc] initWithFrame:CGRectMake(16, 5, 155, 20)];
        [namelabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [namelabel setTextColor:FONT_COLOR_51];
        [namelabel setTextAlignment:NSTextAlignmentLeft];
        namelabel.backgroundColor=[UIColor clearColor];
        [self addSubview:namelabel];
        
        rsvpbadge=[[UIImageView alloc] initWithFrame:CGRectMake(16, 24, 18, 18)];
        [self addSubview:rsvpbadge];
        
        rsvplabel=[[UILabel alloc] initWithFrame:CGRectMake(16+18+5, 24, 180-10-18, 20)];
        [rsvplabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        [rsvplabel setTextColor:FONT_COLOR_HL];
        [rsvplabel setTextAlignment:NSTextAlignmentLeft];
        rsvplabel.backgroundColor=[UIColor clearColor];
        [self addSubview:rsvplabel];

        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
        [self addGestureRecognizer:gestureRecognizer];
        [gestureRecognizer release];

        
        // Initialization code
    }
    return self;
}

- (void) setDelegate:(id)_delegate{
    delegate=_delegate;
}

- (void) setInvitation:(Invitation *)_invitation{
    invitation=_invitation;
    namelabel.text=invitation.identity.name;
    [namelabel setNeedsDisplay];
    
    UIImage *rsvpicon=nil;
    NSString *rsvpstatustext=@"";
    if ([invitation.rsvp_status isEqualToString:@"ACCEPTED"]){
        rsvpicon=[UIImage imageNamed:@"rsvp_accepted_stroke_26blue.png"];
        rsvplabel.textColor=FONT_COLOR_HL;
        rsvpstatustext=@"Accepted";
    } else if ([invitation.rsvp_status isEqualToString:@"DECLINED"]){
        rsvpicon=[UIImage imageNamed:@"rsvp_unavailable_stroke_26g5.png"];
        rsvpstatustext=@"Unavailable";
        rsvplabel.textColor=FONT_COLOR_51;
    } else if ([invitation.rsvp_status isEqualToString:@"INTERESTED"]){
        rsvpicon=[UIImage imageNamed:@"rsvp_pending_stroke_26g5.png"];
        rsvpstatustext=@"Interested";
        rsvplabel.textColor=FONT_COLOR_51;
    } else{
        rsvpicon=[UIImage imageNamed:@"rsvp_pending_stroke_26g5.png"];
        rsvpstatustext=@"Pending";
        rsvplabel.textColor=FONT_COLOR_51;
    }
    
    if([invitation.identity.unreachable boolValue]==YES){
        rsvpicon=[UIImage imageNamed:@"portrait_exclaim.png"];
        rsvpstatustext=@"Contact unreachable";
        rsvplabel.textColor=[UIColor colorWithRed:229/255.0 green:46/255.0 blue:83/255.0 alpha:1];
    }
    
    rsvpbadge.image=rsvpicon;
    [rsvpbadge setNeedsDisplay];
    rsvplabel.text=rsvpstatustext;
    [rsvplabel setNeedsDisplay];
    
    
}

- (void)dealloc{
    [super dealloc];
    [background release];
    [namelabel release];
    [rsvplabel release];
    [rsvpbadge release];
}



- (void) showMenu{
    [self setHidden:YES];
//    [delegate showMenu:invitation];
//    NSLog(@"showMenu");
}
@end
