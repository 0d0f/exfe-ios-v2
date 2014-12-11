//
//  EFGeomarkGroupViewController.h
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import <UIKit/UIKit.h>

@class EFGeomarkGroupViewController, EFRouteLocation, EFMapPerson;
@protocol EFGeomarkGroupViewControllerDelegate <NSObject>

@optional

- (void)geomarkGroupViewController:(EFGeomarkGroupViewController *)controller didSelectRouteLocation:(EFRouteLocation *)routeLocation;
- (void)geomarkGroupViewController:(EFGeomarkGroupViewController *)controller didSelectPerson:(EFMapPerson *)person;

@end

@class EFMarauderMapDataSource;
@interface EFGeomarkGroupViewController : UITableViewController
<
UIGestureRecognizerDelegate
>

@property (nonatomic, weak) id<EFGeomarkGroupViewControllerDelegate> delegate;
@property (nonatomic, readonly) UIViewController    *fromViewController;
@property (nonatomic, readonly) CGPoint             tapLocation;

@property (nonatomic, strong) NSArray   *geomarks;
@property (nonatomic, strong) NSArray   *people;

@property (nonatomic, weak) EFMarauderMapDataSource *mapDataSource;

- (id)initWithGeomarks:(NSArray *)geomarks andPeople:(NSArray *)people;

- (void)presentFromViewController:(UIViewController *)controller tapLocation:(CGPoint)locatoin animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end
