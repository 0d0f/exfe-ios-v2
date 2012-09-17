//
//  EXPlaceEditView.m
//  EXFE
//
//  Created by huoju on 6/29/12.
//
//

#import "EXPlaceEditView.h"

@implementation EXPlaceEditView
@synthesize PlaceDesc;
@synthesize PlaceTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled=YES;
        self.backgroundColor=[UIColor clearColor];
        UIImageView *backgroundimg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        backgroundimg.image=[UIImage imageNamed:@"place_editbg.png"];
        [self addSubview:backgroundimg];
        [backgroundimg release];

//        CGSize constraint = CGSizeMake(frame.size.width , 20000.0f);
//        CGSize size = [@"A" sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:21] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

        PlaceTitle=[[UITextField alloc] initWithFrame:CGRectMake(17, 9, 260, 24)];
        [PlaceTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:21]];
        [PlaceTitle setDelegate:self];

        PlaceTitle.textColor=[Util getHighlightColor];

        PlaceDesc=[[UITextView alloc] initWithFrame:CGRectMake(17-6, 9+24+6, 270, 72)];
        [PlaceDesc setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        PlaceDesc.backgroundColor=[UIColor clearColor];

        [self addSubview:PlaceTitle];
        [self addSubview:PlaceDesc];
        
        closeButton = [[UIButton alloc]
                                 initWithFrame:CGRectMake(self.frame.size.width-25, self.frame.size.height-25, 25.0f, 25.0f)];
//        [closeButton setBackgroundImage:[UIImage imageNamed:@"closebutton"]
//                               forState:UIControlStateNormal];
//        [self addSubview:closeButton];
    }
    return self;
}
- (CGRect) getCloseButtonFrame{
    return closeButton.frame;
}
- (void) setPlaceTitleText:(NSString*)title{
    PlaceTitle.text=title;
}
- (void) setPlaceDescText:(NSString*)desc{
    PlaceDesc.text=desc;
}
- (void)dealloc{
    [PlaceDesc release];
    [PlaceTitle release];
    [closeButton release]; 
    [super dealloc];
}

- (BOOL)becomeFirstResponder {
    return [PlaceTitle becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [PlaceDesc becomeFirstResponder];
    return YES;
}
- (NSString*) getPlaceTitleText{
    return PlaceTitle.text;
}
- (NSString*) getPlaceDescText{
    return PlaceDesc.text;
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [PlaceTitle resignFirstResponder] && [PlaceDesc resignFirstResponder];
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
