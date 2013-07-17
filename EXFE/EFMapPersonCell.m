//
//  EFMapPersonCell.m
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapPersonCell.h"

#import <QuartzCore/QuartzCore.h>
#import "EFMapKit.h"

@interface EFMapPersonCell (Private)
- (void)_personDidChange;
@end

@implementation EFMapPersonCell (Private)

- (void)_personDidChange {
    self.avatarImageView.image = self.person.avatarImage;
    self.stateLabel.text = [NSString stringWithFormat:@"%d米", (int)self.person.distence];
}

@end

@implementation EFMapPersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(CGRect){{5, 5}, {40, 40}}];
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.borderColor = [UIColor blackColor].CGColor;
        avatarImageView.layer.borderWidth = 0.5f;
        avatarImageView.layer.cornerRadius = 1.0f;
        [self.contentView addSubview:avatarImageView];
        self.avatarImageView = avatarImageView;
        
        UIImageView *stateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_12red.png"]];
        stateImageView.frame = (CGRect){{5, 48}, {12, 12}};
        [self.contentView addSubview:stateImageView];
        self.stateImageView = stateImageView;
        
        UILabel *stateLabel = [[UILabel alloc] initWithFrame:(CGRect){{17, 48}, {40, 12}}];
        stateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        stateLabel.textColor = [UIColor blackColor];
        stateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:stateLabel];
        self.stateLabel = stateLabel;
    }
    return self;
}

+ (CGFloat)defaultCellHeight {
    return ceilf(5 + 40 + 15);
}

- (void)setPerson:(EFMapPerson *)person {
    if (_person == person)
        return;
    
    [self willChangeValueForKey:@"person"];
    
    if (_person) {
        _person = nil;
    }
    
    _person = person;
    [self _personDidChange];
    
    [self didChangeValueForKey:@"person"];
}

@end
