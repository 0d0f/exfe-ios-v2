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

@class EFMapPerson;

@interface EFMarauderMapViewController : UIViewController
<
CLLocationManagerDelegate,
MKMapViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
EFTabBarDataSource
>

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet EFMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *operationBaseView;
@property (weak, nonatomic) IBOutlet UIButton *parkButton;
@property (weak, nonatomic) IBOutlet UIButton *headingButton;
@property (weak, nonatomic) IBOutlet UIButton *cleanButton;

// EFTabBarDataSource
@property (nonatomic, strong) EFTabBarItem *customTabBarItem;
@property (nonatomic, assign) EFTabBarStyle tabBarStyle;
@property (nonatomic, weak) EFTabBarViewController *tabBarViewController;
@property (nonatomic, copy) UIImage *shadowImage;
@property (nonatomic, assign) CGRect initFrame;

- (IBAction)parkButtonPressed:(id)sender;
- (IBAction)headingButtonPressed:(id)sender;
- (IBAction)cleanButtonPressed:(id)sender;

@end
