//
//  EXPlaceEditView.m
//  EXFE
//
//  Created by huoju on 6/29/12.
//
//

#import "EXPlaceEditView.h"

@implementation EXPlaceEditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor whiteColor];

        CGSize constraint = CGSizeMake(frame.size.width , 20000.0f);
        CGSize size = [@"A" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:21] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

        PlaceTitle=[[UITextField alloc] initWithFrame:CGRectMake(4, 4, frame.size.width-8, size.height+5)];
        [PlaceTitle setFont:[UIFont fontWithName:@"Helvetica" size:21]];
        [PlaceTitle setDelegate:self];

        PlaceTitle.textColor=[Util getHighlightColor];

        CGSize sizedesc = [@"A\nA\nA\nA" sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        PlaceDesc=[[UITextView alloc] initWithFrame:CGRectMake(0, 4+size.height+5, frame.size.width-8, sizedesc.height)];
        [PlaceDesc setFont:[UIFont fontWithName:@"Helvetica" size:14]];


        [self addSubview:PlaceTitle];
        [self addSubview:PlaceDesc];
    }
    return self;
}
- (void) setPlaceTitle:(NSString*)title{
    PlaceTitle.text=title;
}
- (void) setPlaceDesc:(NSString*)desc{
    PlaceDesc.text=desc;
}
- (void)dealloc{
    [PlaceDesc release];
    [PlaceTitle release];
    [super dealloc];
}
- (BOOL)becomeFirstResponder {
    return [PlaceTitle becomeFirstResponder];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [PlaceDesc becomeFirstResponder];
    return YES;
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
