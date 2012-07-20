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

    exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
    exfeeSelected=[[NSMutableArray alloc] initWithCapacity:12];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    float width=self.view.frame.size.width-VIEW_MARGIN*2;
    containview=[[UIView alloc] initWithFrame:CGRectMake(0,0,width,460)];
    [self.view addSubview:containview];
    
    crosstitle=[[UITextField alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6, width, 40)];
    [crosstitle setBorderStyle:UITextBorderStyleRoundedRect];
    [containview addSubview:crosstitle];
    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle becomeFirstResponder];
    
    exfeenum=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15, width, 24)];
    [containview addSubview:exfeenum];
    
    exfeeInput=[[UITextField alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+exfeenum.frame.size.height+8, width, 40)];
    [exfeeInput setPlaceholder:@"Invite friends by name, email…"];
    [exfeeInput setBorderStyle:UITextBorderStyleRoundedRect];
    [exfeeInput setAutocorrectionType:UITextAutocorrectionTypeNo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:)  name:UITextFieldTextDidChangeNotification object:exfeeInput];
    [exfeeInput setDelegate:self];
    [exfeeInput setHidden:YES];
    [containview addSubview:exfeeInput];
    
    //TODO: workaround for a responder chain bug
    exfeeShowview =[[EXImagesCollectionView alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8, width, 120)];
    [exfeeShowview setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8, width, 40+15+5)];
    [exfeeShowview calculateColumn];

    [exfeeShowview setBackgroundColor:[UIColor whiteColor]];
    [containview addSubview:exfeeShowview];
    isExfeeInputShow=NO;

    suggestionTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,60,60) style:UITableViewStylePlain];
    suggestionTable.dataSource=self;
    suggestionTable.delegate=self;
    [exfeeShowview setDataSource:self];
    [exfeeShowview setDelegate:self];
    [self addDefaultIdentity];
    
    map=[[MKMapView alloc] initWithFrame:CGRectMake(VIEW_MARGIN+160,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+5,130,80)];
    
    [containview addSubview:map];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        [self ShowPlaceView];
    };
    
    [map addGestureRecognizer:tapInterceptor];
    [tapInterceptor release];
    
    [self setExfeeNum];
    [self.view bringSubviewToFront:toolbar];
    
    timetitle=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15,160,24)];
    timetitle.text=@"Sometime";
    [timetitle setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    timetitle.textColor=[Util getHighlightColor];
    [containview addSubview:timetitle];

    timedesc=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+24,160,18)];
    timedesc.text=@"Tap here to set time";
    [timedesc setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [containview addSubview:timedesc];
    
    placetitle=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15,160,24)];
    placetitle.text=@"Somwhere";
    [placetitle setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    placetitle.textColor=[Util getHighlightColor];
    [containview addSubview:placetitle];
    
    placedesc=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height,160,18)];
    placedesc.text=@"Tap here to set place";
    [placedesc setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [containview addSubview:placedesc];

    crossdescription=[[UITextView alloc] initWithFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height+placedesc.frame.size.height+10,width,144)];
    [crossdescription setBackgroundColor:[UIColor  grayColor]];
    [crossdescription setDelegate:self];
    
    UISwipeGestureRecognizer *pull = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pullcontainviewDown)];
    [pull setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [crossdescription addGestureRecognizer:pull];
    [pull release];
    [containview addSubview:crossdescription];
    
    boardoffset=6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height+placedesc.frame.size.height;
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
    
    NSLog(@"show time view");
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    NSCharacterSet *split=[NSCharacterSet characterSetWithCharactersInString:@",;"];
    NSArray *identity_list=[textField.text componentsSeparatedByCharactersInSet:split];
    NSString *json=@"";
    for(NSString *identity_input in identity_list)
    {
        NSString *provider=[Util findProvider:identity_input];
        if(![provider isEqualToString:@""])
        {
            if(![json isEqualToString:@""])
                json=[json stringByAppendingString:@","];
            
            json=[json stringByAppendingFormat:@"{\"provider\":\"%@\",\"external_username\":\"%@\"}",provider,identity_input];
        }
    }
    json=[NSString stringWithFormat:@"[%@]",json];
    [self getIdentity:json];
    return YES;
}
- (void)textDidChange:(UITextField*)textField
{
    if(exfeeInput.text!=nil && exfeeInput.text.length>=1) {
        [APIProfile LoadSuggest:exfeeInput.text delegate:self];
        [self loadIdentitiesFromDataStore];
    }
    else{
        [suggestionTable removeFromSuperview];
    }
}

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
- (void) getIdentity:(NSString*)identity_json{
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKClient *client = [RKClient sharedClient];
    NSString *endpoint = [NSString stringWithFormat:@"/identities/get"];

    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:identity_json forParam:@"identities"];
    [client setValue:app.accesstoken forHTTPHeaderField:@"token"];
    [client post:endpoint usingBlock:^(RKRequest *request){
    request.method=RKRequestMethodPOST;
    request.params=rsvpParams;
    request.onDidLoadResponse=^(RKResponse *response){
        if (response.statusCode == 200) {
            NSDictionary *body=[response.body objectFromJSONData];
            if([body isKindOfClass:[NSDictionary class]]) {
                id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                if(code)
                    if([code intValue]==200) {
                        NSDictionary* response = [body objectForKey:@"response"];
                        NSArray *identities = [response objectForKey:@"identities"];
                        for (NSDictionary *identitydict in identities) {
                            NSString *external_id=[identitydict objectForKey:@"external_id"];
                            NSString *provider=[identitydict objectForKey:@"provider"];
                            NSString *avatar_filename=[identitydict objectForKey:@"avatar_filename"];
                            NSString *identity_id=[identitydict objectForKey:@"id"];
                            NSString *name=[identitydict objectForKey:@"name"];
                            NSString *nickname=[identitydict objectForKey:@"nickname"];
                            
                            Identity *identity=[Identity object];
                            identity.external_id=external_id;
                            identity.provider=provider;
                            identity.avatar_filename=avatar_filename;
                            identity.name=name;
                            identity.nickname=nickname;
                            identity.identity_id=[NSNumber numberWithInt:[identity_id intValue]];
                            Invitation *invitation =[Invitation object];
                            invitation.rsvp_status=@"ACCEPTED";
                            invitation.identity=identity;
                            
                            [exfeeIdentities addObject:invitation];
                            [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
                            [exfeeShowview reloadData];
                            [suggestionTable removeFromSuperview];
                            
                        }
                        exfeeInput.text=@"";
                        [exfeeInput setEnabled:YES];
                    }
                }
            }else {
                    [exfeeInput setEnabled:YES];
                //Check Response Body to get Data!
            }
        };
        request.delegate=self;
    }];
    
}

- (void)loadIdentitiesFromDataStore {
        [suggestIdentities release];
        NSFetchRequest* request = [Identity fetchRequest];
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];

        NSString *inputpredicate=[NSString stringWithFormat:@"*%@*",exfeeInput.text];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((name like[c] %@) OR (external_username like[c] %@) OR (external_id like[c] %@) OR (nickname like[c] %@)) AND provider != %@ AND  provider != %@ ",inputpredicate,inputpredicate,inputpredicate,inputpredicate,@"iOSAPN",@"android"];
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        NSMutableArray *temp=[[NSMutableArray alloc]initWithCapacity:10];
        NSArray *suggestwithselected=[[Identity objectsWithFetchRequest:request] retain];
        for (Identity *identity in suggestwithselected){
            BOOL flag=NO;
            for (Invitation *selected in exfeeIdentities){
                if([selected.identity.identity_id intValue]==[identity.identity_id intValue])
                {
                    flag=YES;
                    continue;
                }
            }
            if(flag==NO)
                [temp addObject:identity];
        }
        
        suggestIdentities=[temp retain];
        [temp release];
        if([suggestIdentities count]>0)
        {
            [suggestionTable reloadData];
            CGRect rect=exfeeInput.frame;
            [suggestionTable setFrame:CGRectMake(rect.origin.x, rect.origin.y+rect.size.height, rect.size.width, 200)];
            [suggestionTable setHidden:NO];
            [self.view addSubview:suggestionTable];
        }
        else{
            [suggestionTable removeFromSuperview];
        }
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
        [reset addTarget:self action:@selector(rsvpreset) forControlEvents:UIControlEventTouchUpInside];
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
    //rsvptoolbar.tag=exfeeIndex;
    
    NSLog(@"show rsvp");
}

- (void) ShowExfeeInput:(BOOL)show{
    float width=self.view.frame.size.width-VIEW_MARGIN*2;
    
    [self pullcontainviewDown];
    
    
    if(show==YES && isExfeeInputShow==NO){
        exfeeInput.alpha=0;
        [exfeeInput setHidden:NO];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        [crosstitle setFrame:CGRectMake(VIEW_MARGIN,crosstitle.frame.origin.y-48,crosstitle.frame.size.width,crosstitle.frame.size.height)];
        [exfeenum setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6,exfeenum.frame.size.width, exfeenum.frame.size.height)];
        [exfeeInput setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+exfeenum.frame.size.height+8, width, 40)];
        [UIView commitAnimations];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.25];
        [UIView setAnimationDuration:0.25];
        exfeeInput.alpha=1;
        [UIView commitAnimations];
        isExfeeInputShow=YES;
        [exfeeInput becomeFirstResponder];


    }
    else if(show==NO && isExfeeInputShow==YES){
        CGRect rect=exfeeShowview.frame;
//        rect.origin.y=rect.origin.y-31;
        
        [UIView animateWithDuration:0.25f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
//                             [crosstitle setHidden:NO];
                             [crosstitle setFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6,crosstitle.frame.size.width,crosstitle.frame.size.height)];

                             [exfeenum setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15, width, 24)];
                             [exfeeInput setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+exfeenum.frame.size.height+8, width, 40)];
                             [exfeeInput setHidden:YES];
                             
                             
                             [exfeeShowview setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8, rect.size.width, rect.size.height)];

                             [map setFrame:CGRectMake(map.frame.origin.x,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+rect.size.height+15+5,map.frame.size.width,map.frame.size.height)];
                             isExfeeInputShow=NO;
                             
                         }
                         completion:nil];
        
    }
//    NSLog(@"show exfee input");
}
- (void) setExfeeNum{
    int count=[exfeeIdentities count];
    exfeenum.text=[NSString stringWithFormat:@"%u Exfees",count];
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
        [self ShowExfeeInput:NO];
    }
//    NSLog(@"click view");
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    NSLog(@"textview begin");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:0.25];
    [containview setFrame:CGRectMake(0,-boardoffset,containview.frame.size.width,containview.frame.size.height)];
    [UIView commitAnimations];
    
    return YES;
}
- (void) pullPannelDown{
    [self ShowExfeeInput:NO];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Identity *identity=[suggestIdentities objectAtIndex:indexPath.row];
    Invitation *invitation =[Invitation object];
    invitation.rsvp_status=@"ACCEPTED";
    invitation.identity=identity;

    [exfeeIdentities addObject:invitation];
    [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
    [exfeeShowview reloadData];
    [suggestionTable removeFromSuperview];
    exfeeInput.text=@"";
    [self setExfeeNum];
    //[self ShowExfeeInput:NO];
}

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
//    int old_height=exfeeShowview.frame.size.height;
//    int y_move=height-old_height;

    [exfeeShowview setFrame:CGRectMake(exfeeShowview.frame.origin.x, exfeeShowview.frame.origin.y, exfeeShowview.frame.size.width, height)];

    [map setFrame:CGRectMake(map.frame.origin.x,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+5,map.frame.size.width,map.frame.size.height)];
    [timetitle setFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15,160,24)];
    [timedesc setFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+24,160,18)];
    [placetitle setFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15,160,24)];
    
    [placedesc setFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height,160,18)];

    [crossdescription setFrame:CGRectMake(VIEW_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15+placetitle.frame.size.height+placedesc.frame.size.height+10,crossdescription.frame.size.width,144-60)];
    [exfeeShowview calculateColumn];
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col {
    if(index==[exfeeIdentities count])
    {
        if(rsvptoolbar)
            [rsvptoolbar setHidden:YES];
        [self ShowExfeeInput:YES];
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
- (void) rsvpreset{
    
}



@end
