//
//  EXAlertView.m
//  EXFE
//
//  Created by huoju on 1/3/13.
//
//

#import "EXAlertView.h"

@implementation EXAlertView
@synthesize alertmsg;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (EXAlertView *)showAlertTo:(UIView *)view frame:(CGRect)frame message:(NSString*)msg animated:(BOOL)animated{
    
//    id me = [self initWithFrame:view.bounds];
	EXAlertView *alertview = [[EXAlertView alloc] initWithFrame:frame];
    alertview.alertmsg=msg;
    alertview.layer.cornerRadius=2;
    alertview.layer.masksToBounds=YES;
	[view addSubview:alertview];
    if(animated==YES){
        alertview.alpha=0;
        [UIView animateWithDuration:0.3 animations:^{
            alertview.alpha = 1.0f;
        }];
    }
	return MB_AUTORELEASE(alertview);
}


+ (void)hideAlertFrom:(UIView *)view animated:(BOOL)animated delay:(NSTimeInterval)time{
	EXAlertView *alertview = [EXAlertView AlertFrom:view];
    if (alertview != nil) {
        [self performBlock:^{
            if(animated==YES){
                alertview.alpha=1.0;
                [UIView animateWithDuration:0.3 animations:^{
                    alertview.alpha = 0;
                } completion:^(BOOL finished) {
                    [alertview removeFromSuperview];
                }];
            }

        } afterDelay:time];
	}
}

+ (EXAlertView *)AlertFrom:(UIView *)view{
    EXAlertView *alertview = nil;
	NSArray *subviews = view.subviews;
	for (UIView *view in subviews) {
		if ([view isKindOfClass:[EXAlertView class]]) {
			alertview = (EXAlertView *)view;
		}
	}
	return alertview;
}

- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithRed:0 green:15/255.0 blue:32/255.0 alpha:1] set];
    [self.alertmsg drawInRect:CGRectMake(10, 4, rect.size.width-20, rect.size.height-8) withFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
}

@end
