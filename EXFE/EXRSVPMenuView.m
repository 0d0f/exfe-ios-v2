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

- (id)initWithFrame:(CGRect)frame withDelegate:(id)_delegate items:(NSArray*)itemlist showTitleBar:(BOOL)showtitlebar
{
    self = [super initWithFrame:frame];
    if (self) {
        delegate=_delegate;
        [self setBackgroundColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.96]];
        UIView *responseview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 20)];
        responseview.backgroundColor=[UIColor colorWithRed:76/255.0 green:76/255.0 blue:76/255.0 alpha:0.96];
        int y=0;
        if(showtitlebar==YES){
            UILabel *responselabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 4, 100, 16)];
            responselabel.text=@"Response:";
            [responselabel setBackgroundColor:[UIColor clearColor]];
            [responselabel setTextColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0]];
            [responselabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            [responseview addSubview:responselabel];
            
            [self addSubview:responseview];
            [responselabel release];
            [responseview release];
            y+=20;
        }
        
        if([self Itemscontain:itemlist string:@"Accepted"]){
            UIButton *btnaccepted=[UIButton buttonWithType:UIButtonTypeCustom];
            [btnaccepted setTitle:@"Accepted" forState:UIControlStateNormal];
            [btnaccepted.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18]];
            [btnaccepted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnaccepted setFrame:CGRectMake(0, y, 125, 44)];
            [btnaccepted.titleLabel setTextAlignment:NSTextAlignmentLeft];
            
            btnaccepted.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnaccepted.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [btnaccepted addTarget:self action:@selector(setRsvpAccepted) forControlEvents:UIControlEventTouchUpInside];
            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            bottomBorder.borderWidth = 1;
            bottomBorder.frame = CGRectMake(0, btnaccepted.frame.size.height-1,btnaccepted.frame.size.width , 1);
            [btnaccepted.layer addSublayer:bottomBorder];
            [self addSubview:btnaccepted];
            y+=44;
        }
        
        if([self Itemscontain:itemlist string:@"Unavailable"]){
            UIButton *btnUnavailable=[UIButton buttonWithType:UIButtonTypeCustom];
            [btnUnavailable setTitle:@"Unavailable" forState:UIControlStateNormal];
            [btnUnavailable.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [btnUnavailable setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnUnavailable setFrame:CGRectMake(0, y, 125, 44)];
            btnUnavailable.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnUnavailable.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [btnUnavailable.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [btnUnavailable addTarget:self action:@selector(setRsvpUnavailable) forControlEvents:UIControlEventTouchUpInside];

            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            bottomBorder.borderWidth = 1;
            bottomBorder.frame = CGRectMake(0, btnUnavailable.frame.size.height-1,btnUnavailable.frame.size.width , 1);
            [btnUnavailable.layer addSublayer:bottomBorder];
            
            [self addSubview:btnUnavailable];
            y+=44;
        }

        if([self Itemscontain:itemlist string:@"Pending"]){
            UIButton *btnPending=[UIButton buttonWithType:UIButtonTypeCustom];
            [btnPending setTitle:@"Pending" forState:UIControlStateNormal];
            [btnPending.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [btnPending setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnPending setFrame:CGRectMake(0, y, 125, 44)];
            btnPending.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnPending.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [btnPending.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [btnPending addTarget:self action:@selector(setRsvpPending) forControlEvents:UIControlEventTouchUpInside];
            
            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            bottomBorder.borderWidth = 1;
            bottomBorder.frame = CGRectMake(0, btnPending.frame.size.height-1,btnPending.frame.size.width , 1);
            [btnPending.layer addSublayer:bottomBorder];

            
            [self addSubview:btnPending];
            y+=44;
        }
        if([self Itemscontain:itemlist string:@"Delete"]){
            UIButton *btnDelete=[UIButton buttonWithType:UIButtonTypeCustom];
            [btnDelete setTitle:@"Delete" forState:UIControlStateNormal];
            [btnDelete.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
            [btnDelete setTitleColor:[UIColor colorWithRed:229/255.0 green:46/255.0 blue:83/255.0 alpha:1] forState:UIControlStateNormal];
            [btnDelete setFrame:CGRectMake(0, y, 125, 44)];
            btnDelete.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnDelete.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [btnDelete.titleLabel setTextAlignment:NSTextAlignmentLeft];
            [btnDelete addTarget:self action:@selector(setRsvpRemove) forControlEvents:UIControlEventTouchUpInside];
            
            CALayer *bottomBorder = [CALayer layer];
            bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
            bottomBorder.borderWidth = 1;
            bottomBorder.frame = CGRectMake(0, btnDelete.frame.size.height-1,btnDelete.frame.size.width , 1);
            [btnDelete.layer addSublayer:bottomBorder];
            [self addSubview:btnDelete];
            y+=44;
        }

        self.layer.borderWidth=0.5;
        self.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.12].CGColor;
        
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(1.5, 1.5)];

        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        [maskLayer release];
    
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
    [delegate RSVPPendingMenuView:self];
}

- (void) setRsvpRemove{
    [delegate RSVPRemoveMenuView:self];
}

- (BOOL) Itemscontain:(NSArray*)items string:(NSString*)item{
    for (NSString *str in items){
        if([str isEqualToString:item])
            return YES;
    }
    return NO;
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
