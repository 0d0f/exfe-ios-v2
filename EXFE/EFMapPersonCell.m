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
#import "EFCache.h"

@interface EFMapPersonCell ()

@property (nonatomic, strong) UIView *stateView;

@end

@interface EFMapPersonCell (Private)
- (void)_personDidChange;
@end

@implementation EFMapPersonCell (Private)

- (void)_personDidChange {
    [[EFDataManager imageManager] loadImageForView:self.avatarImageView
                                  setImageSelector:@selector(setImage:)
                                       placeHolder:[UIImage imageNamed:@"portrait_default.png"]
                                               key:self.person.avatarName
                                   completeHandler:nil];
    
    NSString *infoText = nil;
    if (self.person.connectState == kEFMapPersonConnectStateUnknow) {
        infoText = NSLocalizedString(@"方位?", nil);
        self.stateImageView.hidden = YES;
        
        self.stateView.layer.backgroundColor = [UIColor colorWithRed:(127.0f / 255.0f) green:(127.0f / 255.0f) blue:(127.0f / 255.0f) alpha:1.0f].CGColor;
        self.stateView.hidden = NO;
    } else {
        if (self.person.locationState == kEFMapPersonLocationStateArrival) {
            infoText = NSLocalizedString(@"抵达", nil);
            self.stateImageView.hidden = YES;
            
            self.stateView.layer.backgroundColor = [UIColor colorWithRed:(229.0f / 255.0f) green:(49.0f / 255.0f) blue:(83.0f / 255.0f) alpha:1.0f].CGColor;
            self.stateView.hidden = NO;
        } else if (self.person.locationState == kEFMapPersonLocationStateOnTheWay) {
            if (self.person.connectState == kEFMapPersonConnectStateOnline) {
                self.stateImageView.image = [UIImage imageNamed:@"map_arrow_14red.png"];
            } else if (self.person.connectState == kEFMapPersonConnectStateOffline) {
                self.stateImageView.image = [UIImage imageNamed:@"map_arrow_14g5.png"];
            }
            
            NSUInteger distance = (NSUInteger)self.person.distance;
            NSString *m = @"米";
            if (distance > 1000) {
                m = @"公里";
                distance = distance / 1000;
                if (distance >= 9) {
                    distance = 9;
                    m = @"+公里";
                }
            } else {
                if (distance > 10) {
                    distance = (distance / 10) * 10;
                }
            }
            
            infoText = [NSString stringWithFormat:NSLocalizedString(@"%d%@", nil), distance, m];
            self.stateImageView.layer.transform = CATransform3DMakeRotation(self.person.angle, 0.0f, 0.0f, 1.0f);
            self.stateImageView.hidden = NO;
            self.stateView.hidden = YES;
        } else {
            infoText = NSLocalizedString(@"方位?", nil);
            self.stateImageView.hidden = YES;
            
            self.stateView.layer.backgroundColor = [UIColor colorWithRed:(127.0f / 255.0f) green:(127.0f / 255.0f) blue:(127.0f / 255.0f) alpha:1.0f].CGColor;
            self.stateView.hidden = NO;
        }
    }
    
    self.stateLabel.text = infoText;
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
        avatarImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:avatarImageView];
        self.avatarImageView = avatarImageView;
        
        UIImageView *stateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_12red.png"]];
        stateImageView.frame = (CGRect){{5, 48}, {14, 14}};
        [self.contentView addSubview:stateImageView];
        self.stateImageView = stateImageView;
        
        UIView *stateView = [[UIView alloc] initWithFrame:(CGRect){{7, 50}, {7, 7}}];
        stateView.layer.cornerRadius = 3.5;
        [self.contentView addSubview:stateView];
        self.stateView = stateView;
        self.stateView.hidden = YES;
        
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
    [self willChangeValueForKey:@"person"];
    
    _person = person;
    [self _personDidChange];
    
    [self didChangeValueForKey:@"person"];
}

@end
