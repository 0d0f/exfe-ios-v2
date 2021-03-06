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
#import "NSDate+RouteXDateFormater.h"
#import "EFGradientView.h"
#import "Util.h"

#define kStateLabelNormalFrame      (CGRect){{5, 48}, {40, 12}}
#define kStateLabelMeterFrame       (CGRect){{17, 48}, {36, 12}}
#define kStateLabelTimestampFrame   (CGRect){{5, 48}, {40, 12}}
#define kGradientViewTag            (233)

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
        if (self.person.lastLocation) {
            NSDate *timestamp = self.person.lastLocation.timestamp;
            infoText = [timestamp formatedTimeIntervalFromNowMinutesUpTo90];
            self.stateImageView.hidden = YES;
            self.stateView.hidden = YES;
            self.meterLabel.hidden = YES;
            self.stateLabel.textAlignment = NSTextAlignmentCenter;
            self.stateLabel.frame = kStateLabelNormalFrame;
        } else {
            infoText = NSLocalizedString(@"Unknown", nil);
            self.stateImageView.hidden = YES;
            self.stateView.hidden = YES;
            self.meterLabel.hidden = YES;
            self.stateLabel.textAlignment = NSTextAlignmentCenter;
            self.stateLabel.frame = kStateLabelNormalFrame;
            self.stateLabel.text = infoText;
            [self.stateLabel sizeToFit];
            self.stateLabel.frame = (CGRect){{(CGRectGetWidth(self.frame) - CGRectGetWidth(self.stateLabel.frame)) * 0.5f, CGRectGetMinY(self.stateLabel.frame)}, self.stateLabel.frame.size};
        }
    } else {
        if (self.person.locationState == kEFMapPersonLocationStateArrival) {
            infoText = NSLocalizedString(@"Arrived", nil);
            self.stateImageView.hidden = YES;
            
            self.stateLabel.frame = kStateLabelMeterFrame;
            self.stateLabel.text = infoText;
            [self.stateLabel sizeToFit];
            self.stateLabel.frame = (CGRect){{CGRectGetMaxX(self.stateView.frame) + 2.0f, CGRectGetMinY(self.stateLabel.frame)}, self.stateLabel.frame.size};
            
            EFGradientView *gradientView = (EFGradientView *)[self.stateView viewWithTag:kGradientViewTag];
            gradientView.colors = @[[UIColor COLOR_RGB(0xCC, 0xCC, 0xCC)],
                                    [UIColor COLOR_RGB(0x7F, 0x7F, 0x7F)]];
            self.stateView.hidden = NO;
            self.meterLabel.hidden = YES;
            self.stateLabel.textAlignment = NSTextAlignmentLeft;
        } else if (self.person.locationState == kEFMapPersonLocationStateOnTheWay) {
            if (self.person.connectState == kEFMapPersonConnectStateOnline) {
                self.stateImageView.image = [UIImage imageNamed:@"map_arrow_14red.png"];
            } else if (self.person.connectState == kEFMapPersonConnectStateOffline) {
                self.stateImageView.image = [UIImage imageNamed:@"map_arrow_14g5.png"];
            }
            
            NSUInteger distance = (NSUInteger)self.person.distance;
            NSString *m = NSLocalizedString(@"m", nil);
            if (distance > 1000) {
                m = NSLocalizedString(@"km", nil);
                distance = distance / 1000;
                if (distance >= 99) {
                    distance = 99;
                    m = NSLocalizedString(@"+km", nil);
                }
            } else {
                if (distance > 10) {
                    distance = (distance / 10) * 10;
                }
            }
            
            infoText = [NSString stringWithFormat:@"%d", distance];
            
            self.stateLabel.frame = kStateLabelMeterFrame;
            self.stateLabel.text = infoText;
            [self.stateLabel sizeToFit];
            
            self.meterLabel.text = m;
            [self.meterLabel sizeToFit];
            CGRect meterLabelFrame = self.meterLabel.frame;
            meterLabelFrame.origin = (CGPoint){CGRectGetMaxX(self.stateLabel.frame), CGRectGetMinY(self.stateLabel.frame) + 2.0f};
            self.meterLabel.frame = meterLabelFrame;
            
            self.stateImageView.layer.transform = CATransform3DMakeRotation(self.person.angle, 0.0f, 0.0f, 1.0f);
            self.stateImageView.hidden = NO;
            self.meterLabel.hidden = NO;
            self.stateView.hidden = YES;
            self.stateLabel.textAlignment = NSTextAlignmentRight;
        } else {
            if (self.person.lastLocation) {
                if (self.person.connectState == kEFMapPersonConnectStateOnline) {
                    infoText = NSLocalizedString(@"Online", nil);
                    
                    EFGradientView *gradientView = (EFGradientView *)[self.stateView viewWithTag:kGradientViewTag];
                    gradientView.colors = @[[UIColor COLOR_RGB(0xFF, 0x7E, 0x98)],
                                            [UIColor COLOR_RGB(0xE5, 0x2E, 0x53)]];
                    
                    self.stateView.hidden = NO;
                    self.stateImageView.hidden = YES;
                    self.meterLabel.hidden = YES;
                    self.stateLabel.textAlignment = NSTextAlignmentLeft;
                    self.stateLabel.frame = (CGRect){{CGRectGetMaxX(self.stateView.frame) + 2.0f, CGRectGetMinY(self.stateLabel.frame)}, self.stateLabel.frame.size};
                } else {
                    NSDate *timestamp = self.person.lastLocation.timestamp;
                    NSString *value = [timestamp formatedTimeIntervalValueFromNowMinutesUpTo90];
                    NSString *unit = [timestamp formatedTimeIntervalUnitFromNowMinutesUpTo90];
                    
                    infoText = value;
                    
                    self.stateLabel.frame = kStateLabelTimestampFrame;
                    self.stateLabel.text = infoText;
                    [self.stateLabel sizeToFit];
                    
                    self.meterLabel.text = unit;
                    [self.meterLabel sizeToFit];
                    CGRect meterLabelFrame = self.meterLabel.frame;
                    meterLabelFrame.origin = (CGPoint){CGRectGetMaxX(self.stateLabel.frame), CGRectGetMinY(self.stateLabel.frame) + 2.0f};
                    self.meterLabel.frame = meterLabelFrame;
                    
                    self.stateImageView.hidden = YES;
                    self.meterLabel.hidden = NO;
                    self.stateView.hidden = YES;
                    self.stateLabel.textAlignment = NSTextAlignmentRight;
                }
            } else {
                infoText = NSLocalizedString(@"Unknown", nil);
                self.stateImageView.hidden = YES;
                self.stateView.hidden = YES;
                self.meterLabel.hidden = YES;
                self.stateLabel.textAlignment = NSTextAlignmentCenter;
                self.stateLabel.frame = kStateLabelNormalFrame;
                [self.stateLabel sizeToFit];
                self.stateLabel.frame = (CGRect){{(CGRectGetWidth(self.frame) - CGRectGetWidth(self.stateLabel.frame)) * 0.5f, CGRectGetMinY(self.stateLabel.frame)}, self.stateLabel.frame.size};
            }
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
        avatarImageView.layer.cornerRadius = 2.0f;
        avatarImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:avatarImageView];
        self.avatarImageView = avatarImageView;
        
        UIImageView *avatarBaseImageView = [[UIImageView alloc] initWithFrame:(CGRect){{3.0f, 3.0f}, {44.0f, 44.0f}}];
        avatarBaseImageView.image = [UIImage imageNamed:@"portrait_frame_40.png"];
        avatarBaseImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:avatarBaseImageView];
        self.avatarBaseImageView = avatarBaseImageView;
        
        UIImageView *stateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_arrow_12red.png"]];
        stateImageView.frame = (CGRect){{3, 47}, {14, 14}};
        [self.contentView addSubview:stateImageView];
        self.stateImageView = stateImageView;
        
        UIView *stateView = [[UIView alloc] initWithFrame:(CGRect){{7, 50}, {7, 7}}];
        stateView.layer.cornerRadius = 3.5;
        stateView.layer.masksToBounds = YES;
        
        EFGradientView *gradientView = [[EFGradientView alloc] initWithFrame:stateView.bounds];
        gradientView.tag = kGradientViewTag;
        [stateView addSubview:gradientView];
        
        [self.contentView addSubview:stateView];
        self.stateView = stateView;
        self.stateView.hidden = YES;
        
        UILabel *stateLabel = [[UILabel alloc] initWithFrame:kStateLabelNormalFrame];
        stateLabel.textAlignment = NSTextAlignmentCenter;
        stateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        stateLabel.textColor = [UIColor blackColor];
        stateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:stateLabel];
        self.stateLabel = stateLabel;
        
        UILabel *meterLabel = [[UILabel alloc] initWithFrame:kStateLabelNormalFrame];
        meterLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
        meterLabel.textColor = [UIColor blackColor];
        meterLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:meterLabel];
        self.meterLabel = meterLabel;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

#pragma mark - Gesture

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    UIGestureRecognizerState state = gesture.state;
    
    if (UIGestureRecognizerStateEnded == state) {
        if ([self.delegate respondsToSelector:@selector(mapPersonCellSingleTapHappened:)]) {
            [self.delegate mapPersonCellSingleTapHappened:self];
        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gesture {
    UIGestureRecognizerState state = gesture.state;
    
    if (UIGestureRecognizerStateEnded == state) {
        if ([self.delegate respondsToSelector:@selector(mapPersonCellDoubleTapHappened:)]) {
            [self.delegate mapPersonCellDoubleTapHappened:self];
        }
    }
}

#pragma mark -

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
