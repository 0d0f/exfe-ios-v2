//
//  EXRSVPStatusView.m
//  EXFE
//
//  Created by huoju on 12/26/12.
//
//

#import "EXRSVPStatusView.h"
#import <BlocksKit/BlocksKit.h>

@implementation EXRSVPStatusView
@synthesize invitation = _invitation;
@synthesize delegate = _delegate;
@synthesize next = _next;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
//        self.layer.shadowColor=[UIColor blackColor].CGColor;
//        self.layer.shadowOpacity = 1;
//        self.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        
        background= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        background.image=[[UIImage imageNamed:@"x_exfee_tip.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9, 9, 9,9)];
        [self addSubview:background];
        
        
        self.next = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.next setFrame:CGRectMake(165.0f, CGRectGetHeight(frame) / 2 - 40 / 2, 10.0f, 40.0f)];
        [self.next setImage:[UIImage imageNamed:@"listarrow.png"] forState:UIControlStateNormal];
        [self.next setBackgroundColor:[UIColor clearColor]];
        [self.next addTarget:self action:@selector(clickToDelegate:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.next];
        
        
        UIImageView *arrow=[[UIImageView alloc] initWithFrame:CGRectMake(165.0f, (frame.size.height-15)/ 2, 12, 15)];
        arrow.image=[UIImage imageNamed:@"arrow.png"];
//        [self addSubview:arrow];
        [arrow release];
        
        namelabel=[[UILabel alloc] initWithFrame:CGRectMake(16, 8, 155, 20)];
        [namelabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]];
        [namelabel setTextColor:FONT_COLOR_51];
        [namelabel setTextAlignment:NSTextAlignmentLeft];
        namelabel.backgroundColor=[UIColor clearColor];
        [self addSubview:namelabel];
        
        rsvpbadge=[[UIImageView alloc] initWithFrame:CGRectMake(16, 28, 18, 18)];
        [self addSubview:rsvpbadge];
        
        rsvplabel=[[UILabel alloc] initWithFrame:CGRectMake(16+18+5, 28, 180-10-18, 20)];
        [rsvplabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        [rsvplabel setTextColor:FONT_COLOR_HL];
        [rsvplabel setTextAlignment:NSTextAlignmentLeft];
        rsvplabel.backgroundColor=[UIColor clearColor];
        [self addSubview:rsvplabel];

        //
        UITapGestureRecognizer *gestureRecognizer = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [self.next sendActionsForControlEvents: UIControlEventTouchUpInside];
        }];
        [self addGestureRecognizer:gestureRecognizer];

        
        // Initialization code
    }
    return self;
}

- (void) setInvitation:(Invitation *)invitation{
    _invitation = invitation;
    namelabel.text = _invitation.identity.name;
    [namelabel setNeedsDisplay];
    
    UIImage *rsvpicon=nil;
    NSString *rsvpstatustext=@"";
    if ([_invitation.rsvp_status isEqualToString:@"ACCEPTED"]){
        rsvpicon=[UIImage imageNamed:@"rsvp_accepted_stroke_26blue.png"];
        rsvplabel.textColor=FONT_COLOR_HL;
        rsvpstatustext=@"Accepted";
    } else if ([_invitation.rsvp_status isEqualToString:@"DECLINED"]){
        rsvpicon=[UIImage imageNamed:@"rsvp_unavailable_stroke_26g5.png"];
        rsvpstatustext=@"Unavailable";
        rsvplabel.textColor=FONT_COLOR_51;
        
    } else if ([_invitation.rsvp_status isEqualToString:@"INTERESTED"]){
        rsvpicon=[UIImage imageNamed:@"rsvp_pending_stroke_26g5.png"];
        rsvpstatustext=@"Interested";
        rsvplabel.textColor=FONT_COLOR_51;
    } else{
        rsvpicon=[UIImage imageNamed:@"rsvp_pending_stroke_26g5.png"];
        rsvpstatustext=@"Pending";
        rsvplabel.textColor=FONT_COLOR_51;
    }
    
    if([_invitation.identity.unreachable boolValue]==YES){
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
    [background release];
    [namelabel release];
    [rsvplabel release];
    [rsvpbadge release];
    [super dealloc];
}

- (void)clickToDelegate:(id)sender
{
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(RSVPStatusView:clickfor:)]) {
            [_delegate RSVPStatusView:self clickfor:self.invitation];
        }
    }
}

@end
