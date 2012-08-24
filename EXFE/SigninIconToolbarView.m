//
//  SinginIconToolbarView.m
//  EXFE
//
//  Created by huoju on 8/24/12.
//
//

#import "SigninIconToolbarView.h"

@implementation SigninIconToolbarView

- (id)initWithFrame:(CGRect)frame style:(NSString*)style delegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        if([style isEqualToString:@"landing"])
        {
            UIImage *signbtn_backimg = [UIImage imageNamed:@"signinbar_btnbg.png"];
            UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(14, 10, 126, 31)];
            backimg.image=signbtn_backimg;
            backimg.contentMode=UIViewContentModeScaleToFill;
            backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
            [self addSubview:backimg];
            [backimg release];
            
            signinbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [signinbutton setFrame:CGRectMake(14, 10, 126, 31)];
            [signinbutton setTitle:@"Start with email" forState:UIControlStateNormal];
            [signinbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
            [signinbutton setTitleColor:FONT_COLOR_51 forState:UIControlStateNormal];
            [signinbutton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            signinbutton.titleLabel.shadowOffset=CGSizeMake(0, 1);
            
            [signinbutton addTarget:delegate action:@selector(SigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:signinbutton];
        }
        twitterbutton=[UIButton buttonWithType:UIButtonTypeCustom];
        [twitterbutton setFrame:CGRectMake(212+13, 10, 32, 32)];
        [twitterbutton setBackgroundImage:[UIImage imageNamed:@"identity_twitter_32.png"] forState:UIControlStateNormal];
        [twitterbutton addTarget:delegate action:@selector(TwitterSigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:twitterbutton];
        // Initialization code
    }
    return self;
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
