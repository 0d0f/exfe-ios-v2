//
//  EFGeomarkLocationCell.m
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import "EFGeomarkLocationCell.h"

#import "EFRouteLocation.h"

@interface EFGeomarkLocationCell ()

@property (nonatomic, strong) UILabel *locationTitleLabel;
@property (nonatomic, strong) UILabel *locationDescriptionLabel;

@end

@interface EFGeomarkLocationCell (Private)

- (void)_routeLocationDidChange;

@end

@implementation EFGeomarkLocationCell (Private)

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
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{8.0f, 5.0f}, {184.0f, 24.0f}}];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:titleLabel];
        self.locationTitleLabel = titleLabel;
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:(CGRect){{8.0f, 26.0f}, {184.0f, 14.0f}}];
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:descriptionLabel];
        self.locationDescriptionLabel = descriptionLabel;
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
