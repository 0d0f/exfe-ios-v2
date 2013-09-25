//
//  PlaceViewController.m
//  EXFE
//
//  Created by huoju on 6/26/12.
//
//

#import "PlaceViewController.h"
#import <BlocksKit/BlocksKit.h>
#import "EFAPI.h"
#import "EFModel.h"

@interface PlaceViewController ()

@end

@implementation PlaceViewController
@synthesize delegate = _delegate;
@synthesize showdetailview;
@synthesize isaddnew;
@synthesize showtableview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wantsFullScreenLayout = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"EDIT_PLACE"];
    self.customPlace = [NSMutableDictionary dictionaryWithCapacity:10];
    self.placeResults = [NSMutableArray arrayWithCapacity:20];

    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44 + 20)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.view addSubview:toolbar];

    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 20, 20, 44)];
    btnBack.backgroundColor = [UIColor clearColor];
    [btnBack setImage:[UIImage imageNamed:@"back_g3.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_g3_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(Close) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit];
    [toolbar addSubview:btnBack];

    
    UIImageView *inputframeview=[[UIImageView alloc] initWithFrame:CGRectMake(28, 7 + 20, 229, 31)];
    inputframeview.image=[UIImage imageNamed:@"textfield.png"];
    inputframeview.contentMode    = UIViewContentModeScaleToFill;
    inputframeview.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
    [toolbar addSubview:inputframeview];
    
    inputplace=[[UITextField alloc] initWithFrame:CGRectMake(54, 13.5 + 20, 195-18, 18.5)];
    inputplace.tag=401;
    inputplace.placeholder=NSLocalizedString(@"Search place", nil);
    [inputplace setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    inputplace.delegate=self;
    [inputplace setAutocorrectionType:UITextAutocorrectionTypeNo];
    [inputplace setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    inputplace.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    [inputplace setBackgroundColor:[UIColor clearColor]];
    [toolbar addSubview:inputplace];
    inputplace.text=@"";
    
    UIImageView *icon=[[UIImageView alloc] initWithFrame:CGRectMake(33, 13.5 + 20, 18, 18)];
    icon.image=[UIImage imageNamed:@"place_18.png"];
    [toolbar addSubview:icon];

    rightbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [rightbutton setFrame:CGRectMake(265, 7 + 20, 50, 30)];
    [rightbutton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [rightbutton setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0,3)] forState:UIControlStateNormal];
    [rightbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];

    [rightbutton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:rightbutton];
    
    
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
    placeedit.PlaceTitle.tag = 402;
    placeedit.PlaceDesc.tag = 403;
    [placeedit setHidden:YES];
    [map addSubview:placeedit];

    if(self.selecetedPlace == nil) {
      
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSEntityDescription *placeEntity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
        self.selecetedPlace = [[Place alloc] initWithEntity:placeEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
        self.selecetedPlace.title = @"";
        self.selecetedPlace.place_description = @"";
        self.selecetedPlace.lat = @"";
        self.selecetedPlace.lng = @"";
        self.selecetedPlace.external_id = @"";
        self.selecetedPlace.provider = @"";

    } else{

        if (self.selecetedPlace.title.length > 0) {
            [self.customPlace setValue:self.selecetedPlace.title forKey:@"title"];
        } else {
            [self.customPlace setValue:@"" forKey:@"title"];
        }
        if (self.selecetedPlace.place_description.length > 0) {
            [self.customPlace setValue:self.selecetedPlace.place_description forKey:@"description"];
        } else {
            [self.customPlace setValue:@"" forKey:@"description"];
        }
        if (self.selecetedPlace.lat.length > 0) {
            [self.customPlace setValue:self.selecetedPlace.lat forKey:@"lat"];
        } else {
            [self.customPlace setValue:@"" forKey:@"lat"];
        }
        if (self.selecetedPlace.lng.length > 0) {
            [self.customPlace setValue:self.selecetedPlace.lng forKey:@"lng"];
        } else {
            [self.customPlace setValue:@"" forKey:@"lng"];
        }
        if (self.selecetedPlace.external_id.length > 0) {
            [self.customPlace setValue:self.selecetedPlace.external_id forKey:@"external_id"];
        } else {
            [self.customPlace setValue:@"" forKey:@"external_id"];
        }
        if (self.selecetedPlace.provider.length > 0) {
            [self.customPlace setValue:self.selecetedPlace.provider forKey:@"provider"];
        } else {
            [self.customPlace setValue:@"" forKey:@"provider"];
        }
        showtableview = NO;
        [self editPlace:self.customPlace];
    }
    
//    // TODO PLACEID
//    if([self.selecetedPlace.place_id intValue]==0){
//       // place.place_id=[NSNumber numberWithInt:-[((NewGatherViewController*)gatherview).cross.cross_id intValue]];
//    }

    float tableviewx=map.frame.origin.x;
    float tableviewy=map.frame.origin.y+map.frame.size.height;
    float tableviewidth=map.frame.size.width;
    float tablevieheight=self.view.frame.size.height-tableviewy;

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(tableviewx,tableviewy,tableviewidth,tablevieheight) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
   
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

- (void)viewWillAppear:(BOOL)animated
{
    [self regObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark init
- (void)regObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:inputplace];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegan:) name:UITextFieldTextDidBeginEditingNotification object:inputplace];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:placeedit.PlaceTitle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:placeedit.PlaceDesc];
    
    // model
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameReverseGeocodingSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameGetPlacesByTitleSuccess
                                               object:nil];
}

- (void)regEvent
{
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(maplongpress:)];
    longpress.minimumPressDuration = 1.0;
    [map addGestureRecognizer:longpress];
    
    UITapGestureRecognizer *tapMap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [self setViewStyle:EXPlaceViewStyleMap];
    } delay:0.18];
    [map addGestureRecognizer:tapMap];
}

#pragma mark lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    
}



#pragma mark - Notification Handler

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    
    if ([name isEqualToString:kEFNotificationNameReverseGeocodingSuccess]) {
        NSDictionary *userInfo = notification.userInfo;
        
        NSString *status = [userInfo valueForKeyPath:@"status"];
        if (status != nil &&[status isEqualToString:@"OK"]) {
            NSArray *results = [userInfo valueForKeyPath:@"results"];
            if ([results count] > 0) {
                NSDictionary *p = [results objectAtIndex:0];
                
                if (placeedit.PlaceDesc.text.length == 0) {
                    NSString *formatted_address = [p valueForKeyPath:@"formatted_address"];
                    
                    placeedit.PlaceDesc.text = formatted_address;
                    [self.customPlace setValue:formatted_address forKey:@"description"];
                    [placeedit setNeedsDisplay];
                }
            }
        }
    } else if ([name isEqualToString:kEFNotificationNameGetPlacesByTitleSuccess]) {
        NSDictionary *userInfo = notification.userInfo;
        
        if ([userInfo isKindOfClass:[NSDictionary class]]) {
            NSString *status = [userInfo objectForKey:@"status"];
            NSString *keyword = [userInfo valueForKey:@"title"];
            CLLocationCoordinate2D location = [[userInfo valueForKey:@"location"] MKCoordinateValue];
            
            if (status != nil && [status isEqualToString:@"OK"]) {
                NSArray *results = [userInfo objectForKey:@"results"];
                [self reloadPlaceData:results withKeyword:keyword];
                
                NSString *inputText = inputplace.text;
                
                if ([keyword isEqualToString:inputText]) {
                    
                    [self.customPlace removeAllObjects];
                    [self.customPlace setValue:keyword forKey:@"title"];
                    
                    [self.placeResults removeAllObjects];
                    [self saveResultsFromGooglePlaceAPI:results];
                    [_tableView reloadData];
                    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    
                    [self drawMapAnnontations:self.placeResults];
                    
                    [self showMapOverviewNear:location];
                    
                    [self setViewStyle:EXPlaceViewStyleShowPlaceDetail];
                }
                
            }
        }
    }
}

#pragma mark handler
- (void) Close{
    [[RKObjectManager sharedManager].operationQueue cancelAllOperations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) done{
    
    if (placeedit.hidden) {
        //
    } else {
        
        [self storeSelectedPlace:self.customPlace];
    
//        self.selecetedPlace.title = [self.customPlace valueForKeyPath:@"title"];
//        self.selecetedPlace.place_description = [self.customPlace valueForKeyPath:@"description"];
//
//        NSString * latitude =  [self.customPlace valueForKey:@"lat"];
//        NSString * longitude = [self.customPlace valueForKey:@"lng"] ;
//
//        if (latitude.length > 0 && longitude.length > 0) {
//            self.selecetedPlace.lat = latitude;
//            self.selecetedPlace.lng = longitude;
//            self.selecetedPlace.external_id = [self.customPlace valueForKey:@"external_id"];
//            self.selecetedPlace.provider = [self.customPlace valueForKey:@"provider"];
//        }
    }

    [self.delegate setPlace:self.selecetedPlace];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) maplongpress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchPoint = [gestureRecognizer locationInView:map];
        CLLocationCoordinate2D touchMapCoordinate =[map convertPoint:touchPoint toCoordinateFromView:map];
        [self addCustomAnnotation:touchMapCoordinate];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (inputplace.text.length > 0) {
        [self searchPlaceByKeyword: inputplace.text near:CLLocationCoordinate2DMake(lat, lng)];
    } else {
        [self searchNearByPlaces:CLLocationCoordinate2DMake(lat, lng)];
    }
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
        [self.customPlace setValue:textField.text forKey:@"title"];
        if (textField.text.length == 0) {
            
            [self clearplace];
        }
        
    }
    
    if (textField.tag == 403) {
        [self.customPlace setValue:textField.text forKey:@"description"];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    if( (isedit == NO && self.selecetedPlace == nil) || isaddnew == YES) {
        CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        if (meters < 0 || meters > 500) {
            
            AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [app.model.apiServer getPlacesNearbyWithLocation:location
                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                  if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                                                      NSDictionary *body = (NSDictionary*)responseObject;
                                                                      if ([body isKindOfClass:[NSDictionary class]]) {
                                                                          NSString *status = [body objectForKey:@"status"];
                                                                          if (status != nil && [status isEqualToString:@"OK"]) {
                                                                              // Get results
                                                                              NSArray *results = [body objectForKey:@"results"];
                                                                              
                                                                              // Clean custome place
                                                                              [self.customPlace removeAllObjects];
                                                                              // Save and show results
                                                                              [self.placeResults removeAllObjects];
                                                                              [self saveResultsFromGooglePlaceAPI:results];
                                                                              [_tableView reloadData];
                                                                              [self drawMapAnnontations:self.placeResults];
                                                                              
                                                                              MKCoordinateRegion region;
                                                                              region.center = location;
                                                                              region.span.longitudeDelta = 0.02;
                                                                              region.span.latitudeDelta = 0.02;
                                                                              [map setRegion:region animated:YES];
                                                                              
                                                                              [self setViewStyle:EXPlaceViewStyleShowPlaceDetail];
                                                                              
                                                                          }
                                                                      }
                                                                  }
                                                              }
                                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                              }];
        }
    }
    lng = location.longitude;
    lat = location.latitude;
}

#pragma mark UI helper Methods
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
        
    } else if(style == EXPlaceViewStyleEdit){
        [_tableView setHidden:YES];

        [UIView animateWithDuration:0.25
                         animations:^{
                             [map setFrame:CGRectMake(0, 44, self.view.frame.size.width,self.view.frame.size.height-44 - 216)];
                             mapShadow.frame = CGRectMake(0, CGRectGetHeight(map.bounds) - 4, CGRectGetWidth(map.bounds), 4);
                             [placeedit setHidden:NO];
                             [placeedit becomeFirstResponder];
                         }
                         completion:^(BOOL finished) {
                         }];
        
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

- (void) drawMapAnnontations:(NSArray *)places{
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:self.placeResults.count];
    int i = 0;
    for (NSDictionary *placedict in places) {
        
        CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
        
        location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
        location.longitude = [[placedict objectForKey:@"lng"] doubleValue];
        PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[placedict objectForKey:@"title"]  description:[placedict objectForKey:@"description"]];
        annotation.external_id = [placedict objectForKey:@"external_id"];
        annotation.index = i;
        [annotations addObject:annotation];
        i++;
    }
    [map removeAnnotations:map.annotations];
    [map addAnnotations:annotations];
}

- (void) drawMapAnnontation:(NSDictionary*)placedict{
    
    [map removeAnnotations:map.annotations];
    
    CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
    
    location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
    location.longitude = [[placedict objectForKey:@"lng"] doubleValue];
    
    [self showMapAt:location];
    
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:[placedict valueForKey:@"title"]  description:[placedict valueForKey:@"description"]];
    annotation.external_id = [placedict valueForKey:@"external_id"];
    annotation.index = 0;
    
    [map addAnnotation:annotation];
    
}

#pragma mark Handler Helper Methods
- (void) addCustomAnnotation:(CLLocationCoordinate2D)location{
    [map removeAnnotations: map.annotations];
    
    NSString *title = [self.customPlace valueForKey:@"title"];
    NSString *description = [self.customPlace valueForKey:@"description"];
    if (title.length == 0) {
        title = @"Right there on the map";
        [self.customPlace setValue:@"Right there on the map" forKey:@"title"];
    }
    
    [self.customPlace removeObjectsForKeys:@[@"lat", @"lng", @"external_id", @"provider"]];
    
    [self.customPlace setValue:[NSString stringWithFormat:@"%f", location.latitude] forKey:@"lat"];
    [self.customPlace setValue:[NSString stringWithFormat:@"%f", location.longitude] forKey:@"lng"];
    [self.customPlace setValue:@"" forKey:@"external_id"];
    [self.customPlace setValue:@"" forKey:@"provider"];
    
    [placeedit setPlaceTitleText:title];
    [placeedit setPlaceDescText:description];
    [placeedit setHidden:NO];
    
    PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithCoordinate:location withTitle:self.selecetedPlace.title description:self.selecetedPlace.place_description];
    if ([[map annotations] count] == 0) {
        annotation.index = -2;
        // custome place
    }
    [map addAnnotation:annotation];
    [clearbutton setHidden:YES];
    
    [self setViewStyle:EXPlaceViewStyleEdit];
    
    [self showMapOverviewNear:kCLLocationCoordinate2DInvalid];
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model reverseGeocodingWithLocation:annotation.coordinate];
}

- (void)showMapAt:(CLLocationCoordinate2D)location
{
    if (CLLocationCoordinate2DIsValid(location)) {
//        CGPoint p = [map convertCoordinate:location toPointToView:map];
//        p.y -= 10; // move pin 10 points down
//        CLLocationCoordinate2D newCenter = [map convertPoint:p toCoordinateFromView:map];
 //        [map setCenterCoordinate:newCenter animated:YES];
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(location);
        MKMapRect zoomRect = MKMapRectMake(annotationPoint.x - 2000, annotationPoint.y - 2000, 4000, 4000);

        [map setVisibleMapRect:zoomRect animated:YES];
    }
}

- (void)showMapOverviewNear:(CLLocationCoordinate2D)location
{
//    double w = map.visibleMapRect.size.width;
//    double h = map.visibleMapRect.size.height;
//    double r = h / w;
//    
//    double maxW = 60000;
//    double maxH = maxW * r;
    
    MKMapRect zoomRect = MKMapRectNull;
    
    if (CLLocationCoordinate2DIsValid(location)) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(location);
        zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    }
    
    for (id <MKAnnotation> annotation in map.annotations)
    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        MKMapRect rect = MKMapRectUnion(zoomRect, pointRect);
        zoomRect = rect;
    }
    
//    if (CLLocationCoordinate2DIsValid(location)) {
//        MKMapPoint annotationPoint = MKMapPointForCoordinate(location);
//        if (zoomRect.size.width > maxW ) {
//            zoomRect = MKMapRectMake(annotationPoint.x - maxW / 2, annotationPoint.y - maxH / 2, maxW, maxH);
//        }
//    }
//    
    
    
    [map setVisibleMapRect:zoomRect animated:YES];
}



- (void)searchNearByPlaces:(CLLocationCoordinate2D)location
{
    
    AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.model.apiServer getPlacesNearbyWithLocation:location
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
        
//        if (keyword == nil) {
//            if (self.placeResults.count > 0) {
//                [self selectPlace:[self.placeResults objectAtIndex:0]];
//            }
//        }
        [self setViewStyle:EXPlaceViewStyleShowPlaceDetail];
    }
}




- (void) clearplace{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:NSLocalizedString(@"Clear place", nil) otherButtonTitles:nil];
    [sheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        isnotinputplace = YES;
        [self storeSelectedPlace:nil];

        [map removeAnnotations:[map annotations]];
        [placeedit setHidden:YES];
        [inputplace becomeFirstResponder];
        inputplace.text = @"";
        [clearbutton setHidden:YES];

        isnotinputplace = NO;
        [self.placeResults removeAllObjects];
        [self.customPlace removeAllObjects];
        [_tableView reloadData];
    } else {
        placeedit.PlaceTitle.text = NSLocalizedString(@"Right there on map", nil);
        [placeedit.PlaceTitle setSelectedTextRange:[placeedit.PlaceTitle textRangeFromPosition:placeedit.PlaceTitle.beginningOfDocument toPosition:placeedit.PlaceTitle.endOfDocument]];

        [placeedit.PlaceTitle selectAll:placeedit.PlaceTitle];
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
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
        case 0:{
            [self editPlace:self.customPlace];
            
        }   break;
         
        case 1:{
            [self.customPlace removeAllObjects];
            NSDictionary * dict = [self.placeResults objectAtIndex:indexPath.row];
            [self.customPlace addEntriesFromDictionary:dict];
            
            [self editPlace:self.customPlace];
        }    break;
        default:{
            
        }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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
            cell.detailTextLabel.text = NSLocalizedString(@"No place found. Tap arrow to edit.", nil);
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
    
    MKAnnotationView *annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    annView.canShowCallout = YES;
    
    if ([((PlaceAnnotation*)annotation).external_id isEqualToString:self.selecetedPlace.external_id]) {
        annView.image = [UIImage imageNamed:@"map_mark_diamond_blue.png"];
    } else {
        annView.image = [UIImage imageNamed:@"map_mark_red.png"];
    }
    [annView setCenterOffset:CGPointMake(0, -18)];
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
                if([annoview.image isEqual:[UIImage imageNamed:@"map_mark_diamond_blue.png"]]){
                    annoview.image = [UIImage imageNamed:@"map_mark_red.png"];
                }
            }
        }
        
        view.image = [UIImage imageNamed:@"map_mark_diamond_blue.png"];
        
        if (placeedit.hidden) {
         
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
        } else {
             [mapView deselectAnnotation:view.annotation animated:YES];
        }

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
        
        NSString * value = [place valueForKey:@"lat"];
        if (value.length > 0) {
            self.selecetedPlace.lat = [place valueForKey:@"lat"];
        } else {
            self.selecetedPlace.lat = @"";
        }
        value = [place valueForKey:@"lng"];
        if (value.length > 0) {
            self.selecetedPlace.lng = [place valueForKey:@"lng"];
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
    
    if ([self.selecetedPlace hasGeo]) {
        CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
        location.latitude = [self.selecetedPlace.lat doubleValue];
        location.longitude = [self.selecetedPlace.lng doubleValue];
        [self showMapAt:location];
    }
    
    NSArray *annotations = [map annotations];
    
    for (PlaceAnnotation* annotation in annotations){
        if([annotation isKindOfClass:[PlaceAnnotation class]]){
            MKAnnotationView* annoview = [map viewForAnnotation: annotation];
            if([annotation.external_id isEqualToString:self.selecetedPlace.external_id]){
                annoview.image=[UIImage imageNamed:@"map_mark_diamond_blue.png"];
                [annoview.superview bringSubviewToFront:annoview];
//                [annoview bringSubviewToFront:map];
            } else {
                annoview.image = [UIImage imageNamed:@"map_mark_red.png"];
            }
        }
    }
    
    
    
    return;
}

- (void) editPlace:(NSDictionary *)placedict
{
    isedit = YES;
    [self setViewStyle:EXPlaceViewStyleEdit];
    
    [placeedit setPlaceTitleText:[placedict valueForKey:@"title"]];
    [placeedit setPlaceDescText:[placedict valueForKey:@"description"]];
    [placeedit setHidden:NO];
    
    NSString * latitude =  [placedict valueForKey:@"lat"];
    NSString * longitude = [placedict valueForKey:@"lng"] ;
    
    if (latitude.length > 0 && longitude.length > 0) {
        [self drawMapAnnontation:placedict];
    } else {
        [map removeAnnotations:map.annotations];
    }
}

- (void) selectPlace:(int)index editing:(BOOL)editing{
    CLLocationCoordinate2D location = kCLLocationCoordinate2DInvalid;
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

//            [self showEdit:self.selecetedPlace];
            location.latitude = annotation.coordinate.latitude;
            location.longitude = annotation.coordinate.longitude;

            MKAnnotationView* annoview = [map viewForAnnotation: annotation];
            annoview.image=[UIImage imageNamed:@"map_mark_diamond_blue.png"];
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
//        [self showEdit:self.selecetedPlace];
        location.latitude = [[placedict objectForKey:@"lat"] doubleValue];
        location.longitude = [[placedict objectForKey:@"lng"] doubleValue];

        NSArray *annotations = [map annotations];

        for (PlaceAnnotation* annotation in annotations){
            if([annotation isKindOfClass:[PlaceAnnotation class]]){
                MKAnnotationView* annoview = [map viewForAnnotation: annotation];
                if([annotation.external_id isEqualToString:self.selecetedPlace.external_id]){
                    annoview.image=[UIImage imageNamed:@"map_mark_diamond_blue.png"];
                    [annoview.superview bringSubviewToFront:annoview];
                    [annoview bringSubviewToFront:map];
                } else {
                    annoview.image=[UIImage imageNamed:@"map_mark_red.png"];
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
//    id<MKAnnotation> anno = [map.selectedAnnotations objectAtIndex:0];
//    
//    [map deselectAnnotation:anno animated:YES];
//    NSMutableArray *array = [NSMutableArray arrayWithArray:map.annotations];
//    [array removeObject:anno];
//    [map removeAnnotations:array];
//    
    
    
    [self.customPlace removeAllObjects];
    NSDictionary * dict = [self.placeResults objectAtIndex:index];
    [self.customPlace addEntriesFromDictionary:dict];
    
    [self editPlace:self.customPlace];
}

//- (void) showEdit:(Place*)place{
//    [placeedit setPlaceTitleText:self.selecetedPlace.title];
//    [placeedit setPlaceDescText:self.selecetedPlace.place_description];
//    [placeedit setHidden:NO];
//    [placeedit becomeFirstResponder];
//}

- (void) saveResultsFromGooglePlaceAPI:(NSArray*)results{
    if ([results count] > 0) {
        NSDictionary *dict = [results objectAtIndex:0];
        NSNumber *_lng = [dict valueForKeyPath:@"geometry.location.lng"];
        NSNumber *_lat = [dict valueForKeyPath:@"geometry.location.lat"];
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
        NSString *_name=[placedict valueForKeyPath:@"name"];
        if (_name == nil) {
            _name = @"";
        }
        NSString *_formatted_address=[placedict valueForKeyPath:@"formatted_address"];
        if (_formatted_address == nil){
            _formatted_address = [placedict valueForKeyPath:@"vicinity"];
            if(_formatted_address == nil) {
                _formatted_address = @"";
            }
        }
        NSString *_lng;
        id __lng = [placedict valueForKeyPath:@"geometry.location.lng"] ;
        if (__lng) {
            _lng = [__lng stringValue];
        } else {
            _lng = @"";
        }
        NSString *_lat;
        id __lat= [placedict valueForKeyPath:@"geometry.location.lat"];
        if(__lat) {
            _lat = [__lat stringValue];
        } else {
            _lat = @"";
        }
        NSString *_id = [placedict valueForKeyPath:@"id"];
        if (_id == nil) {
            _id = @"";
        }
        
        NSDictionary * dict = @{@"title":_name,
                                @"description":_formatted_address,
                                @"lng":_lng,
                                @"lat":_lat,
                                @"external_id":_id,
                                @"provider":@"google"};
        [local_results addObject:dict];
    }
    [self.placeResults addObjectsFromArray:local_results];
}

- (void)searchPlaceByKeyword:(NSString*)keyword near:(CLLocationCoordinate2D)location{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.model getPlacesByTitle:keyword location:location];
}



- (void) getPlace:(NSString *)keyword{
    if (CFAbsoluteTimeGetCurrent() - editinginterval > 0.8) {
        
        [self searchPlaceByKeyword: keyword near:CLLocationCoordinate2DMake(lat, lng)];
    }
}

- (void) editingDidBegan:(NSNotification*)notification{
    willUserScroll = YES;
    [self setViewStyle:EXPlaceViewStyleBigTableview];
//    [self setViewStyle:EXPlaceViewStyleTableview];
    
}
- (void) setRightButton:(NSString*) title Selector:(SEL)aSelector{
    [rightbutton setTitle:title forState:UIControlStateNormal];
    [rightbutton addTarget:self action:aSelector forControlEvents:UIControlEventTouchUpInside];
}

@end
