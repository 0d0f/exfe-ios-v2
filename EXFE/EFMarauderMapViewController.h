//
//  EFViewController.h
//  MarauderMap
//
//  Created by 0day on 13-7-3.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "EFTabBarViewController.h"
#import "EFMapKit.h"
#import "EFMarauderMapDataSource.h"
#import "EFMapStrokeView.h"

typedef enum {
    kEFMapZoomTypeUnknow = 0,
    kEFMapZoomTypePersonAndDestination,
    kEFMapZoomTypePersonLocation
} EFMapZoomType;

@class EFMapPerson, EXFEModel, Cross;

@interface EFMarauderMapViewController : UIViewController
<
UIGestureRecognizerDelegate,
CLLocationManagerDelegate,
MKMapViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
EFTabBarDataSource,
EFMapViewDelegate,
EFMarauderMapDataSourceDelegate,
EFMapStrokeViewDataSource,
UIAlertViewDelegate
>

@property (nonatomic, weak)     EXFEModel               *model;
@property (nonatomic, weak)     Cross                   *cross;

@property (weak, nonatomic)     IBOutlet EFMapView      *mapView;
@property (weak, nonatomic)     IBOutlet UIView         *leftBaseView;
@property (weak, nonatomic)     IBOutlet UITableView    *selfTableView;
@property (weak, nonatomic)     IBOutlet UITableView    *tableView;
@property (nonatomic, weak)     EFMapStrokeView         *mapStrokeView;

// EFTabBarDataSource
@property (nonatomic, strong)   EFTabBarItem            *customTabBarItem;
@property (nonatomic, assign)   EFTabBarStyle           tabBarStyle;
@property (nonatomic, weak)     EFTabBarViewController  *tabBarViewController;
@property (nonatomic, copy)     UIImage                 *shadowImage;
@property (nonatomic, assign)   CGRect                  initFrame;

- (IBAction)parkButtonPressed:(id)sender;
- (IBAction)headingButtonPressed:(id)sender;
- (IBAction)cleanButtonPressed:(id)sender;

@end
