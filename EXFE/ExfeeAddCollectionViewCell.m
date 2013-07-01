//
//  ExfeeAddCollectionViewCell.m
//  EXFE
//
//  Created by Stony Wang on 13-3-26.
//
//

#import "ExfeeAddCollectionViewCell.h"

@implementation ExfeeAddCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _avatar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exfee_add.png"]];
        _avatar.frame = CGRectMake(0, 0, 78, 78);
        [self.contentView addSubview:_avatar];
        [_avatar release];
        
        _description = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, CGRectGetWidth(frame), 16)];
        _description.textAlignment = UITextAlignmentCenter;
        _description.backgroundColor = [UIColor clearColor];
        _description.textColor = [UIColor whiteColor];
        _description.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        [self.contentView addSubview:_description];
        [_description release];
        
        _rsvp = [[UILabel alloc] initWithFrame:CGRectMake(0, 79, CGRectGetWidth(frame), 16)];
        _rsvp.textAlignment = UITextAlignmentCenter;
        _rsvp.backgroundColor = [UIColor clearColor];
        _rsvp.textColor = [UIColor whiteColor];
        _rsvp.text = NSLocalizedString(@"Accepted", @"Accepted in Add Exfee");
        _rsvp.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        [self.contentView addSubview:_rsvp];
        [_rsvp release];
        
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
