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
            signinbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [signinbutton setFrame:CGRectMake(14, 10, 126, 31)];
            [signinbutton setTitle:@"Start" forState:UIControlStateNormal];
            [signinbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
            [signinbutton setTitleColor:FONT_COLOR_51 forState:UIControlStateNormal];
            [signinbutton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            signinbutton.titleLabel.shadowOffset=CGSizeMake(0, 1);
            [signinbutton setBackgroundImage:[[UIImage imageNamed:@"signinbar_btnbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateNormal];
            
            [signinbutton addTarget:delegate action:@selector(SigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:signinbutton];
        }
        else if([style isEqualToString:@"signin"]){
            signinbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [signinbutton setFrame:CGRectMake(14, 16, 129, 18)];
            [signinbutton setTitle:@"Welcome to EXFE" forState:UIControlStateNormal];
            [signinbutton addTarget:delegate action:@selector(welcomeButtonPress:) forControlEvents:UIControlEventTouchUpInside];

            [signinbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
            [signinbutton setTitleColor:[UIColor colorWithRed:219.0/255.0 green:234.0/255.0 blue:249.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [signinbutton setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.75] forState:UIControlStateNormal];
            signinbutton.titleLabel.shadowOffset=CGSizeMake(1, 1);
            [self addSubview:signinbutton];
        }
        else if([style isEqualToString:@"addidentity"]){
            
        }
        if(![style isEqualToString:@"addidentity"]){
            facebookbutton =[UIButton buttonWithType:UIButtonTypeCustom];
            [facebookbutton setFrame:CGRectMake(14+126+14+13+10, 10, 32, 32)];
            [facebookbutton setBackgroundImage:[UIImage imageNamed:@"identity_facebook_32.png"] forState:UIControlStateNormal];
            [facebookbutton addTarget:delegate action:@selector(FacebookSigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:facebookbutton];

            twitterbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [twitterbutton setFrame:CGRectMake(212+13+20, 10, 32, 32)];
            [twitterbutton setBackgroundImage:[UIImage imageNamed:@"identity_twitter_32.png"] forState:UIControlStateNormal];
            [twitterbutton addTarget:delegate action:@selector(TwitterSigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:twitterbutton];
            
            morebutton =[UIButton buttonWithType:UIButtonTypeCustom];
            [morebutton setFrame:CGRectMake(270+9, 10, 32, 32)];
            [morebutton setBackgroundImage:[UIImage imageNamed:@"identity_more_32.png"] forState:UIControlStateNormal];
            [morebutton setEnabled:NO];
//            [self addSubview:morebutton];
        }
        else if([style isEqualToString:@"addidentity"]){
            twitterbutton=[UIButton buttonWithType:UIButtonTypeCustom];
            [twitterbutton setFrame:CGRectMake(116+10, 14, 40, 40)];
            [twitterbutton setBackgroundImage:[UIImage imageNamed:@"identity_twitter_40.png"] forState:UIControlStateNormal];
            [twitterbutton addTarget:delegate action:@selector(TwitterSigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:twitterbutton];
            
            facebookbutton =[UIButton buttonWithType:UIButtonTypeCustom];
            [facebookbutton setFrame:CGRectMake(116+72+20, 14, 40, 40)];
            [facebookbutton setBackgroundImage:[UIImage imageNamed:@"identity_facebook_40.png"] forState:UIControlStateNormal];
            [facebookbutton addTarget:delegate action:@selector(FacebookSigninButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:facebookbutton];
            
            morebutton =[UIButton buttonWithType:UIButtonTypeCustom];
            [morebutton setFrame:CGRectMake(116+72+72, 14, 40, 40)];
            [morebutton setBackgroundImage:[UIImage imageNamed:@"identity_more_40.png"] forState:UIControlStateNormal];
            [morebutton addTarget:delegate action:@selector(MoreButtonPress:) forControlEvents:UIControlEventTouchUpInside];
//            [morebutton setEnabled:NO];
//            [self addSubview:morebutton];
        }
        // Initialization code
    }
    return self;
}
- (void) dealloc{
    [signinbutton release];
    [twitterbutton release];
    [facebookbutton release];
    [morebutton release];
    [super dealloc];
 
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
