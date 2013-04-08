//
//  EXPopoverCardCell.m
//  EXFE
//
//  Created by 0day on 13-4-4.
//
//

#import "EXPopoverCardCell.h"

@implementation EXPopoverCardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXPopoverCardCell"
                                          owner:nil
                                        options:nil] lastObject] retain];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_providerImageView release];
    [_userNameLabel release];
    [super dealloc];
}
@end
