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
        rectAvatarFrame = CGRectUnion(CGRectOffset(rectAvatar, -2, -2),CGRectOffset(rectAvatar, 2, 2));
        rectRsvpImage = CGRectMake(2, CGRectGetMaxY(rectAvatarFrame), 18, 18);
        rectName = CGRectMake(CGRectGetMaxX(rectRsvpImage) + 2, CGRectGetMaxY(rectAvatarFrame) + 1, 50, 16);
        rectMates = CGRectMake(CGRectGetMaxX(rectAvatar), CGRectGetMinY(rectAvatar), 20, 10);
        
        _avatar = [[UIImageView alloc] initWithFrame:rectAvatar];
        _avatar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        _avatar.backgroundColor = [UIColor yellowColor];
        {
            UIBezierPath *curvePath= [UIBezierPath bezierPathWithRoundedRect:_avatar.bounds cornerRadius:4];
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = [curvePath CGPath];
            _avatar.layer.mask = maskLayer;
            _avatar.layer.masksToBounds = YES;
        }
        [self addSubview:_avatar];
        
        _avatarFrame = [[UIImageView alloc] initWithFrame:rectAvatarFrame];
        _avatarFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_avatarFrame];
        
        _rsvpImage = [[UIImageView alloc] initWithFrame:rectRsvpImage];
        {
            UIBezierPath *curvePath= [UIBezierPath bezierPathWithRoundedRect:_rsvpImage.bounds cornerRadius:9];
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.path = [curvePath CGPath];
            _rsvpImage.layer.mask = maskLayer;
            _rsvpImage.layer.masksToBounds = YES;
        }
        [self addSubview:_rsvpImage];
        
        _name = [[UILabel alloc] initWithFrame:rectName];
        _name.textColor = [UIColor COLOR_SNOW];
        _name.lineBreakMode = UILineBreakModeCharacterWrap;
        _name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _name.backgroundColor = [UIColor blueColor];
        [self addSubview:_name];
    }
    return self;
}

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    if((self = [super initWithCoder:aDecoder])) {
//    }
//    return self;
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    // draw Mates
    if (self.mates > 0) {
    }
}


// Selection highlights underlying contents
- (void)setSelected:(BOOL)selected
{
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

- (void)setRsvp:(RsvpCode)rsvp
{
    [self setRsvp:rsvp andUnreachable:NO];
}

- (void)setRsvp:(RsvpCode)rsvp andUnreachable:(BOOL)unreachable
{
    _rsvp = rsvp;
    _unreachable = unreachable;
    [self updateRsvpImage];
}

- (void)updateRsvpImage
{
    if (_unreachable) {
//        _rsvpImage = [UIImage imageNamed:@""];
        _rsvpImage.backgroundColor = [UIColor redColor];
    }else{
        switch (_rsvp) {
            case kRsvpAccepted:
//            _rsvpImage = [UIImage imageNamed:@""];
                _rsvpImage.backgroundColor = [UIColor greenColor];
                break;
            case kRsvpDeclined:
//            _rsvpImage = [UIImage imageNamed:@""];
                _rsvpImage.backgroundColor = [UIColor purpleColor];
                break;
            default:
//            _rsvpImage = [UIImage imageNamed:@""];
                _rsvpImage.backgroundColor = [UIColor blueColor];
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
