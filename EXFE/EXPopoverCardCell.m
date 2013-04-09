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

- (void)dealloc {
    [_userNameLabel release];
    [_providerLabel release];
    [super dealloc];
}
@end
