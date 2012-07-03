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

- (void) done{
    if(gatherplace){
        [(GatherViewController*)gatherview setPlace:gatherplace];
        [self dismissModalViewControllerAnimated:YES];
    }
    
    NSLog(@"%@",@"done");
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
        [APIPlace GetPlacesFromGoogleNearby:location.latitude lng:location.longitude delegate:self];
    }
    lng=location.longitude;
    lat=location.latitude;
}

- (void) reloadPlaceData:(NSArray*)places {
    [_places release];
    _places=places;
    [_tableView reloadData];
    [self addPinToMap];
}

- (void)dealloc {
    [locationManager release];
    [_places release];
    [_annotations release];
    [_tableView release];
    [placeedit release];
    [super dealloc];
}
- (void) addPinToMap{

    NSMutableArray *annotations=[[NSMutableArray alloc] initWithCapacity:[_places count]];
    int i=0;
    for(NSDictionary *place in _places)
    {
        CLLocationCoordinate2D location;
        
        location.latitude = [[place objectForKey:@"lat"] doubleValue];
        location.longitude = [[place objectForKey:@"lng"] doubleValue];
        PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[place objectForKey:@"title"]  description:[place objectForKey:@"description"]];
        annotation.index=i;
        [annotations addObject:annotation];
//        [map addAnnotation:annotation];
        [annotation release];
        i++;
    }
    if(_annotations!=nil){
    [map removeAnnotations:_annotations];
    [_annotations release];
        
    }
    _annotations=annotations;
    [map addAnnotations:_annotations];

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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	NSDictionary *place=[_places objectAtIndex:indexPath.row];
    
    if([place objectForKey:@"title"]!=nil)
        cell.textLabel.text = [place objectForKey:@"title"];
    if([place objectForKey:@"description"]!=nil);
    cell.detailTextLabel.text=[place objectForKey:@"description"];
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
    gatherplace=place;
    [self setRightButton:@"done" Selector:@selector(done)];
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
- (void) getPlace{
    if(CFAbsoluteTimeGetCurrent()-editinginterval>1.2)
    {
        [APIPlace GetPlacesFromGoogleByTitle:inputplace.text lat:lat lng:lng delegate:self];
    }
}
- (IBAction)textDidChange:(UITextField*)textField
{
    if([textField.text length]>2)
    {
        editinginterval=CFAbsoluteTimeGetCurrent();
        [self performSelector:@selector(getPlace) withObject:self afterDelay:1.2];
    }
    
    
}
- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector{
    rightbutton.title=title;
    [rightbutton setAction:aSelector];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if (response.statusCode == 200) {
        NSDictionary *body=[response.body objectFromJSONData];
        if([body isKindOfClass:[NSDictionary class]]) {
            NSString *status=[body objectForKey:@"status"];
            if(status!=nil &&[status isEqualToString:@"OK"])
            {
                NSArray *results=[body objectForKey:@"results"] ;
                NSMutableArray *local_results=[[NSMutableArray alloc] initWithCapacity:[results count]];
                for(NSDictionary *place in results)
                {
                    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[place objectForKey:@"name"],@"title",[place objectForKey:@"formatted_address"],@"description",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[place objectForKey:@"id"],@"external_id",@"google",@"provier",nil];
                    [local_results addObject:dict];
                }
                [self reloadPlaceData:local_results];
            }
        }
    }
    else {
        //Check Response Body to get Data!
    }
}
@end
