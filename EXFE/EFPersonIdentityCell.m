//
//  EFPersonIdentityCell.m
//  EXFE
//
//  Created by 0day on 13-4-18.
//
//

#import "EFPersonIdentityCell.h"

#define kLineHeight 44

@implementation EFPersonIdentityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (CGFloat)heightWithIdentities:(NSArray *)identities {
    NSUInteger count = [identities count];
    NSUInteger numberOfLines = count / 2 +  count % 1;
    return numberOfLines * kLineHeight;
}

@end
