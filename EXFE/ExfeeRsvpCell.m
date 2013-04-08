//
//  ExfeeRsvpCell.m
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "ExfeeRsvpCell.h"
#import "Util.h"

@implementation ExfeeRsvpCell

-(NSString *)getNameText
{
    return _NameText;
}

-(void)setNameText:(NSString *)newText
{
    if (newText != _NameText)
    {
        [_NameText release];
        _NameText = [newText copy];
        [name setText:_NameText];
        [self setNeedsDisplay];
        // need layout
    }
}

-(BOOL)isHost
{
    return _isHost;
}

-(void)setHost:(BOOL)h
{
    if (h != _isHost)
    {
        _isHost = h;
        host.hidden = !h;
        host_star.hidden = !h;
        [self setNeedsDisplay];
    }
}

-(NSAttributedString *)getMainText
{
    return _MainText;
}

-(void)setMainText:(NSAttributedString *)newText
{
    if (newText != _MainText)
    {
        [_MainText release];
        _MainText = [newText copy];
        [main setAttributedText:_MainText];
        [self setNeedsDisplay];
    }
}

-(NSString *)getAltText
{
    return _AltText;
}

-(void)setAltText:(NSString *)newText
{
    if (newText != _AltText)
    {
        [_AltText release];
        _AltText = [newText copy];
        [alt setText:_AltText];
        [self setNeedsDisplay];
    }
}

-(NSString *)getRsvpString
{
    return _RsvpString;
}

-(void)setRsvpString:(NSString *)newText
{
    if (newText != _RsvpString)
    {
        [_RsvpString release];
        _RsvpString = [newText copy];
        if ([@"ACCEPTED" isEqualToString:_RsvpString]) {
            [rsvp_status setImage:[UIImage imageNamed:@"rsvp_accepted_stroke_26blue"]];
        } else {
            [rsvp_status setImage:[UIImage imageNamed:@"rsvp_pending_stroke_26g5"]];
        }
        [self setNeedsDisplay];
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(25, 16, 230, 25)];
        name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21];
        name.textColor = [UIColor COLOR_TUNGSTEN];
        [contentView addSubview:name];
        
        host = [[UILabel alloc] initWithFrame:CGRectMake(180, 23, 60, 15)];
        host.text = @"HOST";
        host.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        host.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        [contentView addSubview:host];
        
        host_star = [[UIImageView alloc] initWithFrame:CGRectMake(160, 16, 20, 20)];
        host_star.backgroundColor = [UIColor grayColor];
        [contentView addSubview:host_star];
        
        main = [[EXAttributedLabel alloc] initWithFrame:CGRectMake(25, 65, 190, 22)];
        main.backgroundColor = [UIColor clearColor];
        [contentView addSubview:main];
        
        alt = [[UILabel alloc] initWithFrame:CGRectMake(25, 90, 190, 13)];
        alt.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        alt.textColor = [UIColor COLOR_GRAY];
        [contentView addSubview:alt];
        
        rsvp_status = [[UIImageView alloc] initWithFrame:CGRectMake(269, 65, 26, 26)];
        [contentView addSubview:rsvp_status];
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

//- (void)drawContentView:(CGRect)r
//{
//	// subclasses should implement this
//}
@end
