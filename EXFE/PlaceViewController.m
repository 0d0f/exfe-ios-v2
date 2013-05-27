//
//  PlaceViewController.m
//  EXFE
//
//  Created by huoju on 6/26/12.
//
//

#import "PlaceViewController.h"

#import "EFAPI.h"

@interface PlaceViewController ()

@end

@implementation PlaceViewController
@synthesize delegate;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"EDIT_PLACE"];
    self.customPlace = [NSMutableDictionary dictionaryWithCapacity:10];
    self.placeResults = [NSMutableArray arrayWithCapacity:20];

    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.view addSubview:toolbar];

    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(Close) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:btnBack];

    
    UIImageView *inputframeview=[[UIImageView alloc] initWithFrame:CGRectMake(28, 7, 229, 31)];
    inputframeview.image=[UIImage imageNamed:@"textfield.png"];
    inputframeview.contentMode    = UIViewContentModeScaleToFill;
    inputframeview.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:inputframeview];
    [inputframeview release];
    
    inputplace=[[UITextField alloc] initWithFrame:CGRectMake(54, 13.5, 195-18, 18.5)];
    inputplace.tag=401;
    inputplace.placeholder=@"Search place";
    [inputplace setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    inputplace.delegate=self;
    [inputplace setAutocorrectionType:UITextAutocorrectionTypeNo];
    [inputplace setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    inputplace.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    [inputplace setBackgroundColor:[UIColor clearColor]];
    [toolbar addSubview:inputplace];
    inputplace.text=@"";
    
    UIImageView *icon=[[UIImageView alloc] initWithFrame:CGRectMake(33, 13.5, 18, 18)];
    icon.image=[UIImage imageNamed:@"place_18.png"];
    [toolbar addSubview:icon];
    [icon release];

    rightbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightbutton setFrame:CGRectMake(265, 7, 50, 30)];
    [rightbutton setTitle:@"Done" forState:UIControlStateNormal];
    [rightbutton setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0,3)] forState:UIControlStateNormal];
    [rightbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];

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
    placeedit=[[EXPlaceEditView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 110)];
    placeedit.PlaceTitle.tag=402;
    [placeedit setHidden:YES];
    [map addSubview:placeedit];

    if(self.selecetedPlace == nil) {
      
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSEntityDescription *placeEntity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
        self.selecetedPlace = [[[Place alloc] initWithEntity:placeEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext] autorelease];
        self.selecetedPlace.title = @"";
        self.selecetedPlace.place_description = @"";
        self.selecetedPlace.lat = @"";
        self.selecetedPlace.lng = @"";
        self.selecetedPlace.external_id = @"";
        self.selecetedPlace.provider = @"";

    } else{

        if (self.selecetedPlace.title == nil) {
            self.selecetedPlace.title = @"";
        }
        if (self.selecetedPlace.place_description == nil) {
            self.selecetedPlace.place_description = @"";
        }
        if (self.selecetedPlace.lat == nil) {
            self.selecetedPlace.lat = @"";
        }
        if (self.selecetedPlace.lng == nil) {
            self.selecetedPlace.lng = @"";
        }
        if (self.selecetedPlace.external_id == nil) {
            self.selecetedPlace.external_id = @"";
        }
        if (self.selecetedPlace.provider == nil) {
            self.selecetedPlace.provider = @"";
        }
        
//        [originplace setObject:self.selecetedPlace.external_id forKey:@"external_id"];
//        [originplace setObject:self.selecetedPlace.lat forKey:@"lat"];
//        [originplace setObject:self.selecetedPlace.lng forKey:@"lng"];
//        [originplace setObject:self.selecetedPlace.place_description forKey:@"place_description"];
//        [originplace setObject:self.selecetedPlace.provider forKey:@"provider"];
//        [originplace setObject:self.selecetedPlace.title forKey:@"title"];
        showtableview = NO;
        [self initPlaceView];
    }
    
    // TODO PLACEID
    if([self.selecetedPlace.place_id intValue]==0){
       // place.place_id=[NSNumber numberWithInt:-[((NewGatherViewController*)gatherview).cross.cross_id intValue]];
    }

    float tableviewx=map.frame.origin.x;
    float tableviewy=map.frame.origin.y+map.frame.size.height;
    float tableviewidth=map.frame.size.width;
    float tablevieheight=self.view.frame.size.height-tableviewy;

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableviewx,tableviewy,tableviewidth,tablevieheight) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
   
    actionsheet=[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear place" otherButtonTitles:nil, nil];
    
    [self regEvent];
    
    clearbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [clearbutton setFrame:CGRectMake(238-6, 13, 18, 18)];
    [clearbutton addTarget:self action:@selector(clearplace) forControlEvents:UIControlEventTouchUpInside];
    [clearbutton setImage:[UIImage imageNamed:@"textfield_clear.png"] forState:UIControlStateNormal];
    [self.view addSubview:clearbutton];
    
    if([inputplace.text length] > 1){
        [clearbutton setHidden:NO];
    } else if([inputplace.text isEqualToString:@""] || self.selecetedPlace ==nil){
        [clearbutton setHidden:YES];
    }
    [inputplace setReturnKeyType:UIReturnKeySearch];
    map.showsUserLocation = YES;

    [_tableView setHidden:YES];
    [map setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
    mapShadow = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4)];
    [mapShadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow_4up.png"]]];
    [map addSubview:mapShadow];
    
    if(showtableview==YES){
        [self setViewStyle:EXPlaceViewStyleBigTableview];
        [inputplace becomeFirstResponder];
    }    
}

- (void) initPlaceView{
    CLLocationCoordinate2D location;
    location.latitude = [self.selecetedPlace.lat doubleValue];
    location.longitude = [self.selecetedPlace.lng doubleValue];
    
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:self.selecetedPlace.title description:self.selecetedPlace.place_description];
    annotation.external_id = self.selecetedPlace.external_id;
    
    annotation.index = -2;
    // custome place
    if ([self.selecetedPlace hasGeo]){
        [map addAnnotation:annotation];
        PlaceAnnotation *mapannotation = [[map annotations] objectAtIndex:0];
        MKAnnotationView* annoview = [map viewForAnnotation: mapannotation];
        annoview.image=[UIImage imageNamed:@"map_pin_blue.png"];
    }
    [annotation release];
    
    
    CLLocationCoordinate2D mapcenter =location;
    mapcenter.latitude=mapcenter.latitude-0.0040;
    
    MKCoordinateRegion region;
    region.center = mapcenter;
    float delta = 0.02;
    if (![self.selecetedPlace hasGeo]){
        delta=120;
        CLLocationCoordinate2D location_center;
        location_center.latitude =33.431441;
        location_center.longitude =-41.484375;
        region.center=location_center;
        [self setViewStyle:EXPlaceViewStyleMap];
    }
    region.span.longitudeDelta = delta;
    region.span.latitudeDelta = delta;
    [map setRegion:region animated:YES];
    inputplace.text=@"";
    
    if (self.selecetedPlace != nil){
        [self showEdit:self.selecetedPlace];
    }
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
    longpress.minimumPressDuration = 1.0;
    [map addGestureRecognizer:longpress];
    [longpress release];
    
//    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
//    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
//        UITouch * touch = [touches anyObject];
//        if (!CGRectContainsPoint([placeedit frame], [touch locationInView:map]))
//        {
//            [placeedit resignFirstResponder];
//        }
//        [self setViewStyle:EXPlaceViewStyleMap];
//    };
//    [map addGestureRecognizer:tapInterceptor];
//    [tapInterceptor release];
}


- (void) PlaceEditClose:(id) sender{
}

- (void) Close{
    [self dismissModalViewControllerAnimated:YES];
}


- (void) setViewStyle:(EXPlaceViewStyle)style{
    if(style== EXPlaceViewStyleDefault){
        
    } else if(style== EXPlaceViewStyleMap){
        [inputplace resignFirstResponder];
        [UIView animateWithDuration:0.25
                         animations:^{
                             [_tableView setHidden:YES];
                             [map setFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
                             mapShadow.frame = CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4);
                         }
                         completion:^(BOOL finished) {

//                             [map becomeFirstResponder];
                         }];
        
    } else if(style== EXPlaceViewStyleTableview){
        [map deselectAnnotation:[map.selectedAnnotations objectAtIndex:0] animated:YES];
        
        [_tableView setHidden:NO];
        [placeedit setHidden:YES];
        [placeedit resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,85)];
        mapShadow.frame = CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4);
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
        mapShadow.frame = CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4);
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+140, _tableView.frame.size.width, self.view.frame.size.height-44-140)];
        [UIView commitAnimations];
        
    } else if(style== EXPlaceViewStyleEdit){
        [_tableView setHidden:NO];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,self.view.frame.size.height-44-216)];
        mapShadow.frame = CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4);
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+85, _tableView.frame.size.width, self.view.frame.size.height-44-85)];
        [UIView commitAnimations];
        
    }else if(style==EXPlaceViewStyleShowPlaceDetail){
        [_tableView setHidden:NO];
        [placeedit setHidden:YES];
        [placeedit resignFirstResponder];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,140)];
        mapShadow.frame = CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4);
        [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 44+140, _tableView.frame.size.width, self.view.frame.size.height-44-140)];
        [UIView commitAnimations];
    }
}
- (void) setPlace:(Place*)place isedit:(BOOL)editstate{
    self.selecetedPlace = place;
    isedit = editstate;
}

- (void) maplongpress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [gestureRecognizer locationInView:map];
        CLLocationCoordinate2D touchMapCoordinate =[map convertPoint:touchPoint toCoordinateFromView:map];
        [self addCustomAnnotation:touchMapCoordinate];
    }
}

- (void) addCustomAnnotation:(CLLocationCoordinate2D)location{
    [map removeAnnotations: map.annotations];
    BOOL newPlace = NO;
    if(![self.selecetedPlace hasTitle]){
        self.selecetedPlace.title = @"Right there on the map";
        [placeedit setPlaceTitleText:@"Right there on the map"];
    }
    
    if(![self.selecetedPlace hasDescription]) {
        [placeedit setPlaceDescText:@""];
        newPlace = YES;
    }
    
    [placeedit setHidden:NO];
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:self.selecetedPlace.title description:self.selecetedPlace.place_description];
    if ([[map annotations] count] == 0) {
        annotation.index = -2;
        // custome place
    }
    [map addAnnotation:annotation];
    [annotation release];
    [clearbutton setHidden:YES];
    
    self.selecetedPlace.lat = [NSString stringWithFormat:@"%f",annotation.coordinate.latitude];
    self.selecetedPlace.lng = [NSString stringWithFormat:@"%f",annotation.coordinate.longitude];
    self.selecetedPlace.provider = @"";
    
    if (newPlace) {
        // fill address by location
#warning should be rewrited.
        [[EFAPIServer sharedInstance] getTopPlaceNearbyWithLocation:annotation.coordinate
                                                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                                    NSDictionary *body = (NSDictionary*)responseObject;
                                                                    if ([body isKindOfClass:[NSDictionary class]]) {
                                                                        NSString *status = [body objectForKey:@"status"];
                                                                        if (status != nil &&[status isEqualToString:@"OK"]) {
                                                                            NSArray *results = [body objectForKey:@"results"];
                                                                            if ([results count] > 0) {
                                                                                NSDictionary *p = [results objectAtIndex:0];
                                                                                if ([results count] > 1)
                                                                                    p = [results objectAtIndex:1];
                                                                                
                                                                                NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:[p objectForKey:@"name"],@"title",[p objectForKey:@"vicinity"],@"description",[[[p objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[p objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[p objectForKey:@"id"],@"external_id",@"google",@"provider", nil] autorelease];
                                                                                [self fillTopPlace:dict];
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                            }];
    }
}

- (void) fillTopPlace:(NSDictionary*)topPlace{
    placeedit.PlaceDesc.text =[topPlace objectForKey:@"description"];
    self.selecetedPlace.place_description=[topPlace objectForKey:@"description"];
    [placeedit setNeedsDisplay];
}

- (void) done{
    
    if (placeedit.hidden) {
        // 
    } else {
        self.selecetedPlace.title = placeedit.PlaceTitle.text;
        self.selecetedPlace.place_description = placeedit.PlaceDesc.text;
    }
    
    [delegate setPlace:self.selecetedPlace];
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
    if( (isedit == NO && self.selecetedPlace == nil) || isaddnew == YES) {
        MKCoordinateRegion region;
        region.center = location;
        region.span.longitudeDelta = 0.02;
        region.span.latitudeDelta = 0.02;
        [map setRegion:region animated:YES];
        
        CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        if (meters < 0 || meters > 500) {
            [self searchNearByPlaces:location];
        }
    }
    lng = location.longitude;
    lat = location.latitude;
}

- (void)searchNearByPlaces:(CLLocationCoordinate2D)location
{
    
    [[EFAPIServer sharedInstance] getPlacesNearbyWithLocation:location
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                          if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                              NSDictionary *body = (NSDictionary*)responseObject;
                                                              if ([body isKindOfClass:[NSDictionary class]]) {
                                                                  NSString *status = [body objectForKey:@"status"];
                                                                  if (status != nil && [status isEqualToString:@"OK"]) {
                                                                      NSArray *results = [body objectForKey:@"results"];
                                                                      
                                                                      [self reloadPlaceData:results withKeyword:nil];
                                                                  }
                                                              }
                                                          }
                                                      }
                                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                      }];
    
}

- (void) reloadPlaceData:(NSArray*)results withKeyword:(NSString*)keyword{
    
    NSString *inputText = inputplace.text;
    
    if (keyword == nil || [keyword isEqualToString:inputText]) {
        
        [self.customPlace removeAllObjects];
        if (keyword != nil) {
            [self.customPlace setValue:keyword forKey:@"title"];
        }
        
        [self.placeResults removeAllObjects];
        [self saveResultsFromGooglePlaceAPI:results];
        [_tableView reloadData];
        
        if (keyword != nil) {
            [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        [self drawMapAnnontations:self.placeResults];
        
        if (keyword != nil) {
            if (self.placeResults.count > 0) {
                [self selectPlace:[self.placeResults objectAtIndex:0]];
            }
        }
        [self setViewStyle:EXPlaceViewStyleShowPlaceDetail];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];

    [locationManager release];
    self.placeResults = nil;
    self.customPlace = nil;
    [_tableView release];
    [placeedit release];
    [actionsheet release];
    [mapShadow release];
    [inputplace release];
    [super dealloc];
}

- (void) drawMapAnnontations:(NSArray *)places{
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:self.placeResults.count];
    int i = 0;
    for (NSDictionary *placedict in places) {
        
        CLLocationCoordinate2D location;
        
        location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
        location.longitude = [[placedict objectForKey:@"lng"] doubleValue];
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[placedict objectForKey:@"title"]  description:[placedict objectForKey:@"description"]];
        annotation.external_id = [placedict objectForKey:@"external_id"];
        annotation.index = i;
        [annotations addObject:annotation];
        [annotation release];
        i++;
    }
    [map removeAnnotations:map.annotations];
    [map addAnnotations:annotations];
}

- (void) drawMapAnnontation:(NSDictionary*)placedict{
    CLLocationCoordinate2D location;
    
    location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
    location.longitude = [[placedict objectForKey:@"lng"] doubleValue];
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[placedict valueForKey:@"title"]  description:[placedict valueForKey:@"description"]];
    annotation.external_id = [placedict valueForKey:@"external_id"];
    annotation.index = 0;
    
    [map removeAnnotations:map.annotations];
    [map addAnnotation:annotation];
    
    CLLocationCoordinate2D location2 = location;
    location2.latitude = location2.latitude - 0.0040;
    [map setCenterCoordinate:location2 animated:YES];
    [annotation release];
}

- (void) clearplace{
    isnotinputplace = YES;
    [self storeSelectedPlace:nil];
    
    [map removeAnnotations:[map annotations]];
    [placeedit setHidden:YES];
    [placeedit resignFirstResponder];
    [inputplace becomeFirstResponder];
    inputplace.text = @"";
    [clearbutton setHidden:YES];
    
    isnotinputplace = NO;
    self.placeResults = nil;
    [self.customPlace removeAllObjects];
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
        self.selecetedPlace = nil;
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
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
            [self selectPlace:self.customPlace];
            [self setViewStyle:EXPlaceViewStyleShowPlaceDetail];
            break;
            
        case 1:
            [self selectPlace:[self.placeResults objectAtIndex:indexPath.row]];
            [self setViewStyle:EXPlaceViewStyleShowPlaceDetail];
            break;
        default:
            break;
    }
    
}

#pragma mark UITableView Datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:{
            NSString *title = [self.customPlace valueForKey:@"title"];
            if (title.length > 0 ) {
                return 1;
            } else {
                return 0;
            }
        }   break;
            
        case 1:
            return self.placeResults.count;
            break;
        default:
            return 0;
            break;
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    
    switch (section) {
        case 0:
            [self editPlace:self.customPlace];
            break;
         
        case 1:
            [self editPlace:[self.placeResults objectAtIndex:indexPath.row]];
            [self drawMapAnnontation:[self.placeResults objectAtIndex:indexPath.row]];
            break;
        default:
            break;
    }
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
    
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:{
            [[cell textLabel] setTextColor:FONT_COLOR_HL];
            cell.textLabel.text = [self.customPlace valueForKey:@"title"];
            cell.detailTextLabel.text = @"No place found. Tap arrow to edit.";
        }
            break;
        case 1:{
            NSDictionary *placedict =[self.placeResults objectAtIndex:indexPath.row];
            if ([placedict objectForKey:@"title"] != nil) {
                cell.textLabel.text = [placedict objectForKey:@"title"];
            } else {
                cell.textLabel.text = @"";
            }
            if ([placedict objectForKey:@"description"] != nil){
                cell.detailTextLabel.text = [placedict objectForKey:@"description"];
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
            break;
        default:
            break;
    }
    return cell;
    
}

#pragma mark MKMapView delegate methods

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    MKAnnotationView* annotationView = [mapView viewForAnnotation:userLocation];
//    annotationView.canShowCallout = NO;
//    
//}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{

    if ([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    MKAnnotationView *annView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    annView.canShowCallout = YES;
    
    if ([((PlaceAnnotation*)annotation).external_id isEqualToString:self.selecetedPlace.external_id]) {
        annView.image = [UIImage imageNamed:@"drawMapAnnontations"];
    } else {
        annView.image = [UIImage imageNamed:@"map_pin_red.png"];
    }
    [annView setCenterOffset:CGPointMake(0, -12)];
    UIButton* butt = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    butt.tag = ((PlaceAnnotation*)annotation).index;
    [butt addTarget:self action:@selector(editVenue:) forControlEvents: UIControlEventTouchUpInside];
    annView.rightCalloutAccessoryView = butt;
    [annView setEnabled:YES];
    return annView;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    if ([view.annotation isKindOfClass:[MKUserLocation class]]){
        [self addCustomAnnotation:((MKUserLocation*)view.annotation).location.coordinate];
    }
    
    if ([view.annotation isKindOfClass:[PlaceAnnotation class]]) {
        NSArray *annotations = [map annotations];
        if ([annotations count] > 0) {
            for(int i = 0;i < [annotations count];i++){
                id annotation = [annotations objectAtIndex:i];
                MKAnnotationView* annoview = [mapView viewForAnnotation: annotation];
                if([annoview.image isEqual:[UIImage imageNamed:@"map_pin_blue.png"]]){
                    annoview.image = [UIImage imageNamed:@"map_pin_red.png"];
                }
            }
        }
        
        view.image = [UIImage imageNamed:@"map_pin_blue.png"];
//
        PlaceAnnotation *annot = view.annotation;
//        if (annot.index == -2){
//            // custome place
//            [self selectPlace:annot.index editing:YES];
//            return;
//        }
        [self storeSelectedPlace:[self.placeResults objectAtIndex:annot.index]];
        
        [self setViewStyle:EXPlaceViewStyleMap];
        
//        CLLocationCoordinate2D location;
//        location.latitude = [self.selecetedPlace.lat doubleValue];
//        location.longitude = [self.selecetedPlace.lng doubleValue];
//        [map setCenterCoordinate:location animated:YES];
//        [map selectAnnotation:annot animated:NO];

    }
}


- (void)storeSelectedPlace:(NSDictionary *)place
{
    if (place == nil) {
        self.selecetedPlace.title = @"";
        self.selecetedPlace.place_description = @"";
        self.selecetedPlace.lat = @"";
        self.selecetedPlace.lng = @"";
        self.selecetedPlace.external_id = @"";
        self.selecetedPlace.provider =@"";
    } else {
        self.selecetedPlace.title = [place valueForKey:@"title"];
        self.selecetedPlace.place_description = [place valueForKey:@"description"];
        
        id value = [place valueForKey:@"lat"];
        if (value != nil) {
            self.selecetedPlace.lat = [[place valueForKey:@"lat"] stringValue];
        } else {
            self.selecetedPlace.lat = @"";
        }
        value = [place valueForKey:@"lng"];
        if (value != nil) {
            self.selecetedPlace.lng = [[place valueForKey:@"lng"] stringValue];
        } else {
            self.selecetedPlace.lng = @"";
        }
        self.selecetedPlace.external_id = [place valueForKey:@"external_id"];
        self.selecetedPlace.provider = [place valueForKey:@"provider"];
    }
}

- (void)selectPlace:(NSDictionary *)placedict
{
    isedit = NO;
   
    [self storeSelectedPlace:placedict];
    
    
    NSArray *annotations = [map annotations];
    
    for (PlaceAnnotation* annotation in annotations){
        if([annotation isKindOfClass:[PlaceAnnotation class]]){
            MKAnnotationView* annoview = [map viewForAnnotation: annotation];
            if([annotation.external_id isEqualToString:self.selecetedPlace.external_id]){
                annoview.image=[UIImage imageNamed:@"map_pin_blue.png"];
                [annoview.superview bringSubviewToFront:annoview];
                [annoview bringSubviewToFront:map];
            } else {
                annoview.image=[UIImage imageNamed:@"map_pin_red.png"];
            }
        }
    }
    
    if ([self.selecetedPlace hasGeo]) {
        CLLocationCoordinate2D location;
        location.latitude = [self.selecetedPlace.lat doubleValue];
        location.longitude = [self.selecetedPlace.lng doubleValue];
        CGPoint p = [map convertCoordinate:location toPointToView:map];
        p.y -= 10; // move pin 10 points down
        CLLocationCoordinate2D newCenter = [map convertPoint:p toCoordinateFromView:map];
        [map setCenterCoordinate:newCenter animated:YES];
    }
    
    return;
}

- (void) editPlace:(NSDictionary *)placedict
{
    isedit = YES;
}

- (void) selectPlace:(int)index editing:(BOOL)editing{
    CLLocationCoordinate2D location;
    location.latitude=0;
    location.longitude=0;
    isedit = editing;
    if(index==-2) {
        // cutome place
        NSArray *annotations=[map annotations];
        if([annotations count]>0) {
            PlaceAnnotation *annotation=[annotations objectAtIndex:0];
            self.selecetedPlace.title=annotation.place_title;
            self.selecetedPlace.place_description=annotation.place_description;
            self.selecetedPlace.lat=[NSString stringWithFormat:@"%f",annotation.coordinate.latitude];
            self.selecetedPlace.lng=[NSString stringWithFormat:@"%f",annotation.coordinate.longitude];
            self.selecetedPlace.external_id=@"";
            self.selecetedPlace.provider=@"";

            [self showEdit:self.selecetedPlace];
            location.latitude = annotation.coordinate.latitude;
            location.longitude = annotation.coordinate.longitude;

            MKAnnotationView* annoview = [map viewForAnnotation: annotation];
            annoview.image=[UIImage imageNamed:@"map_pin_blue.png"];
        }
    }else if(index==-1){
        self.selecetedPlace.title=inputplace.text;
        self.selecetedPlace.place_description=@"";
        self.selecetedPlace.lat=@"";
        self.selecetedPlace.lng=@"";
        self.selecetedPlace.external_id=@"";
        self.selecetedPlace.provider=@"";
        placeedit.PlaceTitle.text=self.selecetedPlace.title;
        placeedit.PlaceDesc.text=@"";
    }else{
        NSDictionary *placedict = [self.placeResults objectAtIndex:index];
        [self storeSelectedPlace:placedict];
        [self showEdit:self.selecetedPlace];
        location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
        location.longitude = [[placedict objectForKey:@"lng"] doubleValue];

        NSArray *annotations = [map annotations];

        for (PlaceAnnotation* annotation in annotations){
            if([annotation isKindOfClass:[PlaceAnnotation class]]){
                MKAnnotationView* annoview = [map viewForAnnotation: annotation];
                if([annotation.external_id isEqualToString:self.selecetedPlace.external_id]){
                    annoview.image=[UIImage imageNamed:@"map_pin_blue.png"];
                    [annoview.superview bringSubviewToFront:annoview];
                    [annoview bringSubviewToFront:map];
                } else {
                    annoview.image=[UIImage imageNamed:@"map_pin_red.png"];
                }
            }
        }
        
        float delta = 0.02;
        
        CLLocationCoordinate2D newll;
        MKCoordinateRegion region;
        newll.latitude = [self.selecetedPlace.lat doubleValue];
        newll.longitude = [self.selecetedPlace.lng doubleValue];
        region.center = newll;
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
        
        CLLocationCoordinate2D mapcenter = location;
        mapcenter.latitude = mapcenter.latitude - 0.0040;
        
        [map setRegion:region animated:YES];
        [placeedit setHidden:NO];
        [placeedit becomeFirstResponder];
        return;
    }
//        MKCoordinateRegion region;
//        region.center = location;
//        region.span.longitudeDelta = 0.02;
//        region.span.latitudeDelta = 0.02;
//        [map setRegion:region animated:YES];
//    
//    if(editing==YES){
    
        [self setViewStyle:EXPlaceViewStyleMap];
        float delta=0.02;
        
        CLLocationCoordinate2D newll;// =[map convertPoint:point toCoordinateFromView:map];
        MKCoordinateRegion region;
        newll.latitude=[self.selecetedPlace.lat doubleValue];
        newll.longitude=[self.selecetedPlace.lng doubleValue];
        if(location.latitude==0 && location.longitude==0 && index==-1)
        {
            delta=120;
            newll.latitude =33.431441;
            newll.longitude =-41.484375;
        }
        region.center = newll;
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
    
        CLLocationCoordinate2D mapcenter =location;
        mapcenter.latitude=mapcenter.latitude-0.0040;

        [map setRegion:region animated:NO];
        [placeedit setHidden:NO];
        [placeedit becomeFirstResponder];
//    }
//
}

- (void)editVenue:(id) sender
{
    int index = ((UIButton*)sender).tag;
    id<MKAnnotation> anno = [map.selectedAnnotations objectAtIndex:0];
    
    [map deselectAnnotation:anno animated:YES];
    NSMutableArray *array = [NSMutableArray arrayWithArray:map.annotations];
    [array removeObject:anno];
    [map removeAnnotations:array];
    
    MKAnnotationView* annoview = [map viewForAnnotation: anno];
    annoview.image = [UIImage imageNamed:@"map_pin_blue.png"];
    annoview.canShowCallout = NO;
    [annoview.superview bringSubviewToFront:annoview];
    [annoview bringSubviewToFront:map];
    
    CLLocationCoordinate2D location;
    location.latitude=0;
    location.longitude=0;
    
    NSDictionary *placedict = [self.placeResults objectAtIndex:index];
    [self storeSelectedPlace:placedict];
    
    location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
    location.longitude = [[placedict objectForKey:@"lng"] doubleValue];
    
    CLLocationCoordinate2D mapcenter = location;
    mapcenter.latitude = mapcenter.latitude - 0.0040;
    
    [map setCenterCoordinate:mapcenter animated:YES];
    
    [self showEdit:self.selecetedPlace];
}

- (void) showEdit:(Place*)place{
    [placeedit setPlaceTitleText:self.selecetedPlace.title];
    [placeedit setPlaceDescText:self.selecetedPlace.place_description];
    [placeedit setHidden:NO];
    [placeedit becomeFirstResponder];
}

- (void) saveResultsFromGooglePlaceAPI:(NSArray*)results{
    if ([results count] > 0) {
        NSDictionary *dict = [results objectAtIndex:0];
        NSNumber *_lng = [[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
        NSNumber *_lat = [[[dict objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
        MKCoordinateRegion region;
        float delta = 0.02;
        CLLocationCoordinate2D location_center;
        location_center.latitude = [_lat doubleValue];
        location_center.longitude = [_lng doubleValue];
        region.center = location_center;
        region.span.longitudeDelta = delta;
        region.span.latitudeDelta = delta;
        [map setRegion:region animated:YES];
    }
    NSMutableArray *local_results=[[NSMutableArray alloc] initWithCapacity:[results count]] ;
    for(NSDictionary *placedict in results)
    {
        NSString *_name=[placedict objectForKey:@"name"];
        if (_name == nil) {
            _name=@"";
        }
        NSString *_formatted_address=[placedict objectForKey:@"formatted_address"];
        if (_formatted_address == nil){
            _formatted_address = [placedict objectForKey:@"vicinity"];
            if(_formatted_address == nil) {
                _formatted_address = @"";
            }
        }
        NSString *_lng = [[[placedict objectForKey: @"geometry"] objectForKey:@"location"] objectForKey: @"lng"];
        if (_lng == nil) {
            _lng = @"";
        }
        NSString *_lat = [[[placedict objectForKey: @"geometry"] objectForKey:@"location"] objectForKey: @"lat"];
        if(_lat == nil) {
            _lat = @"";
        }
        NSString *_id = [placedict objectForKey:@"id"];
        if (_id == nil) {
            _id = @"";
        }
        
        NSDictionary * dict = @{@"title":_name, @"description":_formatted_address, @"lng":_lng, @"lat":_lat, @"external_id":_id, @"provider":@"google"};
        [local_results addObject:dict];
    }
    [self.placeResults addObjectsFromArray:local_results];
}

- (void)searchPlaceByKeyword:(NSString*)keyword near:(CLLocationCoordinate2D)location{
    [[EFAPIServer sharedInstance] getPlacesByTitle:keyword
                                          location:location
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                   NSDictionary *body = (NSDictionary*)responseObject;
                                                   if ([body isKindOfClass:[NSDictionary class]]) {
                                                       NSString *status = [body objectForKey:@"status"];
                                                       if (status != nil && [status isEqualToString:@"OK"]) {
                                                           NSArray *results = [body objectForKey:@"results"];
                                                           [self reloadPlaceData:results withKeyword:keyword];
                                                       }
                                                   }
                                               }
                                           }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           }];
}

- (void) getPlace:(NSString *)keyword{
    if (CFAbsoluteTimeGetCurrent() - editinginterval > 0.8) {
        [self searchPlaceByKeyword: keyword near:CLLocationCoordinate2DMake(lat, lng)];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self searchPlaceByKeyword: inputplace.text near:CLLocationCoordinate2DMake(lat, lng)];
    [inputplace resignFirstResponder];
    return YES;
}

- (void)textDidChange:(NSNotification*)notification
{
    if (isnotinputplace == YES){
        return;
    }
    
    UITextField *textField = (UITextField*) notification.object;
    if (textField.tag == 401){
        if (textField.text.length > 0) {
            // search by keywords
            editinginterval = CFAbsoluteTimeGetCurrent();
            
            [self performSelector:@selector(getPlace:) withObject:textField.text afterDelay:0.8];
            
        } else {
            [clearbutton setHidden:NO];
            // search nearby
            [self searchNearByPlaces:CLLocationCoordinate2DMake(lat, lng)];
        }
    }
    
    if (textField.tag == 402){
        //place title editor
        if (textField.text.length == 0) {
            // remove selected
            
            
            [self clearplace];
        }
    }

}
- (void) editingDidBegan:(NSNotification*)notification{
    willUserScroll=YES;
//    UITextField *textField=(UITextField*)notification.object;

    [self setViewStyle:EXPlaceViewStyleTableview];
//    [textField becomeFirstResponder];
    
}
- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector{
    [rightbutton setTitle:title forState:UIControlStateNormal];
    [rightbutton addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
}

@end
