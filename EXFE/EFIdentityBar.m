//
//  EFIdentityBar.m
//  EXFE
//
//  Created by Stony Wang on 13-7-23.
//
//

#import "EFIdentityBar.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@interface EFIdentityBar()


@end

@implementation EFIdentityBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // TODO: calculator the frames
//        UIView * identityBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 50)];
        self.layer.backgroundColor = [UIColor COLOR_WA(0xE6, 0xFF)].CGColor;
        self.layer.cornerRadius = 4;
        self.layer.borderColor = [UIColor COLOR_WA(0xCC, 0xFF)].CGColor;
        self.layer.borderWidth = 1;
        self.layer.masksToBounds = NO;
        
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        avatar.layer.cornerRadius = 2;
        avatar.clipsToBounds = YES;
        self.avatar = avatar;
        [self addSubview:avatar];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 40)];
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:18];
        name.textColor = [UIColor COLOR_BLACK_19];;
        self.name = name;
        [self addSubview:name];
        // listarrow
        UIImageView *down = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron_d20g5.png"]];
        down.frame = CGRectMake(260, 15, 20, 20);
        [self addSubview:down];
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
