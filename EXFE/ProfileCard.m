//
//  ProfileCard.m
//  EXFE
//
//  Created by Stony on 12/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileCard.h"
#import "Util.h"
#import "UIImage+RoundedCorner.h"

@implementation ProfileCard
@synthesize avatar;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [self addGestureRecognizer:myTap];
    }
    return self;
}

- (void)dealloc {
    [avatar release];
    [super dealloc];
    
}

- (void)setAvatar:(UIImage *)a {
    if (avatar == a){
        return;
    }
    if (avatar != nil) {
        [avatar release];
        avatar = nil;
        [self setNeedsDisplay];
    }
    if (a != nil) {
        avatar = [a roundedCornerImage:40 borderSize:0];
        [avatar retain];
        [self setNeedsDisplay];
    }
}

- (void)addProfileTarget:(id)target action:(SEL)action{
    if (profileTarget != nil){
        [profileTarget release];
        profileTarget = nil;
        profileAction = nil;
    }
    if (target != nil){
        profileTarget  = target;
        [profileTarget retain];
        profileAction = action;
    }
}
- (void)removeProfileTarget:(id)target action:(SEL)action{
    if (profileTarget != nil){
        if (profileTarget == target && profileAction == action){
            [profileTarget release];
            profileTarget = nil;
            profileAction = nil;
        }
    }
}
- (void)performProfileClick{
    if (profileTarget != nil && profileAction != nil){
        [profileTarget performSelector:profileAction withObject:self];
    }
}

- (void)addGatherTarget:(id)target action:(SEL)action{
    if (gatherTarget != nil){
        [gatherTarget release];
        gatherTarget = nil;
        gatherAction = nil;
    }
    if (target != nil){
        gatherTarget  = target;
        [gatherTarget retain];
        gatherAction = action;
    }
}
- (void)removeGatherTarget:(id)target action:(SEL)action{
    if (gatherTarget!= nil){
        if (gatherTarget == target && gatherAction == action){
            [gatherTarget release];
            gatherTarget = nil;
            gatherAction = nil;
        }
    }
}
- (void)performGatherClick{
    if (gatherTarget != nil && gatherAction != nil){
        [gatherTarget performSelector:gatherAction withObject:self];
    }
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        CGPoint location = [recognizer locationInView:self];
        if (location.x - self.frame.origin.x < self.frame.size.width / 2){
            [self performProfileClick];
        }else{
            [self performGatherClick];
        }
    }
}


- (void)layoutSubviews{
	CGRect b = [self bounds];
	[contentView setFrame:b];
    [super layoutSubviews];
}
- (void)drawContentView:(CGRect)r{
    CGRect b = [self bounds];
    // Rect caculation
    int cardMargin = 13;
    CGRect barnnerRect = CGRectMake(b.origin.x + cardMargin, b.origin.y + 17, b.size.width - cardMargin * 2, 40);
    int avatarWidth = 40;
    CGRect avatarRect = CGRectMake(barnnerRect.origin.x, barnnerRect.origin.y, avatarWidth, barnnerRect.size.height);
    
    int paddingH = 8;
    
    int titlePaddingV = 4;
    CGRect titleRect = CGRectMake(avatarRect.origin.x + avatarRect.size.width + paddingH, barnnerRect.origin.y + titlePaddingV, barnnerRect.size.width - avatarWidth - paddingH, barnnerRect.size.height - titlePaddingV * 2);
    // card background
    //[backgroundimg drawInRect:r];
    [[UIColor lightGrayColor] setFill];
    UIRectFill(b);
    
    [avatar drawInRect:avatarRect];
    
    [[UIColor COLOR_RGB(0x00, 0x00,0x00)] set];
    NSString * gather = @"Gather a ·X·";
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:gather];
    [string addAttribute:(NSString*)kCTFontAttributeName  value:[UIFont fontWithName:@"HelveticaNeue" size:23] range:NSMakeRange(0,[string length])];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor COLOR_RGB(0x00, 0x00,0xFF)] range:NSMakeRange(9,3)];
    CGRect titlenewRect = CGRectMake(titleRect.origin.x + titleRect.size.width - string.size.width, titleRect.origin.y, string.size.width, titleRect.size.height);
    [string drawInRect:titlenewRect];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
//    UIView *view = [[UIView alloc] initWithFrame:self.frame];
//    view.backgroundColor = [UIColor colorWithRed:.9 green:.0 blue:.125 alpha:1.0];
//
//    self.selectedBackgroundView = view;
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
