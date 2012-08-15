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
@synthesize cross;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewmode=false;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
    exfeeSelected=[[NSMutableArray alloc] initWithCapacity:12];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    float width=self.view.frame.size.width-VIEW_MARGIN*2;
    
    CGRect containviewframe=CGRectMake(self.view.frame.origin.x+VIEW_MARGIN,self.view.frame.origin.y+toolbar.frame.size.height,self.view.frame.size.width-VIEW_MARGIN*2, self.view.frame.size.height-toolbar.frame.size.height);
    
    if(viewmode==YES)
        containviewframe=CGRectMake(0,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height-toolbar.frame.size.height);
    containview=[[UIScrollView alloc] initWithFrame:containviewframe];
    [containview setDelegate:self];
    [self.view addSubview:containview];

    backgroundview=[[UIView alloc] initWithFrame:containview.frame];
    [backgroundview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cross_bg.png"]]];
    [containview addSubview:backgroundview];

    containcardview=[[EXOverlayView alloc] initWithFrame:CGRectMake(0, INNER_MARGIN, containview.frame.size.width, containview.frame.size.height)];
    containcardview.backgroundimage=[UIImage imageNamed:@"paper_texture.png"];
    
    [containview addSubview:containcardview];
    title_input_img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gather_title_input_area.png"]];
    [title_input_img setFrame:CGRectMake(0, 0, 308, 69)];
    [containcardview addSubview:title_input_img];

    crosstitle=[[UITextView alloc] initWithFrame:CGRectMake(INNER_MARGIN+30, 5,containview.frame.size.width-INNER_MARGIN-30, 48)];
    crosstitle.tag=101;
    
    [containcardview addSubview:crosstitle];
    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle setDelegate:self];
    [crosstitle setBackgroundColor:[UIColor clearColor]];
    [crosstitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [crosstitle becomeFirstResponder];
    crosstitle_view=[[UILabel alloc] initWithFrame:CGRectMake(15, 10,containview.frame.size.width-30, 50)];
    
    [crosstitle_view setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    crosstitle_view.shadowOffset=CGSizeMake(0, 1);
    crosstitle_view.shadowColor=[UIColor whiteColor];

    [crosstitle_view  setBackgroundColor:[UIColor clearColor]];
    [containcardview addSubview:crosstitle_view];
    [crosstitle_view setHidden:YES];
    
    exfeenum=[[UILabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15, width, 24)];
    [exfeenum setBackgroundColor:[UIColor clearColor]];
    exfeenum.textAlignment=UITextAlignmentRight;
    [containcardview addSubview:exfeenum];
    [exfeenum setHidden:YES];
    
    //TODO: workaround for a responder chain bug
    exfeeShowview =[[EXImagesCollectionView alloc] initWithFrame:CGRectMake(INNER_MARGIN, crosstitle.frame.origin.x+crosstitle.frame.size.height, width, 120)];
    [exfeeShowview setFrame:CGRectMake(INNER_MARGIN-6, 69, width, 40+15+4)];
    [exfeeShowview calculateColumn];
    [exfeeShowview setBackgroundColor:[UIColor clearColor]];
    
    [containcardview addSubview:exfeeShowview];

    [exfeeShowview setDataSource:self];
    [exfeeShowview setDelegate:self];
    
    map=[[MKMapView alloc] initWithFrame:CGRectMake(INNER_MARGIN+160,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+5,130,80)];
    [containcardview addSubview:map];
    mapbox=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_area_null.png"]];
    [containcardview addSubview:mapbox];
    
    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        [self ShowPlaceView];
    };
    [map addGestureRecognizer:tapInterceptor];
    [tapInterceptor release];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [containcardview addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];

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
    [crossdescription setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
    crossdescription.tag=108;

    crossdescbackimg=[[UIView alloc] initWithFrame:CGRectMake(crossdescription.frame.origin.x, crossdescription.frame.origin.y, crossdescription.frame.size.width, 75)];
    crossdescbackimg.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"gather_describe_area.png"]];
                              
    [containcardview addSubview:crossdescbackimg];
    [crossdescription setBackgroundColor:[UIColor clearColor]];
    [crossdescription setDelegate:self];
    [containcardview addSubview:crossdescription];
    if(viewmode==YES){
        UIImage *chatimg = [UIImage imageNamed:@"chat.png"];
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chatButton setTitle:@"Chat" forState:UIControlStateNormal];
        [chatButton setImage:chatimg forState:UIControlStateNormal];
        chatButton.frame = CGRectMake(0, 0, chatimg.size.width, chatimg.size.height);
        [chatButton addTarget:self action:@selector(toconversation) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        
        self.navigationItem.rightBarButtonItem = barButtonItem;
        [barButtonItem release];
        conversationView=[[ConversationViewController alloc]initWithNibName:@"ConversationViewController" bundle:nil] ;
        conversationView.exfee_id=[cross.exfee.exfee_id intValue];
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSSet *invitations=cross.exfee.invitations;
        if(invitations !=nil&&[invitations count]>0)
        {
            for(Invitation* invitation in invitations)
                if([invitation.identity.connected_user_id intValue]==app.userid)
                    conversationView.identity=invitation.identity;  
        }
        [conversationView.view setHidden:YES];
        [self.view addSubview:conversationView.view];
    }
    [self initData];
    [self reArrangeViews];
    if(viewmode==YES)
        [self ShowRsvpButton];
}
- (void) initData{
    if(self.cross!=nil && viewmode==YES){
        crosstitle.text=cross.title;
        [self setExfeeNum];
        NSArray *widgets=cross.widget;
        for(NSDictionary *widget in widgets) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                NSString *imgurl=[NSString stringWithFormat:@"%@/xbg/%@",IMG_ROOT,[widget objectForKey:@"image"]];
                UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, containview.frame.size.width, 180)];
                UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                if(backimg!=nil && ![backimg isEqual:[NSNull null]]) 
                    imageview.image=backimg;

                UIImageView *imagemaskview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, containview.frame.size.width, 180)];
                imagemaskview.image=[UIImage imageNamed:@"cross_bgmask.png"];
                
                [backgroundview addSubview:imageview];
                [backgroundview addSubview:imagemaskview];
                [imagemaskview release];
                [imageview release];
            }
        }
        [self setDateTime:cross.time];
        NSDictionary *placedict=[NSDictionary dictionaryWithKeysAndObjects:@"title",cross.place.title,@"description",cross.place.place_description,@"lat",cross.place.lat, @"lng",cross.place.lng,@"external_id",cross.place.external_id,@"provider",cross.place.provider, nil];
        [self setPlace:placedict];
        
        crossdescription.text=cross.cross_description;
        for(Invitation *invitation in cross.exfee.invitations)
        {
            if([invitation.host boolValue]==YES)
                [exfeeIdentities insertObject:invitation atIndex:0];
            else{
                [exfeeIdentities addObject:invitation];
            }
            [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
        }
        [exfeeShowview reloadData];
    }
    else if(viewmode==NO){
        [self addDefaultIdentity];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
{
    if(textView.tag==101)
    {
        NSString* newText = [textView.text stringByReplacingCharactersInRange:aRange withString:aText];
        CGSize tallerSize = CGSizeMake(textView.frame.size.width-15,textView.frame.size.height*2);
        CGSize newSize = [newText sizeWithFont:textView.font constrainedToSize:tallerSize lineBreakMode:UILineBreakModeWordWrap];
        
        if (newSize.height > textView.frame.size.height)
        {
            return NO;
        }
        else
            return YES;
    }
    return YES;
}
- (void) reArrangeViews{

    CGSize timetitleconstraint = CGSizeMake(160,timetitle.frame.size.height);
    CGSize timetitlesize = [timetitle.text sizeWithFont:timetitle.font constrainedToSize:timetitleconstraint lineBreakMode:UILineBreakModeWordWrap];
    [timetitle setFrame:CGRectMake(INNER_MARGIN, exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10,timetitlesize.width,24)];
    
    CGSize timedescconstraint = CGSizeMake(160,timedesc.frame.size.height);
    CGSize timedescsize = [timedesc.text sizeWithFont:timedesc.font constrainedToSize:timedescconstraint lineBreakMode:UILineBreakModeWordWrap];
    [timedesc setFrame:CGRectMake(INNER_MARGIN,timetitle.frame.origin.y+timetitle.frame.size.height,timedescsize.width,18)];

    CGSize placetitleconstraint = CGSizeMake(160,placetitle.frame.size.height);
    CGSize placetitlesize = [placetitle.text sizeWithFont:placetitle.font constrainedToSize:placetitleconstraint lineBreakMode:UILineBreakModeTailTruncation];
    [placetitle setFrame:CGRectMake(INNER_MARGIN,timedesc.frame.origin.y+timedesc.frame.size.height+15,placetitlesize.width,placetitle.frame.size.height)];
    
    CGSize placedescconstraint = CGSizeMake(containcardview.frame.size.width-INNER_MARGIN*2,400);
    CGSize placedescsize = [placedesc.text sizeWithFont:placedesc.font constrainedToSize:placedescconstraint lineBreakMode:UILineBreakModeWordWrap];
    [placedesc setFrame:CGRectMake(INNER_MARGIN,placetitle.frame.origin.y+placetitle.frame.size.height,placedescsize.width,placedescsize.height)];

    [map setFrame:CGRectMake(INNER_MARGIN+170+6,exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10+7,115,70)];
    [mapbox setFrame:CGRectMake(INNER_MARGIN+170,exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10,126,84)];
    [crossdescription setFrame:CGRectMake(0,placedesc.frame.origin.y+placedesc.frame.size.height+15,containview.frame.size.width,145)];
    [crossdescbackimg setFrame:CGRectMake(crossdescription.frame.origin.x, crossdescription.frame.origin.y-9, crossdescription.frame.size.width, 75)];

    containview.alwaysBounceVertical=YES;
    if(viewmode==YES){
        CGRect backgroundrect=backgroundview.frame;
        if(backgroundrect.origin.y>=0)
        {
            backgroundrect.origin.y=-72;
            backgroundrect.size.height=self.view.frame.size.height+72-44;
            [backgroundview setFrame:backgroundrect];
        }
        [crosstitle resignFirstResponder];
        [toolbar setHidden:YES];
        [crosstitle setHidden:YES];
        [title_input_img setHidden:YES];
        [crosstitle_view setHidden:NO];
        crosstitle_view.text=crosstitle.text;
        CGRect cardframe=containcardview.frame;
        cardframe.origin.y=0;
        [containcardview setFrame:cardframe];
        [exfeenum setFrame:CGRectMake(containcardview.frame.size.width-15-124, 54, 124, 27)];
        [exfeenum setHidden:NO];

        
        containcardview.backgroundimage=nil;
        [crossdescription setEditable:NO];
        [exfeeShowview HiddenAddButton];
        CGRect exfeshowframe=exfeeShowview.frame;
        exfeshowframe.origin.x=15-5;
        [exfeeShowview setFrame:exfeshowframe];

//        CGSize constrainedSize = CGSizeMake(500,timetitle.frame.size.height);
//        CGSize newtimetitleSize = [timetitle.text sizeWithFont:timetitle.font constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];

        CGRect timetitleframe=timetitle.frame;
        timetitleframe.origin.x=15;
//        timetitleframe.size.width=newtimetitleSize.width;

//        if(timetitleframe.size.width>175) // MAX timetitle width=175
//            timetitleframe.size.width=175;
        
        [timetitle setFrame:timetitleframe];

        CGRect timedescframe=timedesc.frame;
        timedescframe.origin.x=15;
        [timedesc setFrame:timedescframe];

        CGRect placetitleframe=placetitle.frame;
        placetitleframe.origin.x=15;
        [placetitle setFrame:placetitleframe];
        
        CGRect placedescframe=placedesc.frame;
        placedescframe.origin.x=15;
        [placedesc setFrame:placedescframe];

    }else{
        [containview setContentSize:CGSizeMake(containview.frame.size.width, containcardview.frame.size.height+20)];

        [backgroundview setHidden:YES];
        
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

    }
    
    [containcardview setNeedsDisplay];
}
- (void) setViewMode{
    viewmode=YES;
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
    
    Cross *_cross=[Cross object];
    _cross.title=crosstitle.text;
    _cross.cross_description=crossdescription.text;
    _cross.by_identity=by_identity;
    _cross.place=place;
    _cross.time=datetime;
    Exfee *exfee=[Exfee object];
    for(Invitation *invitation in exfeeIdentities){
        [exfee addInvitationsObject:invitation];
    }
    _cross.exfee = exfee;
    
    [APICrosses GatherCross:_cross delegate:self];
}
- (void)dealloc {
	[exfeeIdentities release];
    [exfeeSelected release];
    [suggestIdentities release];
    [exfeeShowview release];
    [crosstitle release];
    [title_input_img release];
    [map release];
    [mapbox release];
    [crossdescription release];
    [timetitle release];
    [timedesc release];
    [placetitle release];
    [placedesc release];
    [gathertoolbar release];
    [rsvptoolbar release];
    [myrsvptoolbar release];
    if(rsvpbutton)
        [rsvpbutton release];
    [containview release];
    [backgroundview release];
    [containcardview release];
    [crossdescbackimg release];
    [conversationView release];
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

- (void) addExfee:(Invitation*) invitation{
    [exfeeIdentities addObject:invitation];
    [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
    [exfeeShowview reloadData];
}


- (void) setPlace:(NSDictionary*)placedict{
    Place *_place=[Place object];
    NSNumber *lat=[placedict objectForKey:@"lat"];
    NSNumber *lng=[NSNumber numberWithDouble:[[placedict objectForKey:@"lng"] doubleValue]];
        
    _place.lat= lat;
    _place.lng= lng;
    
    _place.title=[placedict objectForKey:@"title"];
    _place.place_description =[placedict objectForKey:@"description"];
    _place.external_id=[placedict objectForKey:@"external_id"];
    _place.provider=[placedict objectForKey:@"provider"];
    place=_place;

    if([lat isEqualToNumber:[NSNumber numberWithInt:0]] && [lng isEqualToNumber:[NSNumber numberWithInt:0]] && [_place.title isEqualToString:@""] && [_place.place_description isEqualToString:@""])
    {
        _place.title=@"Somewhere";
        place=nil;
    }

    placetitle.text=_place.title;
    placedesc.text=_place.place_description;

    if(viewmode==NO)
        [self reArrangeViews];
    if(place!=nil) {
        CLLocationCoordinate2D location;
        [map removeAnnotations: map.annotations];
        location.latitude = [_place.lat doubleValue];
        location.longitude = [_place.lng doubleValue];
        MKCoordinateRegion region;
        region.center = location;
        region.span.longitudeDelta = 0.005;
        region.span.latitudeDelta = 0.005;
        [map setRegion:region animated:YES];
        mapbox.image=[UIImage imageNamed:@"map_area.png"];
    }
}

- (void) setDateTime:(CrossTime*)crosstime{
    timetitle.text=[Util getTimeTitle:crosstime];
    timedesc.text=[Util getTimeDesc:crosstime];
    datetime=crosstime;
    if(viewmode==NO)
        [self reArrangeViews];
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
- (void) toconversation{
    if(conversationView.view.isHidden==YES)
    {
        [conversationView.view setHidden:NO];
        [conversationView refreshConversation];
        cross.conversation_count=0;
        NSError *saveError;
        [[Cross currentContext] save:&saveError];
        
        for(id viewcontroller in self.navigationController.viewControllers)
        {
            if([viewcontroller isKindOfClass:[CrossesViewController class]])
            {
                [viewcontroller refreshCell];
            }
        }
        [UIView transitionFromView:self.view toView:conversationView.view duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    }
    else {
        [UIView transitionFromView:conversationView.view toView:self.view duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        [conversationView.view setHidden:YES];
    }
}
- (void) ShowMyRsvpToolBar{
    if(myrsvptoolbar==nil){
        myrsvptoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, 460-44-50) buttonsize:CGSizeMake(20, 20) delegate:self];

        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"I'm in" image:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] inFrame:CGRectMake(0, 6, 107, 30)];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];
        
        EXButton *interested=[[EXButton alloc] initWithName:@"interested" title:@"Interested" image:[UIImage imageNamed:@"rsvp_interested_toolbar.png"] inFrame:CGRectMake(107, 6, 107, 30)];
        [interested addTarget:self action:@selector(rsvpinterested) forControlEvents:UIControlEventTouchUpInside];
        
        EXButton *decline=[[EXButton alloc] initWithName:@"decline" title:@"Decline" image:[UIImage imageNamed:@"rsvp_unavailable_toolbar.png"] inFrame:CGRectMake(214, 6, 107, 30)];
        [decline addTarget:self action:@selector(rsvpdeclined) forControlEvents:UIControlEventTouchUpInside];

        NSArray *array=[NSArray arrayWithObjects:interested,accept,decline, nil];
        [myrsvptoolbar drawButton:array];
        
        [accept release];
        [interested release];
        [decline release];
        
        [self.view addSubview:myrsvptoolbar];
    }
    [rsvptoolbar setHidden:YES];
    [rsvpbutton setHidden:YES];
    [myrsvptoolbar setHidden:NO];
}


- (void) ShowRsvpToolBar{
    if(rsvptoolbar==nil){
        rsvptoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, 460-44-50) buttonsize:CGSizeMake(20, 20) delegate:self];

        EXButton *submate=[[EXButton alloc] initWithName:@"submate" title:@"-1 mate" image:[UIImage imageNamed:@"rsvp_mates_minus_toolbar.png"] inFrame:CGRectMake(14, 6, 44, 30)];
        [submate addTarget:self action:@selector(rsvpsubmate) forControlEvents:UIControlEventTouchUpInside];
        [submate setTitle:@"" forState:UIControlStateNormal];
        EXButton *addmate=[[EXButton alloc] initWithName:@"addmate" title:@"+1 mate" image:[UIImage imageNamed:@"rsvp_mates_plus_toolbar.png"] inFrame:CGRectMake(58, 6, 44, 30)];
        [addmate addTarget:self action:@selector(rsvpaddmate) forControlEvents:UIControlEventTouchUpInside];
        [addmate setTitle:@"" forState:UIControlStateNormal];
        
        UILabel *hint=[[UILabel alloc] initWithFrame:CGRectMake(44, 30+6, 44, 14)];
        hint.text=@"Mates";
        [hint setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
        [hint setBackgroundColor:[UIColor clearColor]];
        hint.textAlignment=UITextAlignmentCenter;
        [hint setTextColor:FONT_COLOR_250];
        [rsvptoolbar addSubview:hint];
        [hint release];

        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"Accept" image:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] inFrame:CGRectMake(116, 6, 68, 30)];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];

        EXButton *ignore=[[EXButton alloc] initWithName:@"ignore" title:@"Pending" image:[UIImage imageNamed:@"rsvp_pending_toolbar.png"] inFrame:CGRectMake(184, 6, 68, 30)];
        [ignore addTarget:self action:@selector(rsvpinterested) forControlEvents:UIControlEventTouchUpInside];

        EXButton *decline=[[EXButton alloc] initWithName:@"decline" title:@"Unavailable" image:[UIImage imageNamed:@"rsvp_unavailable_toolbar.png"] inFrame:CGRectMake(252, 6, 68, 30)];
        [decline addTarget:self action:@selector(rsvpdeclined) forControlEvents:UIControlEventTouchUpInside];

        NSArray *array=[NSArray arrayWithObjects:submate,addmate,ignore,accept,decline, nil];
        [rsvptoolbar drawButton:array];
        [submate release];
        [addmate release];
        [ignore release];
        [accept release];
        [decline release];
        [self.view addSubview:rsvptoolbar];
    }
    [myrsvptoolbar setHidden:YES];
    [rsvpbutton setHidden:YES];
    [rsvptoolbar setHidden:NO];
}

- (void) ShowRsvpButton{
    [rsvptoolbar setHidden:YES];

    if(rsvpbutton)
        [rsvpbutton release];
    Invitation *myInvitation=[self getMyInvitation];
    if(myInvitation && ![myInvitation.rsvp_status isEqualToString:@"NORESPONSE"])
    {
        NSString *buttonimgname=@"";
        if([myInvitation.rsvp_status isEqualToString:@"ACCEPTED"])
            buttonimgname=@"rsvp_accept_toolbar.png";
        else if([myInvitation.rsvp_status isEqualToString:@"INTERESTED"])
            buttonimgname=@"rsvp_interested_toolbar.png";
        else if([myInvitation.rsvp_status isEqualToString:@"DECLINED"])
            buttonimgname=@"rsvp_unavailable_toolbar.png";
        
        rsvpbutton=[[EXButton alloc] initWithName:@"accept" title:@"Accept" image:[UIImage imageNamed:buttonimgname] inFrame:CGRectMake(self.view.frame.size.width/2-30, 460-44-30, 60, 30)];
        
        [rsvpbutton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bg.png"]]];
        [rsvpbutton addTarget:self action:@selector(ShowMyRsvpToolBar) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rsvpbutton];
        [myrsvptoolbar setHidden:YES];
    }
    else
        [myrsvptoolbar setHidden:NO];
}
- (void) ShowGatherToolBar{
    if(gathertoolbar==nil){
        gathertoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, self.view.frame.size.height-50) buttonsize:CGSizeMake(20, 20) delegate:self];
        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"Accept" image:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] inFrame:CGRectMake(35, 6, 36, 30)];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];
        
        EXButton *submate=[[EXButton alloc] initWithName:@"submate" title:@"-1 mate" image:[UIImage imageNamed:@"rsvp_mates_minus_toolbar.png"] inFrame:CGRectMake(35+36+45, 6, 44, 30)];
        [submate addTarget:self action:@selector(rsvpsubmate) forControlEvents:UIControlEventTouchUpInside];
        [submate setTitle:@"" forState:UIControlStateNormal];
        EXButton *addmate=[[EXButton alloc] initWithName:@"addmate" title:@"+1 mate" image:[UIImage imageNamed:@"rsvp_mates_plus_toolbar.png"] inFrame:CGRectMake(35+36+45+44, 6, 44, 30)];
        [addmate addTarget:self action:@selector(rsvpaddmate) forControlEvents:UIControlEventTouchUpInside];
        [addmate setTitle:@"" forState:UIControlStateNormal];
        
        EXButton *remove=[[EXButton alloc] initWithName:@"remove" title:@"Remove" image:[UIImage imageNamed:@"remove_toolbar.png"] inFrame:CGRectMake(35+36+45+44+44+45, 6, 36, 30)];
        [remove addTarget:self action:@selector(rsvpremove) forControlEvents:UIControlEventTouchUpInside];
        NSArray *array=[NSArray arrayWithObjects:accept,submate,addmate,remove, nil];
        [gathertoolbar drawButton:array];
        [accept release];
        [addmate release];
        [submate release];
        [remove release];
        
        UILabel *hint=[[UILabel alloc] initWithFrame:CGRectMake(35+36+45+22, 30+6, 44, 14)];
        hint.text=@"Mates";
        [hint setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
        [hint setBackgroundColor:[UIColor clearColor]];
        hint.textAlignment=UITextAlignmentCenter;
        [hint setTextColor:FONT_COLOR_250];
        [gathertoolbar addSubview:hint];
        [hint release];
        [self.view addSubview:gathertoolbar];
    }
    BOOL isAllAccept=YES;
    int idx=0;
    for(NSNumber *number in exfeeSelected)
    {
        if([number boolValue]==YES)
        {
            Invitation *invitation=[exfeeIdentities objectAtIndex:idx];
            if(![invitation.rsvp_status isEqualToString:@"ACCEPTED"])
            {
                    isAllAccept=NO;
            }
        }
        idx++;
    }
    if(isAllAccept==YES)
        [gathertoolbar replaceButtonImage:[UIImage imageNamed:@"rsvp_accept_toolbar_grey.png"] title:@"Un-accept" target:self action:@selector(rsvpunaccept) forname:@"accept"];
    else
        [gathertoolbar replaceButtonImage:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] title:@"Accept" target:self action:@selector(rsvpaccept) forname:@"accept"];
    [gathertoolbar setHidden:NO];
}

- (void) updateButtonFrame:(NSString*)name frame:(CGRect)rect{
    
}
- (Invitation*) getMyInvitation{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    for(Invitation *invitation in exfeeIdentities)
    {
        if([invitation.identity.connected_user_id intValue] == app.userid)
            return invitation;
    }
    return nil;
}
- (void) setExfeeNum{
    NSString *total=[cross.exfee.total stringValue];
    NSString *accepted=[cross.exfee.accepted stringValue];
    
    
    NSMutableAttributedString * exfeestr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@",accepted,total]];
    
    [exfeestr addAttribute:NSForegroundColorAttributeName value:FONT_COLOR_HL range:NSMakeRange(0,accepted.length)];
    [exfeestr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:21] range:NSMakeRange(0,accepted.length)];
    
    [exfeestr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(accepted.length,exfeestr.length-accepted.length)];
    [exfeestr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:13] range:NSMakeRange(accepted.length,exfeestr.length-accepted.length)];
    
    exfeenum.attributedText=exfeestr;//[NSString stringWithFormat:@"%u Exfees",count];
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
        [crosstitle resignFirstResponder];
        [exfeeShowview becomeFirstResponder];
        CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
        [exfeeShowview onImageTouch:exfeeviewlocation];
    }
    else{
    [crosstitle resignFirstResponder];
    [map becomeFirstResponder];
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
//        [exfeeInput resignFirstResponder];
        [map becomeFirstResponder];
//        [self ShowExfeeInput:NO];
    }
//    NSLog(@"click view");
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    float KEYBOARD_LANDSCAPE=216;
    if(textView.tag==108)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.25];
        float y=crossdescbackimg.frame.origin.y-(self.view.frame.size.height-toolbar.frame.size.height-KEYBOARD_LANDSCAPE-crossdescription.frame.size.height-20);
        [containview setContentOffset:CGPointMake(0, y)];
        [UIView commitAnimations];
    }
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
        [app GatherCrossDidFinish];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
    //    [self stopLoading];
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

    [exfeeShowview setFrame:CGRectMake(exfeeShowview.frame.origin.x, exfeeShowview.frame.origin.y, exfeeShowview.frame.size.width, height)];
//    [map setFrame:CGRectMake(map.frame.origin.x,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+5,map.frame.size.width,map.frame.size.height)];
    [exfeeShowview calculateColumn];
    if(viewmode==NO)
        [self reArrangeViews];
    
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col {
    if(index==[exfeeIdentities count])
    {
        [self ShowGatherToolBar];
//        if(gathertoolbar)
//            [gathertoolbar setHidden:YES];
        [self ShowExfeeView];
    }
    else if(index <[exfeeIdentities count]){
        
        [crosstitle resignFirstResponder];
        [crosstitle endEditing:YES];
        
        [exfeeSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:![[exfeeSelected objectAtIndex:index] boolValue]]];
        [exfeeShowview reloadData];
        BOOL isSelect=NO;
        for(NSNumber *number in exfeeSelected){
            if([number boolValue]==YES)
                isSelect=YES;
        }
        if(isSelect){
            if(viewmode==YES)
                [self ShowRsvpToolBar];
            else
                [self ShowGatherToolBar];
        }
        else
        {
            if(viewmode==YES)
                [self ShowRsvpButton];
//            else
//                [self ShowRsvpToolBar];
        }
    }
}

- (void) sendrsvp:(NSString*)status{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSNumber *by_identity_id=[NSNumber numberWithInt:0];
    for (Invitation* invitation in cross.exfee.invitations )
    {
        if([invitation.identity.connected_user_id intValue] == app.userid)
            by_identity_id=invitation.identity.identity_id;
    }
    if(by_identity_id>0)
    {
        NSMutableArray *postarray= [[NSMutableArray alloc] initWithCapacity:12];
        BOOL selected=NO;
            for(int i=0;i< [exfeeSelected count];i++) {
                if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
                    selected=YES;
                    if(i<[exfeeIdentities count]) {
                        Invitation *invitation=(Invitation*)[exfeeIdentities objectAtIndex:i];
                        invitation.rsvp_status=status;
                        NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:invitation.identity.identity_id,@"identity_id",by_identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
                        [postarray addObject:rsvpdict];
                    }
                }
            }
        
            if(selected==NO){
            // is host
                Invitation *invitation=[self getMyInvitation];
                if(invitation!=nil) {
                    invitation.rsvp_status=status;
                    NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:invitation.identity.identity_id,@"identity_id",by_identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
                    [postarray addObject:rsvpdict];
            }
        }
        
        if(viewmode==YES)
        {
            RKParams* rsvpParams = [RKParams params];
            [rsvpParams setValue:[postarray JSONString] forParam:@"rsvp"];
            RKClient *client = [RKClient sharedClient];
            NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/rsvp?token=%@",[cross.exfee.exfee_id intValue],app.accesstoken];
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
                                    [exfeeShowview reloadData];
//                                    NSLog(@"send rsvp ok!");
                                }
                        }
                        //We got an error!
                    }else {
                        //Check Response Body to get Data!
                    }
                    if(selected==NO)
                        [self ShowRsvpButton];
                    else
                        [self ShowRsvpToolBar];

                };
                request.onDidFailLoadWithError=^(NSError *error){
                    NSLog(@"%@",error);
                    if(selected==NO)
                        [self ShowMyRsvpToolBar];
                    else
                        [self ShowRsvpToolBar];
                    
                };
                request.delegate=self;
            }];
        }
    }
//    [exfeeShowview reloadData];
//    [self ShowGatherToolBar];
}
#pragma mark GatherToolbar delegate methods
- (void) rsvpaccept{
        [self sendrsvp:@"ACCEPTED"];
}

- (void) rsvpinterested{
        [self sendrsvp:@"INTERESTED"];
}

- (void) rsvpdeclined{
        [self sendrsvp:@"DECLINED"];
}

- (void) rsvpunaccept{
    [self sendrsvp:@"NORESPONSE"];
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
    [exfeeShowview calculateColumn];
    [exfeeShowview reloadData];
    
}



@end
