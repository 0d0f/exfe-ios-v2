//
//  PlaceViewController.m
//  EXFE
//
//  Created by huoju on 6/26/12.
//
//

#import "PlaceViewController.h"

@interface PlaceViewController ()

@end

@implementation PlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 100.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];
    
}

- (IBAction) Close:(id) sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;

    MKCoordinateRegion region;

    region.center = location;
    region.span.longitudeDelta = 0.02;
    region.span.latitudeDelta = 0.02;
    [map setRegion:region animated:YES];
    
    CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
    if(meters>500)
    {
        NSLog(@"request new locate");
    }
    
    NSLog(@"%f %f",location.latitude,location.longitude);
}
- (void)dealloc {
    [locationManager release];
    [super dealloc];
}
@end
