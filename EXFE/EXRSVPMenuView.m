//
//  EXRSVPMenuView.m
//  EXFE
//
//  Created by huoju on 12/27/12.
//
//

#import "EXRSVPMenuView.h"

@implementation EXRSVPMenuView
@synthesize invitation;

- (id)initWithFrame:(CGRect)frame withDelegate:(id)_delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        delegate=_delegate;
        [self setBackgroundColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.96]];
        UIView *responseview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 20)];
        responseview.backgroundColor=[UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:0.96];
        UILabel *responselabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 4, 100, 16)];
        responselabel.text=@"Response:";
        [responselabel setBackgroundColor:[UIColor clearColor]];
        [responselabel setTextColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
        [responselabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        [responseview addSubview:responselabel];
        
        [self addSubview:responseview];
        [responselabel release];
        [responseview release];
        
        
        UIButton *btnaccepted=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnaccepted setTitle:@"Accepted" forState:UIControlStateNormal];
        [btnaccepted.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]];
        [btnaccepted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnaccepted setFrame:CGRectMake(0, 20, 125, 44)];
        [btnaccepted.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [btnaccepted addTarget:self action:@selector(setRsvpAccepted) forControlEvents:UIControlEventTouchUpInside];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRectMake(0, btnaccepted.frame.size.height-1,btnaccepted.frame.size.width , 1);
        [btnaccepted.layer addSublayer:bottomBorder];

        [self addSubview:btnaccepted];
        
        UIButton *btnUnavailable=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnUnavailable setTitle:@"Unavailable" forState:UIControlStateNormal];
        [btnUnavailable.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        [btnUnavailable setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnUnavailable setFrame:CGRectMake(0, 20+44, 125, 44)];
        [btnUnavailable.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [btnUnavailable addTarget:self action:@selector(setRsvpUnavailable) forControlEvents:UIControlEventTouchUpInside];

        bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRectMake(0, btnUnavailable.frame.size.height-1,btnUnavailable.frame.size.width , 1);
        [btnUnavailable.layer addSublayer:bottomBorder];
        
        [self addSubview:btnUnavailable];
        
        UIButton *btnPending=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnPending setTitle:@"Pending" forState:UIControlStateNormal];
        [btnPending.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
        [btnPending setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnPending setFrame:CGRectMake(0, 20+44+44, 125, 44)];
        [btnPending.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [btnPending addTarget:self action:@selector(setRsvpPending) forControlEvents:UIControlEventTouchUpInside];
        
        bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
        bottomBorder.borderWidth = 1;
        bottomBorder.frame = CGRectMake(0, btnPending.frame.size.height-1,btnPending.frame.size.width , 1);
        [btnPending.layer addSublayer:bottomBorder];

        
        [self addSubview:btnPending];
        
    }
    return self;
}

- (void) setRsvpAccepted{
    [delegate RSVPAcceptedMenuView:self];
}
- (void) setRsvpUnavailable{
    [delegate RSVPUnavailableMenuView:self];
}
- (void) setRsvpPending{
    [delegate RSVPPendinMenuView:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
