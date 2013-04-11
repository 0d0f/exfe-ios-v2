//
//  ExfeeCollectionViewCell.m
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "ExfeeCollectionViewCell.h"

@implementation ExfeeCollectionViewCell

@synthesize avatar = _avatar;
@synthesize name = _name;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        rectAvatar = CGRectMake(4, 4, 70, 70);
        rectAvatarFrame = CGRectUnion(CGRectOffset(rectAvatar, -4, -4),CGRectOffset(rectAvatar, 4, 4));
        rectRsvpImage = CGRectMake(2, CGRectGetMaxY(rectAvatarFrame) - 2, 18, 18);
        rectName = CGRectMake(CGRectGetMaxX(rectRsvpImage) + 2, CGRectGetMaxY(rectAvatarFrame), 50, 16);
        rectMates = CGRectMake(CGRectGetWidth(rectAvatar) - 20, 0, 20, 13);
        
        _avatar = [[UIImageView alloc] initWithFrame:rectAvatar];
        _avatar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        {
            UIBezierPath *curvePath= [UIBezierPath bezierPathWithRoundedRect:_avatar.bounds cornerRadius:4];
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = [curvePath CGPath];
            _avatar.layer.mask = maskLayer;
            _avatar.layer.masksToBounds = YES;
        }
        [self addSubview:_avatar];
        
        _matesBg = [[CALayer alloc] init];
        _matesBg.contents = (id)[UIImage imageNamed:@"exfee_portrait_mate.png"].CGImage;
        _matesBg.frame = rectMates;
        _matesBg.zPosition = 88;
        [_avatar.layer addSublayer:_matesBg];
        
        _matesLayer = [[CATextLayer alloc] init];
        [_matesLayer setFont:@"HelveticaNeue-Bold"];
        [_matesLayer setFontSize:9];
        [_matesLayer setFrame: rectMates];
        [_matesLayer setAlignmentMode:kCAAlignmentCenter];
        [_matesLayer setContentsScale:[[UIScreen mainScreen] scale]];
        [_matesLayer setForegroundColor:[[UIColor whiteColor] CGColor]];
        _matesLayer.zPosition = 99;
        [_avatar.layer addSublayer:_matesLayer];
        
        
        _avatarFrame = [[UIImageView alloc] initWithFrame:rectAvatarFrame];
        _avatarFrame.image = [UIImage imageNamed:@"exfee_portrait_frame.png"];
        _avatarFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_avatarFrame];
        
        _rsvpImage = [[UIImageView alloc] initWithFrame:rectRsvpImage];
        [self addSubview:_rsvpImage];
        
        _name = [[UILabel alloc] initWithFrame:rectName];
        _name.textColor = [UIColor COLOR_SNOW];
        _name.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        _name.lineBreakMode = UILineBreakModeCharacterWrap;
        _name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _name.backgroundColor = [UIColor clearColor];
        [self addSubview:_name];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [_rsvpImage release];
    [_avatarFrame release];
    [_matesLayer release];
    [_matesBg release];
    [super dealloc];
}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    if((self = [super initWithCoder:aDecoder])) {
//    }
//    return self;
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    [super drawRect:rect];
//}


// Selection highlights underlying contents
- (void)setSelected:(BOOL)selected
{
    if (selected) {
        _avatarFrame.image = [UIImage imageNamed:@"exfee_portrait_selected.png"];
    }else{
        _avatarFrame.image = [UIImage imageNamed:@"exfee_portrait_frame.png"];
    }
    [super setSelected:selected];
}

// Cell highlighting only highlights the cell itself
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
}

- (NSUInteger)getMates
{
    return _mates;
}

- (void)setMates:(NSUInteger)mates
{
    _mates = mates;
    if (mates > 0) {
        _matesBg.hidden = NO;
//        _matesLayer.hidden = NO;
        [_matesLayer setString:[NSString stringWithFormat:@"+%d", _mates]];
    } else {
        _matesBg.hidden = YES;
//        _matesLayer.hidden = YES;
        [_matesLayer setString:@""];
    }
    
    [self setNeedsDisplay];
}

- (RsvpCode)getRsvp
{
    return _rsvp;
}

- (BOOL)getUnreachable
{
    return _unreachable;
}

- (BOOL)getHost
{
    return _host;
}

- (void)setRsvp:(RsvpCode)rsvp
{
    [self setRsvp:rsvp andUnreachable:NO withHost:NO];
}

- (void)setRsvp:(RsvpCode)rsvp andUnreachable:(BOOL)unreachable withHost:(BOOL)host
{
    _rsvp = rsvp;
    _unreachable = unreachable;
    _host = host;
    [self updateRsvpImage];
}

- (void)updateRsvpImage
{
    if (_unreachable) {
        _rsvpImage.image = [UIImage imageNamed:@"exfee_unreachable_badge.png"];
    } else if (_host) {
        _rsvpImage.image = [UIImage imageNamed:@"exfee_host_badge.png"];
    } else{
        switch (_rsvp) {
            case kRsvpAccepted:
            _rsvpImage.image = [UIImage imageNamed:@"exfee_accepted_badge.png"];
                break;
            case kRsvpDeclined:
            _rsvpImage.image = [UIImage imageNamed:@"exfee_unavailable_badge.png"];
                break;
            default:
            _rsvpImage.image = [UIImage imageNamed:@"exfee_pending_badge.png"];
                break;
        }
    }
}

- (SequencePosition)getSequence
{
    return _sequence;
}

- (void)setSequence:(SequencePosition)sequence
{
    if (_sequence != sequence){
        switch (sequence) {
            case kPosFirst:
                _avatar.frame = CGRectOffset(rectAvatar, 4, 0);
                _avatarFrame.frame = CGRectOffset(rectAvatarFrame, 4, 0);
                _rsvpImage.frame = CGRectOffset(rectRsvpImage, 4, 0);
                _name.frame = CGRectOffset(rectName, 4, 0);
                break;
                
            default:
                _avatar.frame = rectAvatar;
                _avatarFrame.frame = rectAvatarFrame;
                _rsvpImage.frame = rectRsvpImage;
                _name.frame = rectName;
                break;
        }
    }
    _sequence = sequence;
}

@end
