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
        
        _description = [[UILabel alloc] initWithFrame:CGRectMake(0, 78, CGRectGetWidth(frame), CGRectGetHeight(frame) - 78)];
        _description.textAlignment = UITextAlignmentCenter;
        _description.backgroundColor = [UIColor clearColor];
        _description.textColor = [UIColor whiteColor];
        _description.font = [UIFont fontWithName:@"Helvetica Neue" size:13];
        [self.contentView addSubview:_description];
        [_description release];
        
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
