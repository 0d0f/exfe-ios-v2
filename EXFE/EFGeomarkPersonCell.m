//
//  EFGeomarkPersonCell.m
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import "EFGeomarkPersonCell.h"

#import <QuartzCore/QuartzCore.h>
#import "EFDataManager+Image.h"
#import "EFMapPerson.h"
#import "EFLocation.h"
#import "Util.h"
#import "EFMarauderMapDataSource.h"

@interface EFGeomarkPersonCell ()

@property (nonatomic, strong) UIImageView   *avatarImageView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *locationInfoLabel;

@end

@interface EFGeomarkPersonCell (Private)

- (UIView *)_backgroundView;
- (UIView *)_selectedBackgroundView;

- (void)_personDidChange;

@end

@implementation EFGeomarkPersonCell (Private)

- (UIView *)_backgroundView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    UIView *topLine = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {CGRectGetWidth(self.frame), 0.5f}}];
    topLine.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:(CGRect){{0.0f, CGRectGetHeight(self.frame) - 0.5f}, {CGRectGetWidth(self.frame), 0.5f}}];
    bottomLine.backgroundColor = [UIColor COLOR_RGB(0xCC, 0xCC, 0xCC)];
    [backgroundView addSubview:bottomLine];
    
    return backgroundView;
}

- (UIView *)_selectedBackgroundView {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [[UIColor COLOR_BLUE_EXFE] colorWithAlphaComponent:0.08f];
    
    UIView *topLine = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {CGRectGetWidth(self.frame), 0.5f}}];
    topLine.backgroundColor = [UIColor COLOR_RGB(0xCC, 0xCC, 0xCC)];
    [backgroundView addSubview:topLine];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:(CGRect){{0.0f, CGRectGetHeight(self.frame) - 0.5f}, {CGRectGetWidth(self.frame), 0.5f}}];
    bottomLine.backgroundColor = [UIColor whiteColor];
    [backgroundView addSubview:bottomLine];
    
    return backgroundView;
}

- (void)_personDidChange {
    if (self.person) {
        [[EFDataManager imageManager] loadImageForView:self.avatarImageView
                                      setImageSelector:@selector(setImage:)
                                           placeHolder:[UIImage imageNamed:@"portrait_default.png"]
                                                   key:self.person.avatarName
                                       completeHandler:nil];
        self.nameLabel.text = self.person.name;
        NSString *locationInfo = nil;
        
        CLLocationDistance distanceFromDest = self.person.distance;
        NSString *destUnit = NSLocalizedString(@"m", nil);
        if (distanceFromDest > 1000) {
            destUnit = NSLocalizedString(@"km", nil);
            distanceFromDest = distanceFromDest / 1000;
            if (distanceFromDest >= 99) {
                distanceFromDest = 99;
                destUnit = NSLocalizedString(@"+km", nil);
            }
        } else {
            if (distanceFromDest > 10) {
                distanceFromDest = (distanceFromDest / 10) * 10;
            }
        }
        
        NSString *distanceDestString = [NSString stringWithFormat:@"%ld%@", (long)distanceFromDest, destUnit];
        
        if (kEFMapPersonConnectStateOnline == self.person.connectState) {
            CLLocationDistance distanceFromMe = ceil([self.person.lastLocation distanceFromLocation:[self.mapDataSource me].lastLocation]);
            NSString *unit = NSLocalizedString(@"m", nil);
            
            if (distanceFromMe > 1000) {
                unit = NSLocalizedString(@"km", nil);
                distanceFromMe = distanceFromMe / 1000;
                if (distanceFromMe >= 99) {
                    distanceFromMe = 99;
                    unit = NSLocalizedString(@"+km", nil);
                }
            } else {
                if (distanceFromMe > 10) {
                    distanceFromMe = (distanceFromMe / 10) * 10;
                }
            }
            
            NSString *distanceString = [NSString stringWithFormat:@"%ld%@", (long)distanceFromMe, unit];
            
            locationInfo = [NSString stringWithFormat:NSLocalizedString(@"%1$@ to arrive, %2$@ apart", nil), distanceDestString, distanceString];
        } else {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.person.lastLocation.timestamp];
            NSInteger time = timeInterval / 60;
            BOOL isMinutes = YES;
            if (time / 60) {
                time = time / 60;
                isMinutes = NO;
            }
            locationInfo = [NSString stringWithFormat:NSLocalizedString(@"%d%@前 至目的地%@", nil), time, isMinutes ? @"分钟" : @"小时", distanceDestString];
        }
        
        self.locationInfoLabel.text = locationInfo;
    } else {
        self.avatarImageView.image = [UIImage imageNamed:@"portrait_default.png"];
        self.nameLabel.text = nil;
        self.locationInfoLabel.text = nil;
    }
}

@end

@implementation EFGeomarkPersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:(CGRect){{6.0f, 7.0f}, {30.0f, 30.0f}}];
        avatarImageView.layer.cornerRadius = 2.0f;
        avatarImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:avatarImageView];
        self.avatarImageView = avatarImageView;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:(CGRect){{38.0f, 5.0f}, {156.0f, 24.0f}}];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        nameLabel.shadowOffset = (CGSize){0.0f, 1.0f};
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        nameLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *locationInfoLabel = [[UILabel alloc] initWithFrame:(CGRect){{38.0f, 27.0f}, {156.0f, 14.0f}}];
        locationInfoLabel.backgroundColor = [UIColor clearColor];
        locationInfoLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        locationInfoLabel.shadowOffset = (CGSize){0.0f, 1.0f};
        locationInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        locationInfoLabel.textAlignment = NSTextAlignmentRight;
        locationInfoLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        [self.contentView addSubview:locationInfoLabel];
        self.locationInfoLabel = locationInfoLabel;
        
        self.backgroundView = [self _backgroundView];
        self.selectedBackgroundView = [self _selectedBackgroundView];
    }
    return self;
}

#pragma mark - Property Accessor

- (void)setPerson:(EFMapPerson *)person {
    [self willChangeValueForKey:@"person"];
    
    _person = person;
    [self _personDidChange];
    
    [self didChangeValueForKey:@"person"];
}

@end
