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

    if(gatherplace==nil)
    {
        gatherplace=[[NSMutableDictionary alloc] init];
    }
    else{
        CLLocationCoordinate2D location;
        location.latitude =[[gatherplace objectForKey:@"lat"] doubleValue];
        location.longitude =[[gatherplace objectForKey:@"lng"] doubleValue];
        
        PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[gatherplace objectForKey:@"title"]  description:[gatherplace objectForKey:@"description"]];
        annotation.index=-1;
        [map addAnnotation:annotation];
        [annotation release];

        MKCoordinateRegion region;
        
        region.center = location;
        region.span.longitudeDelta = 0.02;
        region.span.latitudeDelta = 0.02;
        [map setRegion:region animated:YES];

    }
    float tableviewx=map.frame.origin.x;
    float tableviewy=map.frame.origin.y+map.frame.size.height;
    float tableviewidth=map.frame.size.width;
    float tablevieheight=self.view.frame.size.height-tableviewy;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableviewx,tableviewy,tableviewidth,tablevieheight) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
   
    placeedit=[[EXPlaceEditView alloc] initWithFrame:CGRectMake(10, 5, 280, 120)];
    [placeedit setHidden:YES];
    [map addSubview:placeedit];
    actionsheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:nil, nil];
    
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maplongpress:)];
    longpress.minimumPressDuration = 1;
    [map addGestureRecognizer:longpress];
    [longpress release];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        UITouch * touch = [touches anyObject];
        if (!CGRectContainsPoint([placeedit frame], [touch locationInView:map]))
        {
            [placeedit setHidden:YES];
            [placeedit resignFirstResponder];
        }
        
        
        if (CGRectContainsPoint([placeedit getCloseButtonFrame], [touch locationInView:map]))
        {
            [actionsheet showInView:self.view];
        }
        [self setViewStyle:EXPlaceViewStyleMap];
    };
    [map addGestureRecognizer:tapInterceptor];
    [tapInterceptor release];
}

- (void) PlaceEditClose:(id) sender{
    NSLog(@"place edit close");
}
- (void) setViewStyle:(EXPlaceViewStyle)style{
    if(style== EXPlaceViewStyleDefault){
        
    } else if(style== EXPlaceViewStyleMap){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.view.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
        [UIView commitAnimations];
        [inputplace resignFirstResponder];
        
        
        [map becomeFirstResponder];
        
    } else if(style== EXPlaceViewStyleTableview){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,230)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+85, _tableView.frame.size.width, self.view.frame.size.height-44-85)];
        [UIView commitAnimations];
        
    } else if(style== EXPlaceViewStyleEdit){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,self.view.frame.size.height-44-216)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, map.frame.size.height+44, _tableView.frame.size.width, self.view.frame.size.height-44-85)];
        [UIView commitAnimations];
        
    }
}
- (void) setPlace:(Place*)_place{
    if(gatherplace==nil)
            gatherplace=[[NSMutableDictionary alloc] init];
    [gatherplace setObject:_place.title forKey:@"title"];
    [gatherplace setObject:_place.place_description forKey:@"description"];
    [gatherplace setObject:_place.lat forKey:@"lat"];
    [gatherplace setObject:_place.lng forKey:@"lng"];
    [gatherplace setObject:_place.external_id forKey:@"external_id"];
    [gatherplace setObject:_place.provider forKey:@"provider"];
    isedit=YES;
    
}
- (void) maplongpress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
    }
    else {
        CGPoint touchPoint = [gestureRecognizer locationInView:map];
        CLLocationCoordinate2D touchMapCoordinate =
        [map convertPoint:touchPoint toCoordinateFromView:map];
        [map removeAnnotations: map.annotations];
        PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:touchMapCoordinate withTitle:@"Somewhere" description:@""];
        if([[map annotations] count]==0)
            annotation.index=-1;
        [map addAnnotation:annotation];
        [annotation release];
    }
}

- (IBAction) Close:(id) sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) done{
//    [gatherplace objectForKey:@"title"]
//    [gatherplace objectForKey:@"description"]
    if(gatherplace){
        NSString *provider=[gatherplace objectForKey:@"provider"];
        if(provider==nil)
           provider=@"exfe";
           
        NSDictionary *place =[NSDictionary dictionaryWithKeysAndObjects:@"title",[placeedit getPlaceTitle],@"description",[placeedit getPlaceDesc], @"lat",[gatherplace objectForKey:@"lat"],@"lng",[gatherplace objectForKey:@"lng"],@"provider",provider,@"external_id",[gatherplace objectForKey:@"external_id"], nil];

        [(GatherViewController*)gatherview setPlace:place];
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        
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
    if(isedit==NO)
    {
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
    }
    lng=location.longitude;
    lat=location.latitude;
}

- (void) reloadPlaceData:(NSArray*)places {
    [_places release];
    _places=places;
    [_tableView reloadData];
    [self drawMapAnnontations];
}

- (void)dealloc {
    [locationManager release];
    [_places release];
    [_annotations release];
    [_tableView release];
    [placeedit release];
    [actionsheet release];
    [super dealloc];
}
//- (void) addNewPin{
//    
//}
- (void) drawMapAnnontations{

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

#pragma mark UIActionSheetDelegate delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        [placeedit setHidden:YES];
        [placeedit resignFirstResponder];
        [map removeAnnotations:[map annotations]];
        [gatherplace setObject:@"" forKey:@"title"];
        [gatherplace setObject:@"" forKey:@"description"];
        [gatherplace setObject:[NSNumber numberWithInt:0] forKey:@"lat"];
        [gatherplace setObject:[NSNumber numberWithInt:0] forKey:@"lng"];
        [gatherplace setObject:@"" forKey:@"external_id"];
        [gatherplace setObject:@"" forKey:@"provider"];
        
    }
    NSLog(@"click %u",buttonIndex);
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
    CLLocationCoordinate2D location;

    if(index==-1)
    {
        NSArray *annotations=[map annotations];
        if([annotations count]>0)
        {
            PlaceAnnotation *annotation=[annotations objectAtIndex:0];

            [gatherplace setObject:annotation.place_title forKey:@"title"];
            [gatherplace setObject:annotation.place_description forKey:@"description"];
            [gatherplace setObject:[NSNumber numberWithDouble:annotation.coordinate.latitude] forKey:@"lat"];
            [gatherplace setObject:[NSNumber numberWithDouble:annotation.coordinate.longitude] forKey:@"lng"];
            [gatherplace setObject:@"" forKey:@"external_id"];
            [gatherplace setObject:@"exfe" forKey:@"provider"];
            [self addPlaceEdit:gatherplace];
//            lat=annotation.coordinate.latitude;
//            lng=annotation.coordinate.longitude;
            location.latitude = annotation.coordinate.latitude;
            location.longitude = annotation.coordinate.longitude;

        }
    }else{
        NSDictionary *place=[_places objectAtIndex:index];
        [gatherplace setObject:[place objectForKey:@"title"] forKey:@"title"];
        [gatherplace setObject:[place objectForKey:@"description"] forKey:@"description"];
        [gatherplace setObject:[place objectForKey:@"lat"] forKey:@"lat"];
        [gatherplace setObject:[place objectForKey:@"lng"] forKey:@"lng"];
        [gatherplace setObject:[place objectForKey:@"external_id"] forKey:@"external_id"];
        [gatherplace setObject:[place objectForKey:@"provider"] forKey:@"provider"];
        [self addPlaceEdit:gatherplace];

        location.latitude = [[place objectForKey:@"lat"] doubleValue];
        location.longitude = [[place objectForKey:@"lng"] doubleValue];

    }
    [self setViewStyle:EXPlaceViewStyleMap];

    CGPoint point=[map convertCoordinate:location toPointToView:map];
    CGPoint mapcenter=[map convertCoordinate:map.region.center toPointToView:map];
    if(point.y<mapcenter.y)
    {
        float moveto_y=placeedit.frame.origin.y+placeedit.frame.size.height-30;
        float offset=moveto_y-point.y;
        mapcenter.y=mapcenter.y-moveto_y-offset;
    }
    else
    {
        float moveto_y=placeedit.frame.origin.y+placeedit.frame.size.height-30;
        float offset=point.y-moveto_y;

        mapcenter.y=mapcenter.y-moveto_y+offset;
    }
    CLLocationCoordinate2D newll =[map convertPoint:mapcenter toCoordinateFromView:map];
    
    MKCoordinateRegion region;
    region.center = newll;
    region.span.longitudeDelta = 0.02;
    region.span.latitudeDelta = 0.02;
    [map setRegion:region animated:YES];
    
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
- (IBAction)editingDidBegan:(UITextField*)textField{
    [self setViewStyle:EXPlaceViewStyleTableview];
    [textField becomeFirstResponder];
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
                    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[place objectForKey:@"name"],@"title",[place objectForKey:@"formatted_address"],@"description",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[place objectForKey:@"id"],@"external_id",@"google",@"provider",nil];
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
