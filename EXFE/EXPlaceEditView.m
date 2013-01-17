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
        backgroundimg.image=[[UIImage imageNamed:@"map_edit_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0,0)];
//        
        [self addSubview:backgroundimg];
        [backgroundimg release];

//        CGSize constraint = CGSizeMake(frame.size.width , 20000.0f);
//        CGSize size = [@"A" sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:21] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

        PlaceTitle=[[UITextField alloc] initWithFrame:CGRectMake(17, 9, 260, 24)];
        [PlaceTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:21]];
        PlaceTitle.textColor=[UIColor whiteColor];
        [PlaceTitle setDelegate:self];

        PlaceDesc=[[UITextView alloc] initWithFrame:CGRectMake(17-6, 9+24+6, 270, 72)];
        [PlaceDesc setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
        PlaceDesc.backgroundColor=[UIColor clearColor];
        PlaceDesc.textColor=[UIColor whiteColor];

        [self addSubview:PlaceTitle];
        [self addSubview:PlaceDesc];
        
        closeButton = [[UIButton alloc]
                                 initWithFrame:CGRectMake(self.frame.size.width-25, self.frame.size.height-25, 25.0f, 25.0f)];
//        
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
//
//- (void)drawRect:(CGRect)rect
//{
//    UIBezierPath *framepath =[UIBezierPath bezierPathWithRect:rect];
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    CGContextBeginPath(currentContext);
//    CGContextAddPath(currentContext, framepath.CGPath);
//    CGContextClosePath(currentContext);
//    CGContextSaveGState(currentContext);
//    
//    CGFloat colors [] = {
//        0/255.0f, 0/255.0f, 0/255.0f, 0.5,
//        0/255.0f, 0/255.0f, 0/255.0f, 0.33
//    };
//    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
//    CGColorSpaceRelease(baseSpace);
//    baseSpace = NULL;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
//    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//    CGGradientRelease(gradient), gradient = NULL;
//}

@end
