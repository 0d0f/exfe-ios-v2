//
//  EFGeomarkLocationCell.m
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import "EFGeomarkLocationCell.h"

#import "EFRouteLocation.h"
#import "Util.h"

@interface EFGeomarkLocationCell ()

@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UILabel *locationDescriptionLabel;

@end

@interface EFGeomarkLocationCell (Private)

- (UIView *)_backgroundView;
- (UIView *)_selectedBackgroundView;

- (void)_routeLocationDidChange;

@end

@implementation EFGeomarkLocationCell (Private)

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

- (void)_routeLocationDidChange {
    if (self.routeLocation) {
        self.locationTitleLabel.text = self.routeLocation.title;
        self.locationDescriptionLabel.text = self.routeLocation.subtitle;
    } else {
        self.locationTitleLabel.text = nil;
        self.locationDescriptionLabel.text = nil;
    }
}

@end

@implementation EFGeomarkLocationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{6.0f, 5.0f}, {190.0f, 24.0f}}];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        titleLabel.shadowOffset = (CGSize){0.0f, 1.0f};
        [self.contentView addSubview:titleLabel];
        self.locationTitleLabel = titleLabel;
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:(CGRect){{6.0f, 27.0f}, {190.0f, 14.0f}}];
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        descriptionLabel.shadowOffset = (CGSize){0.0f, 1.0f};
        [self.contentView addSubview:descriptionLabel];
        self.locationDescriptionLabel = descriptionLabel;
        
        self.backgroundView = [self _backgroundView];
        self.selectedBackgroundView = [self _selectedBackgroundView];
    }
    return self;
}

#pragma mark - Property Accessor

- (void)setRouteLocation:(EFRouteLocation *)routeLocation {
    [self willChangeValueForKey:@"routeLocation"];
    
    _routeLocation = routeLocation;
    [self _routeLocationDidChange];
    
    [self didChangeValueForKey:@"routeLocation"];
}

@end
