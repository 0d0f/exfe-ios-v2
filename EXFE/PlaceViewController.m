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
@synthesize gatherview;

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


    float tableviewx=map.frame.origin.x;
    float tableviewy=map.frame.origin.y+map.frame.size.height;
    float tableviewidth=map.frame.size.width;
    float tablevieheight=self.view.frame.size.height-tableviewy;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableviewx,tableviewy,tableviewidth,tablevieheight) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
   
    placeedit=[[EXPlaceEditView alloc] initWithFrame:CGRectMake(20, 20, 200, 100)];
    [placeedit setHidden:YES];
    [map addSubview:placeedit];

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
    if(meters<0 || meters>500)
    {
        NSLog(@"request new locate");
        [APIPlace GetPlacesFromGoogleNearby:location.latitude lng:location.longitude delegate:self];
    }
    NSLog(@"%f %f",location.latitude,location.longitude);
}

- (void) reloadPlaceData:(NSArray*)places {
    NSLog(@"reload");
    [_places release];
    _places=places;
    [_tableView reloadData];
    [self addPinToMap];
}

- (void)dealloc {
    [locationManager release];
    [_places release];
    [_tableView release];
    [placeedit release];
    [super dealloc];
}
- (void) addPinToMap{

    int i=0;
    for(NSDictionary *place in _places)
    {
        CLLocationCoordinate2D location;
        
        location.latitude = [[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
        location.longitude = [[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
        PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[place objectForKey:@"name"]  description:[place objectForKey:@"vicinity"]];
        annotation.index=i;
        [map addAnnotation:annotation];
        [annotation release];
        i++;
    }
}
#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    NSLog(@"number count");
    if(_places)
        return [_places count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"place suggest view";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	NSDictionary *place=[_places objectAtIndex:indexPath.row];
	cell.textLabel.text = [place objectForKey:@"name"];
    cell.detailTextLabel.text=[place objectForKey:@"vicinity"];
	
    return cell;
    
}

#pragma mark MKMapView delegate methods
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.pinColor = MKPinAnnotationColorGreen;
    annView.animatesDrop=TRUE;
    annView.canShowCallout = YES;
    annView.calloutOffset = CGPointMake(-5, 5);
//    annView.image = [UIImage imageNamed:@"arrow.png"];
    UIButton* butt = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    butt.tag=((PlaceAnnotation*)annotation).index;
    [butt addTarget:self action:@selector(selectOnMap:) forControlEvents: UIControlEventTouchUpInside];
    annView.rightCalloutAccessoryView = butt;
    
    [annView setEnabled:YES];
    
    return annView;
}
- (void) selectPlace:(int)index{
    NSDictionary *place=[_places objectAtIndex:index];
    [self addPlaceEdit:place];
    
//    [(GatherViewController*)gatherview setPlace:place];
//    [self dismissModalViewControllerAnimated:YES];
    
}
- (void) selectOnMap:(id) sender
{
    int index=((UIButton*)sender).tag;
    [self selectPlace:index];
}

- (void) addPlaceEdit:(NSDictionary*)place{
    
    if([place objectForKey:@"title"] !=nil && [place objectForKey:@"title"]!=[NSNull null])
        [placeedit setPlaceTitle:[place objectForKey:@"title"]];
    if([place objectForKey:@"description"]!=nil && [place objectForKey:@"description"]!=[NSNull null])
        [placeedit setPlaceDesc:[place objectForKey:@"description"]];
    [placeedit setHidden:NO];

    [placeedit becomeFirstResponder];    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectPlace:indexPath.row];
}
@end
