//
//  GatherViewController.m
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import "GatherViewController.h"

@interface GatherViewController ()

@end

@implementation GatherViewController

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
//    UIImageView *imgback=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_gradient.png"]];
//    [self.view addSubview:imgback];
//    [imgback release];

    exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
    exfeeSelected=[[NSMutableArray alloc] initWithCapacity:12];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    float width=self.view.frame.size.width-VIEW_MARGIN*2;
    backgroundview=[[UIView alloc] initWithFrame:self.view.frame];
    [backgroundview setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:backgroundview];
    
    CGRect containviewframe=CGRectMake(self.view.frame.origin.x+VIEW_MARGIN,self.view.frame.origin.y+toolbar.frame.size.height,self.view.frame.size.width-VIEW_MARGIN*2, self.view.frame.size.height-toolbar.frame.size.height);
    containview=[[UIScrollView alloc] initWithFrame:containviewframe];
    [containview setDelegate:self];
    [backgroundview addSubview:containview];

    containcardview=[[EXOverlayView alloc] initWithFrame:CGRectMake(0, INNER_MARGIN, containview.frame.size.width, containview.frame.size.height)];
    containcardview.backgroundimage=[UIImage imageNamed:@"paper_texture.png"];
    
    [containview addSubview:containcardview];
    UIImageView *title_input_img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gather_title_input_area.png"]];
    [title_input_img setFrame:CGRectMake(0, 0, 308, 69)];
    [containcardview addSubview:title_input_img];
    [title_input_img release];

    crosstitle=[[UITextView alloc] initWithFrame:CGRectMake(INNER_MARGIN+30, 5,containview.frame.size.width-INNER_MARGIN-30, 48)];
    [containcardview addSubview:crosstitle];
    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle setBackgroundColor:[UIColor clearColor]];
    [crosstitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [crosstitle becomeFirstResponder];
    
    
    exfeenum=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15, width, 24)];
    [containcardview addSubview:exfeenum];
    [exfeenum setHidden:YES];
    
    exfeeInput=[[UITextField alloc] initWithFrame:CGRectMake(INNER_MARGIN, toolbar.frame.size.height+6+exfeenum.frame.size.height+8, width, 40)];
    [exfeeInput setPlaceholder:@"Invite friends by name, email…"];
    [exfeeInput setBorderStyle:UITextBorderStyleRoundedRect];
    [exfeeInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    [exfeeInput setBackgroundColor:[UIColor clearColor]];
    
    //TODO: workaround for a responder chain bug
    exfeeShowview =[[EXImagesCollectionView alloc] initWithFrame:CGRectMake(INNER_MARGIN, crosstitle.frame.origin.x+crosstitle.frame.size.height, width, 120)];
    [exfeeShowview setFrame:CGRectMake(INNER_MARGIN-6, 69+4-5, width, 40+15+5)];
    [exfeeShowview calculateColumn];
    [exfeeShowview setBackgroundColor:[UIColor clearColor]];
    [containcardview addSubview:exfeeShowview];
//    isExfeeInputShow=NO;

    [exfeeShowview setDataSource:self];
    [exfeeShowview setDelegate:self];
    [self addDefaultIdentity];
    
    map=[[MKMapView alloc] initWithFrame:CGRectMake(INNER_MARGIN+160,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+5,130,80)];
    [containcardview addSubview:map];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        [self ShowPlaceView];
    };
    [map addGestureRecognizer:tapInterceptor];
    [tapInterceptor release];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [containcardview addGestureRecognizer:gestureRecognizer];
    
    [self setExfeeNum];
    [self.view bringSubviewToFront:toolbar];
    
    timetitle=[[UILabel alloc] initWithFrame:CGRectMake(INNER_MARGIN,
                                                        exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10
                                                        ,160,25)];
    [timetitle setBackgroundColor:[UIColor clearColor]];
    timetitle.text=@"Sometime";
    [timetitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    timetitle.textColor=[Util getHighlightColor];
    [containcardview addSubview:timetitle];

    timedesc=[[UILabel alloc] initWithFrame:CGRectMake(INNER_MARGIN,timetitle.frame.origin.y+timetitle.frame.size.height,160,18)];
    [timedesc setBackgroundColor:[UIColor clearColor]];
    timedesc.text=@"Tap here to set time";
    [timedesc setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    [containcardview addSubview:timedesc];
    
    placetitle=[[UILabel alloc] initWithFrame:CGRectMake(INNER_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15,160,24)];
    [placetitle setBackgroundColor:[UIColor clearColor]];
    placetitle.text=@"Somwhere";
    [placetitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    placetitle.textColor=[Util getHighlightColor];
    [containcardview addSubview:placetitle];
    
    placedesc=[[UILabel alloc] initWithFrame:CGRectMake(INNER_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height,self.view.frame.size.width-VIEW_MARGIN*2,18)];
    [placedesc setBackgroundColor:[UIColor clearColor]];
    placedesc.numberOfLines=0;
    placedesc.adjustsFontSizeToFitWidth=NO;
    placedesc.text=@"Tap here to set place";
    [placedesc setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
    [containcardview addSubview:placedesc];

    crossdescription=[[UITextView alloc] initWithFrame:CGRectMake(INNER_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height+placedesc.frame.size.height+10,width,144)];

    crossdescbackimg=[[UIView alloc] initWithFrame:CGRectMake(crossdescription.frame.origin.x, crossdescription.frame.origin.y, crossdescription.frame.size.width, 75)];
    crossdescbackimg.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"gather_describe_area.png"]];
                              
    [containcardview addSubview:crossdescbackimg];
    [crossdescription setBackgroundColor:[UIColor clearColor]];
    [crossdescription setDelegate:self];
    [containcardview addSubview:crossdescription];
    
    [self reArrangeViews];
}

- (void) reArrangeViews{
    
    [timetitle setFrame:CGRectMake(INNER_MARGIN, exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10,160,24)];
    [timedesc setFrame:CGRectMake(INNER_MARGIN,timetitle.frame.origin.y+timetitle.frame.size.height,160,18)];
    [placetitle setFrame:CGRectMake(INNER_MARGIN,timedesc.frame.origin.y+timedesc.frame.size.height+15,160,24)];
    
    
    [placedesc setFrame:CGRectMake(INNER_MARGIN,placetitle.frame.origin.y+placetitle.frame.size.height,160,containcardview.frame.size.width-INNER_MARGIN*2)];

    CGSize constraint = CGSizeMake(placedesc.frame.size.width,400);
    CGSize placedescsize = [placedesc.text sizeWithFont:placedesc.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

    [placedesc setFrame:CGRectMake(INNER_MARGIN,placetitle.frame.origin.y+placetitle.frame.size.height,160,placedescsize.height)];
    
    [map setFrame:CGRectMake(INNER_MARGIN+160,exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10,130,80)];
    
    [crossdescription setFrame:CGRectMake(0,placedesc.frame.origin.y+placedesc.frame.size.height+15,containview.frame.size.width,145)];
    [crossdescbackimg setFrame:CGRectMake(crossdescription.frame.origin.x, crossdescription.frame.origin.y, crossdescription.frame.size.width, 75)];

    float triheight=4;
    float y=timetitle.frame.origin.y+timetitle.frame.size.height/2-triheight;
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointMake(0,y)];
    [triangle addLineToPoint:CGPointMake(0,y+triheight*2)];
    [triangle addLineToPoint:CGPointMake(triheight,y+triheight)];
    [triangle addLineToPoint:CGPointMake(0,y)];

    y=placetitle.frame.origin.y+placetitle.frame.size.height/2-triheight;
    [triangle moveToPoint:CGPointMake(0,y)];
    [triangle addLineToPoint:CGPointMake(0,y+triheight*2)];
    [triangle addLineToPoint:CGPointMake(triheight,y+triheight)];
    [triangle addLineToPoint:CGPointMake(0,y)];
    
    containcardview.transparentPath=triangle;
    [containcardview setFrame:CGRectMake(containcardview.frame.origin.x, containcardview.frame.origin.y, containcardview.frame.size.width, crossdescription.frame.origin.y+crossdescription.frame.size.height)];
    [containview setContentSize:CGSizeMake(containview.frame.size.width, containcardview.frame.size.height+20)];

    containview.alwaysBounceVertical=YES;
    
//    containview.layer.shadowColor = [UIColor blueColor].CGColor;
//    containview.layer.shadowOpacity = 0.7f;
//    containview.layer.shadowOffset = CGSizeMake(-3, 1);
//    containview.layer.shadowRadius = 5.0f;
//    containview.layer.masksToBounds = NO;
    
    [containcardview setNeedsDisplay];
}
- (void) addDefaultIdentity{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0)
    {
        User *user=[users objectAtIndex:0];
        Identity *default_identity=user.default_identity;
        if(user!=nil){
            Invitation *invitation=[Invitation object];
            invitation.rsvp_status=@"ACCEPTED";
            invitation.host=[NSNumber numberWithBool:YES];
            invitation.mates=0;
            invitation.identity=default_identity;
            [exfeeIdentities addObject:invitation];
            [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
            [exfeeShowview reloadData];
        }
    }
}

- (IBAction) Gather:(id) sender{
    [self pullcontainviewDown];
    Identity *by_identity=[Identity object];
    by_identity.identity_id=[NSNumber numberWithInt:174];
    
    Cross *cross=[Cross object];
    cross.title=crosstitle.text;
    cross.cross_description=@"test desc";
    cross.by_identity=by_identity;
    cross.place=place;
    cross.time=datetime;
    Exfee *exfee=[Exfee object];
    for(Invitation *invitation in exfeeIdentities){
        [exfee addInvitationsObject:invitation];  
    }
    cross.exfee = exfee;
    
    [APICrosses GatherCross:cross delegate:self];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:exfeeInput];

	[exfeeIdentities release];
    [exfeeSelected release];
    [suggestIdentities release];
    [exfeeInput release];
    [exfeeShowview release];
    [crosstitle release];
    [map release];
    [crossdescription release];
    [timetitle release];
    [timedesc release];
    [placetitle release];
    [placedesc release];
    
    [containview release];
    [backgroundview release];
    [containcardview release];
    [crossdescbackimg release];
    [super dealloc];
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
- (IBAction) Close:(id) sender{
    [self pullcontainviewDown];
    [self dismissModalViewControllerAnimated:YES];
}


- (void) ShowPlaceView{
    PlaceViewController *placeViewController=[[PlaceViewController alloc]initWithNibName:@"PlaceViewController" bundle:nil];
    placeViewController.gatherview=self;
    if(place)
        [placeViewController setPlace:place];
    [self presentModalViewController:placeViewController animated:YES];
    [placeViewController release];
}
- (void) ShowTimeView{
    TimeViewController *timeViewController=[[TimeViewController alloc] initWithNibName:@"TimeViewController" bundle:nil];
    timeViewController.gatherview=self;
    [self presentModalViewController:timeViewController animated:YES];
    [timeViewController release];
}

- (void) ShowExfeeView{
    ExfeeInputViewController *exfeeinputViewController=[[ExfeeInputViewController alloc] initWithNibName:@"ExfeeInputViewController" bundle:nil];
    exfeeinputViewController.gatherview=self;
    [self presentModalViewController:exfeeinputViewController animated:YES];
    [exfeeinputViewController release];
    
}
//
//-(BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSCharacterSet *split=[NSCharacterSet characterSetWithCharactersInString:@",;"];
//    NSArray *identity_list=[textField.text componentsSeparatedByCharactersInSet:split];
//    NSString *json=@"";
//    for(NSString *identity_input in identity_list) {
//        NSString *provider=[Util findProvider:identity_input];
//        if(![provider isEqualToString:@""]) {
//            if(![json isEqualToString:@""])
//                json=[json stringByAppendingString:@","];
//            json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,identity_input];
//        }
//    }
//    json=[NSString stringWithFormat:@"[%@]",json];
//    [self getIdentity:json];
//    return YES;
//}

//- (void)textDidChange:(UITextField*)textField
//{
//    if(exfeeInput.text!=nil && exfeeInput.text.length>=1) {
//        [APIProfile LoadSuggest:exfeeInput.text delegate:self];
//        [self loadIdentitiesFromDataStore];
//    }
//    else{
//        [suggestionTable removeFromSuperview];
//    }
//}

- (NSString*) findProvider:(NSString*)external_id{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    if([emailTest evaluateWithObject:external_id]==YES)
        return @"email";

    NSString *twitterRegex = @"@[A-Za-z0-9.-]+";
    NSPredicate *twitterTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", twitterRegex];
    if([twitterTest evaluateWithObject:external_id]==YES)
        return @"twitter";
    
    return @"";
}
//- (void) getIdentity:(NSString*)identity_json{
//    
//    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//    RKClient *client = [RKClient sharedClient];
//    NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];
//
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:identity_json forParam:@"identities"];
//    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
//    [client post:endpoint usingBlock:^(RKRequest *request){
//    request.method=RKRequestMethodPOST;
//    request.params=rsvpParams;
//    request.onDidLoadResponse=^(RKResponse *response){
//        if (response.statusCode == 200) {
//            NSDictionary *body=[response.body objectFromJSONData];
//            if([body isKindOfClass:[NSDictionary class]]) {
//                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                if(code)
//                    if([code intValue]==200) {
//                        NSDictionary* response = [body objectForKey:@"response"];
//                        NSArray *identities = [response objectForKey:@"identities"];
//                        for (NSDictionary *identitydict in identities) {
//                            NSString *external_id=[identitydict objectForKey:@"external_id"];
//                            NSString *provider=[identitydict objectForKey:@"provider"];
//                            NSString *avatar_filename=[identitydict objectForKey:@"avatar_filename"];
//                            NSString *identity_id=[identitydict objectForKey:@"id"];
//                            NSString *name=[identitydict objectForKey:@"name"];
//                            NSString *nickname=[identitydict objectForKey:@"nickname"];
//                            
//                            Identity *identity=[Identity object];
//                            identity.external_id=external_id;
//                            identity.provider=provider;
//                            identity.avatar_filename=avatar_filename;
//                            identity.name=name;
//                            identity.nickname=nickname;
//                            identity.identity_id=[NSNumber numberWithInt:[identity_id intValue]];
//                            Invitation *invitation =[Invitation object];
//                            invitation.rsvp_status=@"NORESPONSE";
//                            invitation.identity=identity;
//                            
//                            [exfeeIdentities addObject:invitation];
//                            [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
//                            [exfeeShowview reloadData];
//                        }
//                        exfeeInput.text=@"";
//                        [exfeeInput setEnabled:YES];
//                    }
//                }
//            }else {
//                    [exfeeInput setEnabled:YES];
//                //Check Response Body to get Data!
//            }
//        };
//        request.delegate=self;
//    }];
//    
//}
- (void) addExfee:(Invitation*) invitation{
    [exfeeIdentities addObject:invitation];
    [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
    [exfeeShowview reloadData];
    [self setExfeeNum];
}


- (void) setPlace:(NSDictionary*)placedict{
    Place *_place=[Place object];
    _place.title=[placedict objectForKey:@"title"];
    NSNumber *lat=[placedict objectForKey:@"lat"];
    NSNumber *lng=[NSNumber numberWithDouble:[[placedict objectForKey:@"lng"] doubleValue]];
    _place.lat= lat;
    _place.lng= lng;
    _place.place_description =[placedict objectForKey:@"description"];
    _place.external_id=[placedict objectForKey:@"external_id"];
    _place.provider=[placedict objectForKey:@"provider"];
    place=_place;
    placetitle.text=_place.title;
    placedesc.text=_place.place_description;
    
    CGSize maximumLabelSize = CGSizeMake(placedesc.frame.size.width,9999);
    
    CGSize expectedLabelSize = [placedesc.text sizeWithFont:placedesc.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    CGRect newFrame = placedesc.frame;
    newFrame.size.height = expectedLabelSize.height;
    placedesc.frame = newFrame;
    [self reArrangeViews];
    
    
    
//    placedesc 
    
    CLLocationCoordinate2D location;
    
    [map removeAnnotations: map.annotations];
    location.latitude = [_place.lat doubleValue];
    location.longitude = [_place.lng doubleValue];
    PlaceAnnotation *annotation=[[PlaceAnnotation alloc] initWithCoordinate:location withTitle:_place.title  description:_place.place_description];
    MKCoordinateRegion region;
    
    region.center = location;
    region.span.longitudeDelta = 0.005;
    region.span.latitudeDelta = 0.005;
    [map setRegion:region animated:YES];
    [map removeAnnotations:[map annotations]];
    [map addAnnotation:annotation];
}

- (void) setDateTime:(CrossTime*)crosstime{
    NSDictionary *humanreadable_date=[Util crossTimeToString:crosstime];
    timetitle.text=[humanreadable_date objectForKey:@"relative"];
    timedesc.text=[humanreadable_date objectForKey:@"date"];
    datetime=crosstime;
}

- (void) pullcontainviewDown{
    NSLog(@"pull down");
    if(containview.frame.origin.y<0){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [containview setFrame:CGRectMake(0,0,self.view.frame.size.width,460)];
        [UIView commitAnimations];
        [crossdescription resignFirstResponder];
    }
}

- (void) ShowRSVPToolBar:(int)exfeeIndex{
    selectedExfeeIndex=exfeeIndex;
    if(rsvptoolbar==nil){
        rsvptoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, self.view.frame.size.height-44) buttonsize:CGSizeMake(20, 20) delegate:self];
        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"Accept" image:[UIImage imageNamed:@"chat.png"]];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];
        EXButton *addmate=[[EXButton alloc] initWithName:@"addmate" title:@"+1 mate" image:[UIImage imageNamed:@"chat.png"]];
        [addmate addTarget:self action:@selector(rsvpaddmate) forControlEvents:UIControlEventTouchUpInside];
        EXButton *submate=[[EXButton alloc] initWithName:@"submate" title:@"+1 mate" image:[UIImage imageNamed:@"chat.png"]];
        [submate addTarget:self action:@selector(rsvpsubmate) forControlEvents:UIControlEventTouchUpInside];
        EXButton *reset=[[EXButton alloc] initWithName:@"reset" title:@"Reset" image:[UIImage imageNamed:@"chat.png"]];
        [reset addTarget:self action:@selector(rsvpremove) forControlEvents:UIControlEventTouchUpInside];
        NSArray *array=[NSArray arrayWithObjects:accept,addmate,submate,reset, nil];
        [rsvptoolbar drawButton:array];
        [accept release];
        [addmate release];
        [submate release];
        [reset release];
        [self.view addSubview:rsvptoolbar];
    }
    [rsvptoolbar setItemIndex:exfeeIndex];
    [rsvptoolbar setHidden:NO];
}

//- (void) ShowExfeeInput:(BOOL)show{
//    float width=self.view.frame.size.width-VIEW_MARGIN*2;
//    [self pullcontainviewDown];
//    if(show==YES && isExfeeInputShow==NO){
//        exfeeInput.alpha=0;
//        [exfeeInput setHidden:NO];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDelay:0];
//        [UIView setAnimationDuration:0.25];
//        [crosstitle setFrame:CGRectMake(VIEW_MARGIN,crosstitle.frame.origin.y-48,crosstitle.frame.size.width,crosstitle.frame.size.height)];
//        [exfeenum setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6,exfeenum.frame.size.width, exfeenum.frame.size.height)];
//        [exfeeInput setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+exfeenum.frame.size.height+8, width, 40)];
//        [UIView commitAnimations];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDelay:0.25];
//        [UIView setAnimationDuration:0.25];
//        exfeeInput.alpha=1;
//        [UIView commitAnimations];
//        isExfeeInputShow=YES;
//        [exfeeInput becomeFirstResponder];
//    }
//    else if(show==NO && isExfeeInputShow==YES){
//        CGRect rect=exfeeShowview.frame;
//        [UIView animateWithDuration:0.25f
//                              delay:0.0f
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             [crosstitle setFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6,crosstitle.frame.size.width,crosstitle.frame.size.height)];
//
//                             [exfeenum setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15, width, 24)];
//                             [exfeeInput setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+exfeenum.frame.size.height+8, width, 40)];
//                             [exfeeInput setHidden:YES];
//                             
//                             
//                             [exfeeShowview setFrame:CGRectMake(INNER_MARGIN-6, toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8, rect.size.width, rect.size.height)];
//
//                             [map setFrame:CGRectMake(map.frame.origin.x,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+rect.size.height+15+5,map.frame.size.width,map.frame.size.height)];
//                             isExfeeInputShow=NO;
//                             
//                         }
//                         completion:nil];
//        
//    }
//}
- (void) setExfeeNum{
    int count=[exfeeIdentities count];
    exfeenum.text=[NSString stringWithFormat:@"%u Exfees",count];
}
- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    if (CGRectContainsPoint([placetitle frame], location) || CGRectContainsPoint([placedesc frame], location))
    {
        [self ShowPlaceView];
    }
    if (CGRectContainsPoint([timetitle frame], location) || CGRectContainsPoint([timedesc frame], location))
    {
        [self ShowTimeView];
    }
    if (CGRectContainsPoint([exfeeShowview frame], location))
    {
        CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
        [exfeeShowview onImageTouch:exfeeviewlocation];
    }
    else{
    [crosstitle resignFirstResponder];
    [exfeeInput resignFirstResponder];
    [map becomeFirstResponder];
//    [self ShowExfeeInput:NO];
    }

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        if (CGRectContainsPoint([placetitle frame], [touch locationInView:self.view]) || CGRectContainsPoint([placedesc frame], [touch locationInView:self.view]))
        {
            [self ShowPlaceView];
        }
        if (CGRectContainsPoint([timetitle frame], [touch locationInView:self.view]) || CGRectContainsPoint([timedesc frame], [touch locationInView:self.view]))
        {
            [self ShowTimeView];
        }

        
        [crosstitle resignFirstResponder];
        [exfeeInput resignFirstResponder];
        [map becomeFirstResponder];
//        [self ShowExfeeInput:NO];
    }
//    NSLog(@"click view");
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:0.25];
    [containview setContentOffset:CGPointMake(0, containview.frame.size.height- crossdescription.frame.size.height-44-6-20)];
    [UIView commitAnimations];
    return YES;
}
#pragma mark UIScrollView methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (UIView *view in [containview subviews])
    {
        [view resignFirstResponder];
    }
    [crossdescription resignFirstResponder];
    [containview becomeFirstResponder];
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {

    if([objects count]>0)
    {
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        if([objectLoader.userData isEqualToString:@"suggest"])
            [self loadIdentitiesFromDataStore];
        else
            [app GatherCrossDidFinish];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
//    [self stopLoading];
}

#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if(suggestIdentities)
        return [suggestIdentities count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"suggest view";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
	cell.textLabel.text = identity.name;
	
    return cell;
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
//    Invitation *invitation =[Invitation object];
//    invitation.rsvp_status=@"ACCEPTED";
//    invitation.identity=identity;
//
//    [suggestionTable removeFromSuperview];
//    exfeeInput.text=@"";
//    //[self ShowExfeeInput:NO];
//}


#pragma mark EXImagesCollectionView Datasource methods

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [exfeeIdentities count];
}
- (Invitation *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index{
    Invitation *invitation =[exfeeIdentities objectAtIndex:index];
//    Identity *identity=invitation.identity;
    return invitation;
}
- (NSArray *) selectedOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return exfeeSelected;
    
}
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView shouldResizeHeightTo:(float)height{

    [exfeeShowview setFrame:CGRectMake(exfeeShowview.frame.origin.x, exfeeShowview.frame.origin.y, exfeeShowview.frame.size.width, height)];

    [map setFrame:CGRectMake(map.frame.origin.x,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+5,map.frame.size.width,map.frame.size.height)];

    [self reArrangeViews];
    [exfeeShowview calculateColumn];
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col {
    if(index==[exfeeIdentities count])
    {
        if(rsvptoolbar)
            [rsvptoolbar setHidden:YES];
        [self ShowExfeeView];
//        [self ShowExfeeInput:YES];
    }
    else if(index <[exfeeIdentities count]){
        
        [exfeeInput resignFirstResponder];
        [crosstitle resignFirstResponder];
        [crosstitle endEditing:YES];
        [exfeeInput endEditing:YES];
        
        [exfeeSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:![[exfeeSelected objectAtIndex:index] boolValue]]];
        [exfeeShowview reloadData];
        [self ShowRSVPToolBar:index];
//        [exfeeShowview select:0,1,3, nil];
    }
}

#pragma mark RSVPToolbar delegate methods
- (void) rsvpaccept{
    for(int i=0;i< [exfeeSelected count];i++) {
        if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
            if(i<[exfeeIdentities count]) {
            Invitation *invitation=(Invitation*)[exfeeIdentities objectAtIndex:i];
            invitation.rsvp_status=@"ACCEPTED";
            }
        }
    }
    [exfeeShowview reloadData];
}
- (void) rsvpaddmate{
    for(int i=0;i< [exfeeSelected count];i++) {
        if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
            if(i<[exfeeIdentities count]) {
                Invitation *invitation=(Invitation*)[exfeeIdentities objectAtIndex:i];
                if([invitation.mates intValue]<9)
                    invitation.mates=[NSNumber numberWithInt:[invitation.mates intValue]+1];
            }
        }
    }
    [exfeeShowview reloadData];
}
- (void) rsvpsubmate{
    for(int i=0;i< [exfeeSelected count];i++) {
        if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
            if(i<[exfeeIdentities count]) {
                Invitation *invitation=(Invitation*)[exfeeIdentities objectAtIndex:i];
                int mates=[invitation.mates intValue]-1;
                if(mates<0)
                    mates=0;
                invitation.mates=[NSNumber numberWithInt:mates];
            }
        }
    }
    [exfeeShowview reloadData];

}
- (void) rsvpremove{

    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
//    [mutableIndexSet addIndex:0];
//    [mutableIndexSet addIndex:2];
//    [mutableIndexSet addIndex:9];
    for(int i=0;i< [exfeeSelected count];i++) {
        if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
            if(i<[exfeeIdentities count]) {
                [mutableIndexSet addIndex:i];
            }
        }
    }
    [exfeeIdentities removeObjectsAtIndexes:mutableIndexSet];
    [exfeeSelected removeObjectsAtIndexes:mutableIndexSet];

    [mutableIndexSet release];
    [exfeeShowview reloadData];
    
}



@end
