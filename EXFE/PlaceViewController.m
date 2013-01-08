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
@synthesize showdetailview;
@synthesize isaddnew;
@synthesize showtableview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)regObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:inputplace];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegan:) name:UITextFieldTextDidBeginEditingNotification object:inputplace];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:placeedit.PlaceTitle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:placeedit.PlaceDesc];
}

- (void)regEvent
{
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maplongpress:)];
    longpress.minimumPressDuration = 0.610;
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
        [self setViewStyle:EXPlaceViewStyleMap];
    };
    [map addGestureRecognizer:tapInterceptor];
    [tapInterceptor release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    originplace=[[NSMutableDictionary alloc] initWithCapacity:5];
    
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]]];
    [self.view addSubview:toolbar];
    
    backgroundview=[[UIView alloc] initWithFrame:CGRectMake(6, 7, 255, 30)];
    backgroundview.backgroundColor=[UIColor whiteColor];
    backgroundview.layer.cornerRadius=15;

    [toolbar addSubview:backgroundview];
    inputplace=[[UITextField alloc] initWithFrame:CGRectMake(10+10+10, 7, 240-44-2-10+44, 30)];
    inputplace.tag=401;
    [inputplace setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    inputplace.delegate=self;
    [inputplace setAutocorrectionType:UITextAutocorrectionTypeNo];
    [inputplace setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    inputplace.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    [inputplace setBackgroundColor:[UIColor clearColor]];
    [toolbar addSubview:inputplace];
    UIImageView *icon=[[UIImageView alloc] initWithFrame:CGRectMake(6+4, 13, 18, 18)];
    icon.image=[UIImage imageNamed:@"place_18.png"];
    [toolbar addSubview:icon];
    [icon release];

    if(place!=nil) {
        revert=[UIButton buttonWithType:UIButtonTypeCustom];
        [revert setFrame:CGRectMake(210, 13, 44, 19)];
        revert.backgroundColor=[UIColor colorWithRed:191/255.0f green:191/255.0f blue:191/255.0f alpha:1.00f];
        [revert setTitle:@"Revert" forState:UIControlStateNormal];
        [revert.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:10]];
        revert.layer.cornerRadius=10;
        revert.layer.masksToBounds=YES;
        [revert setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [revert addTarget:self action:@selector(doRevert:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:revert];
        [inputplace setFrame:CGRectMake(10+10+10, 7, 240-44-2-10, 30)];
    }
    
    rightbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightbutton setFrame:CGRectMake(265, 7, 50, 30)];
    [rightbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [rightbutton setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
    [rightbutton setBackgroundImage:[[UIImage imageNamed:@"btn_dark.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];
    [rightbutton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:rightbutton];
    
    [self regObserver];
    
    CGRect inputframe=backgroundview.frame;
    inputbackgroundImage = [[UIImageView alloc] initWithFrame:inputframe];
    inputbackgroundImage.image = [UIImage imageNamed:@"textfield_navbar_frame.png"];
    inputbackgroundImage.contentMode    = UIViewContentModeScaleToFill;
    inputbackgroundImage.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:inputbackgroundImage];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 100.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    [locationManager startUpdatingLocation];
    placeedit=[[EXPlaceEditView alloc] initWithFrame:CGRectMake(13, 5, 294, 124)];
    [placeedit setHidden:YES];
    [map addSubview:placeedit];

    if(place==nil) {
        place=[Place object];
        place.title=@"";
        place.place_description=@"";
        place.lat=@"";
        place.lng=@"";

    }
    else{
        [originplace setObject:place.external_id forKey:@"external_id"];
        [originplace setObject:place.lat forKey:@"lat"];
        [originplace setObject:place.lng forKey:@"lng"];
        [originplace setObject:place.place_description forKey:@"place_description"];
        [originplace setObject:place.provider forKey:@"provider"];
        [originplace setObject:place.title forKey:@"title"];
        
        [self initPlaceView];
    }
    if([place.place_id intValue]==0)
        place.place_id=[NSNumber numberWithInt:-[((NewGatherViewController*)gatherview).cross.cross_id intValue]];

    float tableviewx=map.frame.origin.x;
    float tableviewy=map.frame.origin.y+map.frame.size.height;
    float tableviewidth=map.frame.size.width;
    float tablevieheight=self.view.frame.size.height-tableviewy;

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableviewx,tableviewy,tableviewidth,tablevieheight) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
   
    actionsheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles:nil, nil];
    
    [self regEvent];
    
    clearbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [clearbutton setFrame:CGRectMake(238, 13, 18, 18)];
    [clearbutton addTarget:self action:@selector(clearplace) forControlEvents:UIControlEventTouchUpInside];
    [clearbutton setImage:[UIImage imageNamed:@"textfield_clear.png"] forState:UIControlStateNormal];
    [self.view addSubview:clearbutton];
    
    if([inputplace.text length]>1){
        [clearbutton setHidden:NO];
        [revert setHidden:YES];
    }else if([inputplace.text isEqualToString:@""] || place==nil){
        [clearbutton setHidden:YES];
        [revert setHidden:YES];
    }
    [inputplace setReturnKeyType:UIReturnKeySearch];
    map.showsUserLocation = YES;
//    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+self.view.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
    [_tableView setHidden:YES];
    [map setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];

    if(showtableview==YES){
        [self setViewStyle:EXPlaceViewStyleBigTableview];
        [inputplace becomeFirstResponder];
    }
    
//
}

- (void) initPlaceView{
    CLLocationCoordinate2D location;
    location.latitude =[place.lat doubleValue];
    location.longitude =[place.lng doubleValue];
    PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:place.title description:place.place_description];
    annotation.external_id=place.external_id;
    
    annotation.index=-2;
    if(![place.lat isEqualToString:@""] && ![place.lng isEqualToString:@""]){
        [map addAnnotation:annotation];
        PlaceAnnotation *mapannotation=[[map annotations] objectAtIndex:0];
        MKAnnotationView* annoview = [map viewForAnnotation: mapannotation];
        annoview.image=[UIImage imageNamed:@"map_pin_blue.png"];
    }
    [annotation release];
    MKCoordinateRegion region;
    region.center = location;
    float delta=0.02;
    if([place.lat isEqualToString:@""] && [place.lng isEqualToString:@""]){
        delta=120;
        CLLocationCoordinate2D location_center;
        location_center.latitude =33.431441;
        location_center.longitude =-41.484375;
        region.center=location_center;
    }
    region.span.longitudeDelta = delta;
    region.span.latitudeDelta = delta;
    [map setRegion:region animated:YES];
    inputplace.text=place.title;
    
    if(showdetailview==YES){
        CGPoint point=[map convertCoordinate:location toPointToView:map];
        point.y+=18;
        CLLocationCoordinate2D newll =[map convertPoint:point toCoordinateFromView:map];
        MKCoordinateRegion region;
        region.center = newll;
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
        [map setRegion:region animated:YES];
        [self addPlaceEdit:place];
        [map becomeFirstResponder];
        [inputplace resignFirstResponder];
        [placeedit resignFirstResponder];
    }
}
- (void) PlaceEditClose:(id) sender{
}
- (void) setViewStyle:(EXPlaceViewStyle)style{
    if(style== EXPlaceViewStyleDefault){
        
    } else if(style== EXPlaceViewStyleMap){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [_tableView setHidden:YES];
//        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, self.view.frame.size.height, _tableView.frame.size.width, _tableView.frame.size.height)];
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
        [UIView commitAnimations];
        [inputplace resignFirstResponder];
        [map becomeFirstResponder];
    } else if(style== EXPlaceViewStyleTableview){
        [_tableView setHidden:NO];

        [placeedit setHidden:YES];
        [placeedit resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,85)];
//        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,230)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+85, _tableView.frame.size.width, self.view.frame.size.height-44-85)];
        [UIView commitAnimations];
    } else if(style== EXPlaceViewStyleBigTableview){
        [_tableView setHidden:NO];

        [placeedit setHidden:YES];
        [placeedit resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,140)];
//        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,230)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+140, _tableView.frame.size.width, self.view.frame.size.height-44-140)];
        [UIView commitAnimations];
        
    } else if(style== EXPlaceViewStyleEdit){
        [_tableView setHidden:NO];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,self.view.frame.size.height-44-216)];
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, map.frame.size.height+44, _tableView.frame.size.width, self.view.frame.size.height-44-85)];
        [UIView commitAnimations];
        
    }
}
- (void) setPlace:(Place*)_place isedit:(BOOL)editstate{
    place=_place;
    isedit=editstate;
    
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
            annotation.index=-2;
        [map addAnnotation:annotation];
        [annotation release];
        [clearbutton setHidden:YES];
        [revert setHidden:NO];
        [placeedit setPlaceTitleText:@"Somewhere"];
        [placeedit setPlaceDescText:@""];
    }
}

- (IBAction) doRevert:(id) sender{
    isnotinputplace=YES;
    [[Cross currentContext] rollback];
    [[Place currentContext] rollback];
    [self initPlaceView];
    [revert setHidden:YES];
    [clearbutton setHidden:NO];
    if(place==nil){
        [inputplace resignFirstResponder];
        [self setViewStyle:EXPlaceViewStyleTableview];
    }
    else{
        [inputplace resignFirstResponder];
        [placeedit becomeFirstResponder];
        [self setViewStyle:EXPlaceViewStyleEdit];
    }
    [map removeAnnotations:[map annotations]];
    [self initPlaceView];
//    CLLocationCoordinate2D location;
//    location.latitude = [place.lat doubleValue];
//    location.longitude = [place.lng doubleValue];
//    CGPoint point=[map convertCoordinate:location toPointToView:map];
//
//    float editheight=placeedit.frame.origin.y+placeedit.frame.size.height;
//    point.y+=(map.frame.size.height-editheight)/2-100;
//    CLLocationCoordinate2D newll =[map convertPoint:point toCoordinateFromView:map];
//    MKCoordinateRegion region;
//    region.center = newll;
//    float delta=0.02;
//    if([place.lat isEqualToString:@""] && [place.lng isEqualToString:@""]){
//        delta=120;
//        CLLocationCoordinate2D location_center;
//        location_center.latitude =33.431441;
//        location_center.longitude =-41.484375;
//        region.center=location_center;
//    }
//    region.span.longitudeDelta = delta;
//    region.span.latitudeDelta = delta;
//    [map setRegion:region animated:YES];
    isnotinputplace=NO;
    if(place==nil)
        [self setViewStyle:EXPlaceViewStyleTableview];
    else
        [self setViewStyle:EXPlaceViewStyleEdit];
}

- (void) done{
//    if(placeedit.hidden==NO){
//        place.title=[placeedit getPlaceTitleText];
//        place.place_description=[placeedit getPlaceDescText];
//    }
//    if(isedit==YES){
//       if([[originplace objectForKey:@"external_id"] isEqualToString:place.external_id] &&
//          [[originplace objectForKey:@"lat"] isEqualToString:place.lat] &&
//          [[originplace objectForKey:@"lng"] isEqualToString:place.lng] &&
//          [[originplace objectForKey:@"place_description"] isEqualToString:place.place_description] &&
//          [[originplace objectForKey:@"provider"] isEqualToString:place.provider] &&
//          [[originplace objectForKey:@"title"] isEqualToString:place.title]
//          ){
//           [(NewGatherViewController*)gatherview fillPlace:place];
//       }
//       else
//        [(NewGatherViewController*)gatherview fillPlace:place];
//    }
//    else
        [(NewGatherViewController*)gatherview setPlace:place];
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
    if( (isedit==NO && place==nil) || isaddnew==YES)
    {
        MKCoordinateRegion region;
        region.center = location;
        region.span.longitudeDelta = 0.02;
        region.span.latitudeDelta = 0.02;
        [map setRegion:region animated:YES];
        
        CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        if(meters<0 || meters>500)
        {
            [[APIPlace sharedManager] GetPlacesFromGoogleNearby:location.latitude lng:location.longitude delegate:self];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];

    [locationManager release];
    [_places release];
    [_annotations release];
    [_tableView release];
    [placeedit release];
    [actionsheet release];
    [originplace release];
    [super dealloc];
}

- (void) drawMapAnnontations{

    NSMutableArray *annotations=[[NSMutableArray alloc] initWithCapacity:[_places count]];
    int i=0;
    for(NSDictionary *placedict in _places)
    {
        CLLocationCoordinate2D location;
        
        location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
        location.longitude = [[placedict objectForKey:@"lng"] doubleValue];
        PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[placedict objectForKey:@"title"]  description:[placedict objectForKey:@"description"]];
        annotation.external_id=[placedict objectForKey:@"external_id"];
        annotation.index=i;
        [annotations addObject:annotation];
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

- (void) clearplace{
    isnotinputplace=YES;
    place.title=@"";
    place.place_description=@"";
    place.lat=@"";
    place.lng=@"";
    [map removeAnnotations:[map annotations]];
    [placeedit setHidden:YES];
    [placeedit resignFirstResponder];
    [inputplace becomeFirstResponder];
    inputplace.text=@"";
    [revert setHidden:NO];
    [clearbutton setHidden:YES];
    isnotinputplace=NO;
    [_tableView reloadData];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV;
    for (aV in views) {
        CGRect endFrame = aV.frame;
        
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 230.0, aV.frame.size.width, aV.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.45];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [aV setFrame:endFrame];
        [UIView commitAnimations];
        
    }
}

#pragma mark UIActionSheetDelegate delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        [placeedit setHidden:YES];
        [placeedit resignFirstResponder];
        [map removeAnnotations:[map annotations]];
        place=nil;
    }
}

#pragma mark UIScrollView methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(willUserScroll==YES){
        [inputplace resignFirstResponder];
        [_tableView becomeFirstResponder];
        [self setViewStyle:EXPlaceViewStyleBigTableview];
        willUserScroll=NO;
    }
}
#pragma mark UITableView Delegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tipline=0;
    if([inputplace.text length]>0)
        tipline=1;
//    isedit=YES;
    [self selectPlace:indexPath.row-tipline editing:NO];
    [self done];
}

#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    int tipline=0;
//    && ![inputplace.text isEqualToString:place.title]
    if([inputplace.text length]>0 )
        tipline=1;
    if(_places)
        return [_places count]+tipline;
    return tipline;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    int tipline=0;
    if([inputplace.text length]>0 )
        tipline=1;
    [self selectPlace:indexPath.row-tipline editing:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"place suggest view";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.backgroundColor=FONT_COLOR_250;
    [[cell textLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [[cell detailTextLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
    [[cell textLabel] setTextColor:FONT_COLOR_25];
    [[cell detailTextLabel] setTextColor:[UIColor colorWithRed:127/255.0f green:127/255.0f blue:127/255.0f alpha:1] ];

//    if([inputplace.text length]>0 && )
//        cell.textLabel.text=inputplace.text;
        if(indexPath.row==0 && [inputplace.text length]>0 )
        {
            [[cell textLabel] setTextColor:FONT_COLOR_HL];
            cell.textLabel.text=inputplace.text;
            cell.detailTextLabel.text=@"No place found. Tap arrow to edit.";
        }else{
            int hitline=0;
            if([inputplace.text length]>0){
                hitline=1;
            }
            NSDictionary *placedict=[_places objectAtIndex:indexPath.row-hitline];
            if([placedict objectForKey:@"title"]!=nil)
                cell.textLabel.text = [placedict objectForKey:@"title"];
            if([placedict objectForKey:@"description"]!=nil);
            cell.detailTextLabel.text=[placedict objectForKey:@"description"];
        }

    return cell;
    
}

#pragma mark MKMapView delegate methods
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{

    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    MKAnnotationView *annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annView.canShowCallout = YES;
    
    if([((PlaceAnnotation*)annotation).external_id isEqualToString:place.external_id])
            annView.image=[UIImage imageNamed:@"map_pin_blue.png"];
    else{
            annView.image=[UIImage imageNamed:@"map_pin_red.png"];
    }
    [annView setCenterOffset:CGPointMake(0, -12)];
    UIButton* butt = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    butt.tag=((PlaceAnnotation*)annotation).index;
    [butt addTarget:self action:@selector(selectOnMap:) forControlEvents: UIControlEventTouchUpInside];
    annView.rightCalloutAccessoryView = butt;
    [annView setEnabled:YES];
    return annView;
}
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    // Annotation is your custom class that holds information about the annotation
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        NSArray *annotations=[map annotations];
        if([annotations count]>0)
        {
            for(int i=0;i<[annotations count];i++){
                id annotation=[annotations objectAtIndex:i];
                MKAnnotationView* annoview = [mapView viewForAnnotation: annotation];
                if([annoview.image isEqual:[UIImage imageNamed:@"map_pin_blue.png"]]){
                    annoview.image=[UIImage imageNamed:@"map_pin_red.png"];
                }
            }
        }
        view.image=[UIImage imageNamed:@"map_pin_blue.png"];

        
        PlaceAnnotation *annot = view.annotation;
        if(annot.index==-2){
            [self selectPlace:annot.index editing:YES];
            return;
        }
        NSDictionary *placedict=[_places objectAtIndex:annot.index
];
        place.title=[placedict objectForKey:@"title"];
        place.place_description=[placedict objectForKey:@"description"];
        place.lat=[[placedict objectForKey:@"lat"] stringValue];
        place.lng=[[placedict objectForKey:@"lng"] stringValue];
        place.external_id=[placedict objectForKey:@"external_id"];
        place.provider=[placedict objectForKey:@"provider"];

    }
}
- (void) selectPlace:(int)index editing:(BOOL)editing{
    CLLocationCoordinate2D location;
    location.latitude=0;
    location.longitude=0;
    isedit=editing;
    if(index==-2)
    {
        NSArray *annotations=[map annotations];
        if([annotations count]>0)
        {
            PlaceAnnotation *annotation=[annotations objectAtIndex:0];
            place.title=annotation.place_title;
            place.place_description=annotation.place_description;
            place.lat=[NSString stringWithFormat:@"%f",annotation.coordinate.latitude];
            place.lng=[NSString stringWithFormat:@"%f",annotation.coordinate.longitude];
            place.external_id=@"";
            place.provider=@"exfe";

            [self addPlaceEdit:place];
            location.latitude = annotation.coordinate.latitude;
            location.longitude = annotation.coordinate.longitude;

            MKAnnotationView* annoview = [map viewForAnnotation: annotation];
            annoview.image=[UIImage imageNamed:@"map_pin_blue.png"];
        }

    }else if(index==-1){
        place.title=inputplace.text;
        place.place_description=@"";
        place.lat=@"";
        place.lng=@"";
        place.external_id=@"";
        place.provider=@"exfe";
    }else{
        NSDictionary *placedict=[_places objectAtIndex:index];
        place.title=[placedict objectForKey:@"title"];
        place.place_description=[placedict objectForKey:@"description"];
        place.lat=[[placedict objectForKey:@"lat"] stringValue];
        place.lng=[[placedict objectForKey:@"lng"] stringValue];
        place.external_id=[placedict objectForKey:@"external_id"];
        place.provider=[placedict objectForKey:@"provider"];
        [self addPlaceEdit:place];
        location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
        location.longitude = [[placedict objectForKey:@"lng"] doubleValue];

        NSArray *annotations=[map annotations];
        [map removeAnnotations:annotations];

        PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[placedict objectForKey:@"title"]  description:[placedict objectForKey:@"description"]];
        annotation.external_id=[placedict objectForKey:@"external_id"];
        annotation.index=index;
        [map addAnnotation:annotation];
    }
    
    if(editing==YES){
        
        [self setViewStyle:EXPlaceViewStyleMap];
        float delta=0.02;
        CGPoint point=[map convertCoordinate:location toPointToView:map];
        point.y+=18;
        
        CLLocationCoordinate2D newll;// =[map convertPoint:point toCoordinateFromView:map];
        MKCoordinateRegion region;
        newll.latitude=[place.lat doubleValue];
        newll.longitude=[place.lng doubleValue];
        if(location.latitude==0 && location.longitude==0 && index==-1)
        {
            delta=120;
//            CLLocationCoordinate2D location_center;
            newll.latitude =33.431441;
            newll.longitude =-41.484375;
        }
        region.center = newll;
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
        [map setRegion:region animated:YES];
        [placeedit setHidden:NO];
        [placeedit becomeFirstResponder];
    }
//
}

- (void) selectOnMap:(id) sender
{
    int index=((UIButton*)sender).tag;
    [self selectPlace:index editing:YES];
}

- (void) addPlaceEdit:(Place*)_place{
    if(_place.title !=nil )
        [placeedit setPlaceTitleText:place.title];
    if(_place.place_description!=nil)
        [placeedit setPlaceDescText:place.place_description];
    [placeedit setHidden:NO];
    [placeedit becomeFirstResponder];
}

- (void) getPlace{
    if(CFAbsoluteTimeGetCurrent()-editinginterval>0.8)
    {
        [[APIPlace sharedManager] GetPlacesFromGoogleByTitle:inputplace.text lat:lat lng:lng delegate:self];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [[APIPlace sharedManager] GetPlacesFromGoogleByTitle:inputplace.text lat:lat lng:lng delegate:self];
    return YES;
}
- (void)textDidChange:(NSNotification*)notification
{
    if(isnotinputplace==YES){
        return;
    }
    UITextField *textField=(UITextField*)notification.object;
    if([textField.text length]>2 && textField.tag==401)
    {
        editinginterval=CFAbsoluteTimeGetCurrent();
        [self performSelector:@selector(getPlace) withObject:self afterDelay:0.8];
    }
    if(![textField.text isEqualToString:@""] && ![textField.text isEqualToString:place.title] && place.title!=nil){
        [clearbutton setHidden:YES];
        [revert setHidden:NO];
    }
    
    [_tableView reloadData];

}
- (void) editingDidBegan:(NSNotification*)notification{
//    isedit=NO;
    willUserScroll=YES;
    UITextField *textField=(UITextField*)notification.object;
//    if(![textField.text isEqualToString:@""] && ![textField.text isEqualToString:place.title] && place.title!=nil){
//        [clearbutton setHidden:YES];
//        [revert setHidden:NO];
//    }
    
    
//    if([textField.text length]>2)
//        [self performSelector:@selector(getPlace) withObject:self];

    [self setViewStyle:EXPlaceViewStyleTableview];
    [textField becomeFirstResponder];
}
- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector{
    [rightbutton setTitle:title forState:UIControlStateNormal];
    [rightbutton addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];

}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    if (response.statusCode == 200) {
        NSDictionary *body=[response.body objectFromJSONData];
        if([body isKindOfClass:[NSDictionary class]]) {

            NSString *status=[body objectForKey:@"status"];
            if(status!=nil &&[status isEqualToString:@"OK"])
            {
                NSArray *results=[body objectForKey:@"results"] ;
                if([results count]>0)
                {
                    NSDictionary *dict=[results objectAtIndex:0];
                    NSNumber *_lng=[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
                    NSNumber *_lat=[[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
                    MKCoordinateRegion region;
                    float delta=0.02;
                    CLLocationCoordinate2D location_center;
                    location_center.latitude =[_lat doubleValue];
                    location_center.longitude =[_lng doubleValue];
                    region.center=location_center;
                    region.span.longitudeDelta = delta;
                    region.span.latitudeDelta = delta;
                    [map setRegion:region animated:YES];
                }
                NSMutableArray *local_results=[[NSMutableArray alloc] initWithCapacity:[results count]] ;
                for(NSDictionary *placedict in results)
                {
                    NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[placedict objectForKey:@"name"],@"title",[placedict objectForKey:@"formatted_address"],@"description",[[[placedict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[placedict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[placedict objectForKey:@"id"],@"external_id",@"google",@"provider",nil];
                    [local_results addObject:dict];
                    [dict release];
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
