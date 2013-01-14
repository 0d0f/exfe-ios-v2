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
        //avatar = [a roundedCornerImage:40 borderSize:0];
        avatar = a;
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
    CGRect barnnerRect = CGRectMake(cardMargin, 16, b.size.width - cardMargin * 2, 40);
    
    int avatarWidth = 40;
    int avatarHeight = 40;
    CGRect avatarRect = CGRectMake(barnnerRect.origin.x + 1, barnnerRect.origin.y, avatarWidth, avatarHeight);
    
    int paddingH = 8;
    int paddingH2 = 22;
    int titlePaddingV = 8;
    CGRect titleRect = CGRectMake(CGRectGetMaxX(avatarRect) + paddingH, barnnerRect.origin.y + titlePaddingV, barnnerRect.size.width - avatarWidth - paddingH - paddingH2, barnnerRect.size.height - titlePaddingV * 2);
    // card background
    //[backgroundimg drawInRect:r];
    [[UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)] setFill];
    UIRectFill(b);
    [avatar drawInRect:avatarRect];
    
    [[UIImage imageNamed:@"xlist_top.png"] drawInRect:CGRectMake(0, 9, CGRectGetWidth(b), CGRectGetHeight(b) - 9)];
    
    [[UIColor greenColor] set];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextTranslateCTM(currentContext, 0, self.bounds.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    NSString * gather = @"Gather a ·X·";
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:gather];
    CTFontRef fontRef= CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 20.0, NULL);
    [string addAttribute:(NSString*)kCTFontAttributeName  value:(id)fontRef range:NSMakeRange(0,[string length])];
    CFRelease(fontRef);
    [string addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor darkGrayColor].CGColor range:NSMakeRange(0,9)];
    [string addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_EXFEE_BLUE].CGColor range:NSMakeRange(9,3)];
    
    CTTextAlignment alignment = kCTRightTextAlignment;
    CTParagraphStyleSetting setting[1] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
    };
    CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(setting, 1);
    [string addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[string length])];
    CFRelease(paragraphstyle);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectOffset(titleRect, 0, -titlePaddingV));
    CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [string length]), path, NULL);
    CFRelease(framesetter);
    CFRelease(path);
    CTFrameDraw(theFrame, currentContext);
    CFRelease(theFrame);
    [string release];
    CGContextRestoreGState(currentContext);
    
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
