//
//  NewGatherViewController.m
//  EXFE
//
//  Created by huoju on 1/4/13.
//
//

#import "NewGatherViewController.h"
#import "Util.h"
#import "EFTime.h"
#import "ImgCache.h"
#import "MapPin.h"
#import "Place+Helper.h"


#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (16)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (88)
#define DECTOR_HEIGHT_EXTRA              (LARGE_SLOT)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define OVERLAP                          (DECTOR_HEIGHT)
#define CONTAINER_TOP_MARGIN             (DECTOR_HEIGHT - OVERLAP)
#define CONTAINER_TOP_PADDING            (DECTOR_HEIGHT_EXTRA + DECTOR_MARGIN + OVERLAP)
#define CONTAINER_VERTICAL_PADDING       (15)
#define DESC_MIN_HEIGHT                  (18)
#define DESC_MAX_HEIGHT                  (90)
#define DESC_BOTTOM_MARGIN               (LARGE_SLOT)
#define EXFEE_OVERLAP                    (12)
#define EXFEE_HORIZON_PADDING            (SMAILL_SLOT)
#define EXFEE_HEIGHT                     (50)
#define EXFEE_BOTTOM_MARGIN              (LARGE_SLOT - SMALL_SLOT)
#define TIME_RELATIVE_HEIGHT             (MAIN_TEXT_HIEGHT)
#define TIME_RELATIVE_BOTTOM_MARGIN      (SMALL_SLOT)
#define TIME_ABSOLUTE_HEIGHT             (ALTERNATIVE_TEXT_HIEGHT)
#define TIME_ABSOLUTE_RIGHT_MARGIN       (SMALL_SLOT)
#define TIME_ZONE_HEIGHT                 (ALTERNATIVE_TEXT_HIEGHT)
#define TIME_BOTTOM_MARGIN               (LARGE_SLOT)
#define PLACE_TITLE_HEIGHT               (MAIN_TEXT_HIEGHT)
#define PLACE_TITLE_BOTTOM_MARGIN        (SMALL_SLOT)
#define PLACE_DESC_HEIGHT                (ALTERNATIVE_TEXT_HIEGHT * 4)
#define PLACE_DESC_MIN_HEIGHT            (20)
#define PLACE_DESC_MAX_HEIGHT            (90)
#define PLACE_DESC_BOTTOM_MARGIN         (LARGE_SLOT)
#define TITLE_HORIZON_MARGIN             (SMALL_SLOT)
#define TITLE_VERTICAL_MARGIN            (18)


@interface NewGatherViewController ()

@end

@implementation NewGatherViewController
@synthesize cross;
@synthesize default_user;
@synthesize title_be_edit;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initUI{
    
    CGRect f = self.view.frame;
    CGRect c = CGRectMake(f.origin.x, f.origin.y + CONTAINER_TOP_MARGIN, f.size.width, f.size.height - f.origin.y - CONTAINER_TOP_MARGIN);
    container = [[UIScrollView alloc] initWithFrame:c];
    {
        
        int left = CONTAINER_VERTICAL_PADDING;
        descView = [[EXLabel alloc] initWithFrame:CGRectMake(left, CONTAINER_TOP_PADDING, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, 80)];
        descView.textColor = [UIColor COLOR_RGB(0x33, 0x33, 0x33)];
        descView.numberOfLines = 4;
        descView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        descView.shadowColor = [UIColor whiteColor];
        descView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        descView.backgroundColor = [UIColor clearColor];
        descView.lineBreakMode = NSLineBreakByWordWrapping;
        descView.text=@"Take some note";
        [container addSubview:descView];
        
        exfeeSuggestHeight = 70;
        exfeeShowview = [[EXImagesCollectionGatherView alloc]initWithFrame:CGRectMake(c.origin.x, CGRectGetMaxY(descView.frame) + DESC_BOTTOM_MARGIN - EXFEE_OVERLAP, c.size.width, exfeeSuggestHeight + EXFEE_OVERLAP)];
        exfeeShowview.backgroundColor = [UIColor clearColor];
        [exfeeShowview calculateColumn];
        [exfeeShowview setDataSource:self];
        [exfeeShowview setDelegate:self];
        [container addSubview:exfeeShowview];
        
        timeRelView = [[UILabel alloc] initWithFrame:CGRectMake(left, exfeeShowview.frame.origin.y + exfeeShowview.frame.size.height + EXFEE_BOTTOM_MARGIN, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, TIME_RELATIVE_HEIGHT)];
        timeRelView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        timeRelView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        timeRelView.shadowColor = [UIColor whiteColor];
        timeRelView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeRelView.backgroundColor = [UIColor clearColor];
        [container addSubview:timeRelView];
        
        timeAbsView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeRelView.frame.origin.y + timeRelView.frame.size.height + TIME_RELATIVE_BOTTOM_MARGIN, c.size.width /2 -  CONTAINER_VERTICAL_PADDING, TIME_ABSOLUTE_HEIGHT)];
        timeAbsView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        timeAbsView.shadowColor = [UIColor whiteColor];
        timeAbsView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeAbsView.backgroundColor = [UIColor clearColor];
        
        [container addSubview:timeAbsView];
        
        timeZoneView= [[UILabel alloc] initWithFrame:CGRectMake(left + timeAbsView.frame.size.width + TIME_ABSOLUTE_RIGHT_MARGIN, timeAbsView.frame.origin.y, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 - timeAbsView.frame.size.width  - TIME_ABSOLUTE_RIGHT_MARGIN , TIME_ZONE_HEIGHT)];
        timeZoneView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        timeZoneView.backgroundColor = [UIColor clearColor];
        [container addSubview:timeZoneView];
        
        placeTitleView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeAbsView.frame.origin.y + timeAbsView.frame.size.height + TIME_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_TITLE_HEIGHT)];
        placeTitleView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        placeTitleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        placeTitleView.shadowColor = [UIColor whiteColor];
        placeTitleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeTitleView.numberOfLines = 2;
        placeTitleView.backgroundColor = [UIColor clearColor];
        [container addSubview:placeTitleView];
        
        placeDescView= [[UILabel alloc] initWithFrame:CGRectMake(left, placeTitleView.frame.origin.y + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_DESC_HEIGHT)];
        placeDescView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        placeDescView.shadowColor = [UIColor whiteColor];
        placeDescView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeDescView.numberOfLines = 4;
        placeDescView.lineBreakMode = NSLineBreakByWordWrapping;
        placeDescView.backgroundColor = [UIColor clearColor];
        [container addSubview:placeDescView];
        
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) ;
        int b = (placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + c.origin.y + OVERLAP /*+ DECTOR_HEIGHT_EXTRA*/);
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, placeDescView.frame.origin.y + placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b)];
        mapView.backgroundColor = [UIColor lightGrayColor];
        mapView.delegate = self;
        [container addSubview:mapView];
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = container.frame.origin.y + placeDescView.frame.origin.y + placeDescView.frame.size.height;
        }else{
            s.height = container.frame.origin.y + mapView.frame.origin.y + mapView.frame.size.height;
        }
        container.contentSize = s;
        
    }
    container.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:container];
    
    headview = [[EXCurveView alloc] initWithFrame:CGRectMake(f.origin.x, f.origin.y, f.size.width, DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA) withCurveFrame:CGRectMake(f.origin.x + f.size.width * 0.6, f.origin.y +  DECTOR_HEIGHT, 40, DECTOR_HEIGHT_EXTRA) ];
    headview.backgroundColor=[UIColor grayColor];
    {
        CGFloat scale = CGRectGetWidth(headview.bounds) / 880.0f;
        CGFloat startY = 0 - 198 * scale;
        dectorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, startY, 880 * scale, 495 * scale)];
        dectorView.image=[UIImage imageNamed:@"x_title_bg.png"];
        [headview addSubview:dectorView];
        
        UIView* dectorMask = [[UIView alloc] initWithFrame:headview.bounds];
        dectorMask.backgroundColor = [UIColor COLOR_WA(0x00, 0x55)];
        [headview addSubview:dectorMask];
        [dectorMask release];
        
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnBack.frame) + TITLE_HORIZON_MARGIN, TITLE_VERTICAL_MARGIN, f.size.width - (CGRectGetMaxX(btnBack.frame) + TITLE_HORIZON_MARGIN) * 2, DECTOR_HEIGHT - TITLE_VERTICAL_MARGIN * 2)];
        titleView.textColor = [UIColor COLOR_RGB(0xFE, 0xFF,0xFF)];
        titleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.lineBreakMode = UILineBreakModeWordWrap;
        titleView.numberOfLines = 2;
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.shadowColor = [UIColor blackColor];
        titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        [headview addSubview:titleView];
    }
    [self.view addSubview:headview];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 /2, 20, 44)];
    btnBack.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(Close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    UIView *pannel=[[UIView alloc] initWithFrame:CGRectMake(0,screenframe.size.height-44-20, self.view.frame.size.width, 44)];
    [pannel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33]];

    UIButton *btngather=[UIButton buttonWithType:UIButtonTypeCustom];
    [btngather setFrame:CGRectMake(99, 8.5, 122, 32)];
    [btngather setTitle:@"Gather" forState:UIControlStateNormal];
    [btngather.titleLabel setShadowColor:[UIColor blackColor]];
    [btngather.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    btngather.layer.cornerRadius=2;
    [btngather addTarget:self action:@selector(Gather:) forControlEvents:UIControlEventTouchUpInside];

    [btngather setBackgroundImage:[[UIImage imageNamed:@"btn_glass_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0,5)] forState:UIControlStateNormal];
    [pannel addSubview:btngather];
    [self.view addSubview:pannel];
    [pannel release];

    pannellight=[[UIImageView alloc] initWithFrame:CGRectMake(0,screenframe.size.height-44-20, self.view.frame.size.width, 44)];
    pannellight.image=[UIImage imageNamed:@"glassbar_light.png"];
    [self.view addSubview:pannellight];
    [self GlassBarlightAnimation];
}

- (void) GlassBarlightAnimation{

    CABasicAnimation *opacityAnimation_out = [CABasicAnimation animationWithKeyPath:
                                          @"opacity"];
    opacityAnimation_out.duration= 1;
    opacityAnimation_out.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    opacityAnimation_out.fromValue =[NSNumber numberWithInt:1];
    opacityAnimation_out.toValue =[NSNumber numberWithInt:0];
    opacityAnimation_out.removedOnCompletion = NO;
    opacityAnimation_out.fillMode = kCAFillModeForwards;

    CABasicAnimation *opacityAnimation_in = [CABasicAnimation animationWithKeyPath:
                                          @"opacity"];
    opacityAnimation_in.duration= 1;
    opacityAnimation_in.beginTime=1;
    opacityAnimation_in.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    opacityAnimation_in.fromValue =[NSNumber numberWithInt:0];
    opacityAnimation_in.toValue =[NSNumber numberWithInt:1];
    opacityAnimation_in.removedOnCompletion = NO;
    opacityAnimation_in.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations=[NSArray arrayWithObjects:opacityAnimation_out,opacityAnimation_in, nil];
    group.duration=2;
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.repeatCount=FLT_MAX;
                      
    [[pannellight layer] addAnimation:group forKey:@"opacityAnimation"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
    [self initData];
    [self refreshUI];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    gestureRecognizer.delegate=self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [gestureRecognizer release];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO; 
    }
    return YES;
}

- (void) initData{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    if(cross==nil){
        cross=[Cross object];
    }
    if(users!=nil && [users count] >0)
    {
        default_user=[[users objectAtIndex:0] retain];
    }
    [users release];
    

    exfeeInvitations = [[NSMutableArray alloc] initWithCapacity:12];
    cross=[Cross object];
//    cross.cross_description=@"Take some note";

    NSArray *cross_default_backgrounds=[[NSUserDefaults standardUserDefaults] objectForKey:@"cross_default_backgrounds"];
    NSString *default_background=@"";
    
    if(cross_default_backgrounds!=nil && [cross_default_backgrounds count]>0){
        int idx=arc4random()%[cross_default_backgrounds count];
        default_background=[cross_default_backgrounds objectAtIndex:idx];
    }

    NSDictionary *widget=[NSDictionary dictionaryWithObjectsAndKeys:default_background,@"image",@"Background",@"type", nil];
    if(cross.widget==nil)
        cross.widget=[[NSMutableArray alloc] initWithCapacity:1];
    [cross.widget addObject:widget];
    
    [self addDefaultIdentity];
    User *user=default_user;
    Identity *default_identity=[[user.identities allObjects] objectAtIndex:0];

    cross.title=[NSString stringWithFormat:@".X. with %@",default_identity.name];

    title_be_edit=NO;
//    cross.exfee.invitations
}

- (void) addDefaultIdentity{
    User *user=default_user;
    Identity *default_identity=[[user.identities allObjects] objectAtIndex:0];
    if(user!=nil){
        Invitation *invitation=[Invitation object];
        invitation.rsvp_status=@"ACCEPTED";
        invitation.host=[NSNumber numberWithBool:YES];
        invitation.mates=0;
        invitation.identity=default_identity;
        invitation.updated_by=default_identity;
        invitation.updated_at=[NSDate date];
        invitation.created_at=[NSDate date];
        [exfeeInvitations addObject:invitation];
        [exfeeShowview reloadData];
    }
}

- (void)dealloc {
    
    [descView release];
    [exfeeShowview release];
    [timeRelView release];
    [timeAbsView release];
    [timeZoneView release];
    [placeTitleView release];
    [placeDescView release];
    [mapView release];
    [container release];
    [dectorView release];
    [headview release];
    [pannellight release];
//    [btnBack release];
    [titleView release];
    
    [super dealloc];
}

- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:self.view];

//    if (descView.hidden == NO && CGRectContainsPoint(descView.frame, location)) {
//        [self showDescriptionFullContent: (descView.numberOfLines != 0)];
//        return;
//    }
    
    if (CGRectContainsPoint([titleView frame], location) || CGRectContainsPoint([descView frame], location)||
        CGRectContainsPoint([descView frame], location) || CGRectContainsPoint([descView frame], location)){
        TitleDescEditViewController *titleViewController=[[TitleDescEditViewController alloc] initWithNibName:@"TitleDescEditViewController" bundle:nil];
        titleViewController.gatherview=self;
        NSString *imgurl;
        for(NSDictionary *widget in (NSArray*)cross.widget) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
            }
        }
        [titleViewController setBackground:imgurl];
//        timeViewController.gatherview=self;
//        [titleViewController setDateTime:cross.time];
        [self presentModalViewController:titleViewController animated:YES];
        [titleViewController setCrossTitle:cross.title desc:cross.cross_description];

        [titleViewController release];
    }

    if (CGRectContainsPoint([timeRelView frame], location) || CGRectContainsPoint([timeAbsView frame], location)|| CGRectContainsPoint([timeZoneView frame], location))
    {
        TimeViewController *timeViewController=[[TimeViewController alloc] initWithNibName:@"TimeViewController" bundle:nil];
        timeViewController.gatherview=self;
        [timeViewController setDateTime:cross.time];
        [self presentModalViewController:timeViewController animated:YES];
        [timeViewController release];
    }
    if (CGRectContainsPoint([placeTitleView frame], location) || CGRectContainsPoint([placeDescView frame], location))
    {
        [self ShowPlaceView:@"search"];
    }
    
    //    if(exfeeShowview.editmode==YES){
    //        if (!CGRectContainsPoint([exfeeShowview frame], location)){
    //            [self setExfeeViewMode:NO];
    //        }
    //    }
    //    if(viewmode==YES){
    //        if(crosstitle.hidden==NO)
    //        {
    //            if (!CGRectContainsPoint([crosstitle frame], location)){
    //                cross.title = crosstitle.text;
    //                crosstitle_view.text=crosstitle.text;
    //                [crosstitle setHidden:YES];
    //                [crosstitle_view setHidden:NO];
    //                [title_input_img setHidden:YES];
    //                [self saveCrossUpdate];
    //            }
    //
    //        }
    //        if(crossdescription.editable==YES){
    //            if (!CGRectContainsPoint([crossdescription frame], location)){
    //                [self saveCrossDesc];
    //            }
    //        }
    //    }
    if (CGRectContainsPoint([exfeeShowview frame], location)) {
        //        [crosstitle resignFirstResponder];
        [exfeeShowview becomeFirstResponder];
        CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
        [exfeeShowview onImageTouch:exfeeviewlocation];
    }else{
        [self hideMenu];
        [self hideStatusView];
    }
    
    //    else{
    //        [crosstitle resignFirstResponder];
    //        [map becomeFirstResponder];
    //    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Close:(UIButton*)sender{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    if(cross)
        [[Cross currentContext] deleteObject:cross];
    [self dismissModalViewControllerAnimated:YES];

}

- (void) addExfee:(NSArray*) invitations{
    if(exfeeInvitations==nil)
        exfeeInvitations = [[NSMutableArray alloc] initWithArray:invitations];
    else{
        for(Invitation *invitation in invitations){
            [exfeeInvitations addObject:invitation];
        }
    }
    NSString *newtitle=@".X. with ";
    if(title_be_edit==NO){
        for(Invitation *invitation in exfeeInvitations){
            newtitle=[newtitle stringByAppendingFormat:@"%@ ",invitation.identity.name];
        }
        cross.title=newtitle;
        titleView.text=newtitle;
    }
    
    [exfeeShowview reloadData];
}

- (void) setTitle:(NSString*)title Description:(NSString*)desc{
    if(cross.title!=title)
        title_be_edit=YES;
    cross.title=title;
    cross.cross_description=desc;
    [self fillTitleAndDescription:cross];
    [self relayoutUI];
}

- (IBAction) Gather:(id) sender{
//    [self pullcontainviewDown];
    
//    if([crossdescription.text isEqualToString:@"Write some notes here."]){
//        crossdescription.text=@"";
//    }
    
    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *orderedIdentities=[default_user.identities sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
  
    cross.by_identity=[orderedIdentities objectAtIndex:0];
//    cross.title=crosstitle.text;
//    cross.cross_description=crossdescription.text;
    if(cross.time==nil){
        cross.time=[CrossTime object];
        cross.time.begin_at=[EFTime object];
//
        NSDate *date=[NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"Z"];
//
        NSString *timezonestr=[formatter stringFromDate:date];
        NSMutableString *str=[timezonestr mutableCopy];
        [str insertString:@":" atIndex:3];
        cross.time.begin_at.timezone=str;
        [str release];
//
//        [formatter release];
//        //        NSString *eftimezone=[timezonestr substringFromIndex:3];
//        //        if([eftimezone isEqualToString:@""])
//        //            eftimezone=@"+00:00";
//        
//        
//        //        datetime.begin_at.timezone=@"";
    }
//    cross.time=datetime;
    Exfee *exfee=[Exfee object];
    
    for(Invitation *invitation in exfeeInvitations){
        [exfee addInvitationsObject:invitation];
    }
    cross.exfee = exfee;
    [Flurry logEvent:@"GATHER_SEND"];
    [APICrosses GatherCross:[cross retain] delegate:self];
}

- (void) ShowPlaceView:(NSString*)status{
    PlaceViewController *placeViewController=[[PlaceViewController alloc]initWithNibName:@"PlaceViewController" bundle:nil];
    placeViewController.gatherview=self;
    if(cross.place!=nil){
            if(![cross.place.title isEqualToString:@""] || ( ![cross.place.lat isEqualToString:@""] || ![cross.place.lng isEqualToString:@""])){
                [placeViewController setPlace:cross.place isedit:YES];
            }
            else{
                placeViewController.isaddnew=YES;
                placeViewController.showtableview=YES;
                status=@"search";
                
            }
    }else{
        placeViewController.isaddnew=YES;
    }
    if([status isEqualToString:@"detail"]){
        placeViewController.showdetailview=YES;
    }else if([status isEqualToString:@"search"]){
        placeViewController.showtableview=YES;
    }
    [self presentModalViewController:placeViewController animated:YES];
    [placeViewController release];
}

#pragma mark Refresh UI content methods
- (void)refreshUI{
    [self fillCross:self.cross];
}

- (void)fillCross:(Cross*) x{
    if (x != nil){
        [self fillTitleAndDescription:x];
        [self fillBackground:x.widget];
        [self fillTime:x.time];
        [self fillPlace:x.place];
    }
    [self relayoutUI];
}

- (void) fillTitleAndDescription:(Cross*)x{
    [titleView setText:x.title];
    [self setLayoutDirty];
    
    if (x.cross_description == nil || x.cross_description.length == 0){
//        descView.hidden = YES;
//        descView.text = @"";
        [self setLayoutDirty];
    }else{
        if ([x.cross_description length]>0)
            descView.text = x.cross_description;
        descView.hidden = NO;
        [self setLayoutDirty];
    }
}

- (void) fillBackground:(NSArray*)widgets{
    BOOL flag = NO;
    for(NSDictionary *widget in widgets) {
        if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            NSString *imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
            UIImage *backimg = [[ImgCache sharedManager] getImgFromCache:imgurl];
            if(backimg == nil || [backimg isEqual:[NSNull null]]){
                dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                dispatch_async(imgQueue, ^{
                    UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(backimg!=nil && ![backimg isEqual:[NSNull null]]){

                            dectorView.image = backimg;
                            [self setLayoutDirty];
                        }
                    });
                });
                dispatch_release(imgQueue);
            }else{
                dectorView.image = backimg;
                [self setLayoutDirty];
            }
            flag = YES;
            if (dectorView.hidden == YES){
                dectorView.hidden = NO;
            }
            break;
        }
    }
    if (flag == NO){
        dectorView.hidden = YES;
    }
}

- (void)fillExfee{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *exfee = [[NSMutableArray alloc]  initWithCapacity:12];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"invitation_id" ascending:YES];
    NSArray *invitations=[cross.exfee.invitations sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    int myself = 0;
    int accepts = 0;
    
    for(Invitation *invitation in invitations) {
        if ([invitation.identity.connected_user_id intValue]== app.userid) {
            [exfee insertObject:invitation atIndex:myself];
            myself ++;
        }else if([@"ACCEPTED" isEqualToString:invitation.rsvp_status] == YES){
            [exfee insertObject:invitation atIndex:(myself + accepts)];
            accepts ++;
        }else if ([@"REMOVED" isEqualToString:invitation.rsvp_status] == NO){
            [exfee addObject:invitation];
        }
    }
    
    if(exfeeInvitations != nil){
        [exfeeInvitations release];
        exfeeInvitations = nil;
    }
    exfeeInvitations = [[NSMutableArray alloc] initWithArray:exfee];
    [exfee release];
    [exfeeShowview reloadData];
}

- (void) setTime:(CrossTime*)time{
    cross.time=time;
    [self fillTime:time];
    [self relayoutUI];
}

- (void) setPlace:(Place*)place{
    cross.place=place;
    [self fillPlace:place];
    [self relayoutUI];
}

- (void)fillTime:(CrossTime*)time{
    if (time != nil){
        timeRelView.text = [Util getTimeTitle:time localTime:NO];
        NSString* desc = [Util getTimeDesc:time];
        if(desc != nil && desc.length > 0){
            timeAbsView.text = desc;
            timeAbsView.hidden = NO;
            [timeAbsView sizeToFit];
            timeZoneView.hidden = NO;
            timeZoneView.text = time.begin_at.timezone;
            [timeZoneView sizeToFit];
        }else{
            timeAbsView.text = @"";
            timeAbsView.hidden = YES;
            timeZoneView.hidden = YES;
            timeZoneView.text = @"";
        }
        
    }else{
        timeRelView.text = @"Sometime";
        timeAbsView.text = @"Pick a time";
//        timeAbsView.hidden = YES;
        timeZoneView.text = @"";
        timeZoneView.hidden = YES;
    }
    [self setLayoutDirty];
}

- (void)fillPlace:(Place*)place{
    if(place == nil || [place isEmpty]){
        placeTitleView.text = @"Shomewhere";
        placeDescView.text = @"Choose a place";
//        placeDescView.hidden = YES;
        mapView.hidden = YES;
        [self setLayoutDirty];
    }else {
        
        if ([place hasTitle]){
            placeTitleView.text = place.title;
        }else{
            placeTitleView.text = @"Shomewhere";
        }
        
        if ([place hasDescription]){
            placeDescView.text = place.place_description;
            placeDescView.hidden = NO;
            [placeDescView sizeToFit];
        }else{
            placeDescView.text = @"";
            placeDescView.hidden = YES;
        }
        
        if ([place hasGeo]){
            mapView.hidden = NO;
            float delta = 0.005;
            CLLocationCoordinate2D location;
            [mapView removeAnnotations: mapView.annotations];
            location.latitude = [place.lat doubleValue];
            location.longitude = [place.lng doubleValue];
            
            MKCoordinateRegion region;
            region.center = location;
            region.span.longitudeDelta = delta;
            region.span.latitudeDelta = delta;
            [mapView setRegion:region animated:NO];
            
            [mapView removeAnnotations:mapView.annotations];
            MapPin *pin = [[MapPin alloc] initWithCoordinates:region.center placeName:place.title description:@""];
            [mapView addAnnotation:pin];
            
        }else{
            mapView.hidden = YES;
        }
        [self setLayoutDirty];
    }
}

- (void)showDescriptionFullContent:(BOOL)needfull{
    if (needfull){
        if (descView.numberOfLines != 0){
            descView.numberOfLines = 0;
            [self setLayoutDirty];
        }
    }else{
        if (descView.numberOfLines == 0){
            descView.numberOfLines = 4;
            [self setLayoutDirty];
        }
    }
    [self relayoutUI];
}

#pragma mark Relayout methods
- (void)relayoutUI{
    if (layoutDirty == YES){
        //CGRect f = self.view.frame;
        CGRect c = container.frame;
        
        float left = CONTAINER_VERTICAL_PADDING;
        float width = c.size.width - CONTAINER_VERTICAL_PADDING * 2;
        
        float baseX = CONTAINER_VERTICAL_PADDING;
        float baseY = CONTAINER_TOP_PADDING;
        
        // Description
        if (descView.hidden == NO) {
            //            CGSize rect = CGSizeMake(width, INFINITY);
            //            NSString* four_lines = @"M\nM\nM\nM";
            //            CGSize fit4 = [four_lines sizeWithFont:descView.font constrainedToSize:rect lineBreakMode:descView.lineBreakMode];
            //            CGSize fitFull = [descView.text sizeWithFont:descView.font constrainedToSize:rect lineBreakMode:descView.lineBreakMode];
            //            CGFloat bestHeight = fitFull.height;
            //            if (descView.numberOfLines == 4){
            //                bestHeight = MIN(fit4.height, fitFull.height);
            //            }
            //            descView.frame = CGRectMake(left , baseY, width, bestHeight);
            descView.frame = CGRectMake(left , baseY, width, 80);
            [descView sizeToFit];
            baseX = CGRectGetMaxX(descView.frame);
            baseY = CGRectGetMaxY(descView.frame) ;
        }
        
        // Exfee
        if (exfeeShowview.hidden == NO){
            baseY += DESC_BOTTOM_MARGIN;
            exfeeShowview.frame = CGRectMake(CGRectGetMinX(c), baseY - EXFEE_OVERLAP, CGRectGetWidth(c), exfeeSuggestHeight + EXFEE_OVERLAP);
            baseX = CGRectGetMaxX(exfeeShowview.frame);
            baseY = CGRectGetMaxY(exfeeShowview.frame);
        }
        
        // Time
        if (timeRelView.hidden == NO){
            baseY += EXFEE_BOTTOM_MARGIN;
            CGSize timeRelSize = [timeRelView.text sizeWithFont:timeRelView.font];
            timeRelView.frame = CGRectMake(left, baseY, timeRelSize.width, timeRelSize.height);
            if (timeRelView.hidden == NO) {
                baseX = CGRectGetMinX(timeRelView.frame);
                baseY = CGRectGetMaxY(timeRelView.frame);
                
            }
            
            if (timeAbsView.hidden == NO){
                baseY += TIME_RELATIVE_BOTTOM_MARGIN;
            }
            CGSize timeAbsSize = [timeAbsView.text sizeWithFont:timeAbsView.font];
            timeAbsView.frame = CGRectMake(left, baseY, timeAbsSize.width, timeAbsSize.height);
            
            if (timeZoneView.hidden == NO){
                CGSize timeZoneSize = CGSizeZero;
                timeZoneSize = [timeZoneView.text sizeWithFont:timeZoneView.font];
                if (baseX + timeZoneSize.width <= width){
                    baseX = CGRectGetMaxX(timeAbsView.frame) + TIME_ABSOLUTE_RIGHT_MARGIN;
                    baseY = CGRectGetMinY(timeAbsView.frame);
                    timeZoneView.frame = CGRectMake(baseX, baseY, timeZoneSize.width, timeZoneSize.height);
                    baseX = CGRectGetMinX(timeAbsView.frame);
                    baseY = CGRectGetMaxY(timeAbsView.frame);
                }else{
                    baseX = CGRectGetMinX(timeAbsView.frame);
                    baseY = CGRectGetMaxY(timeAbsView.frame) + SMALL_SLOT;
                    timeZoneView.frame = CGRectMake(baseX, baseY, timeZoneSize.width, timeZoneSize.height);
                    baseX = CGRectGetMinX(timeZoneView.frame);
                    baseY = CGRectGetMaxY(timeZoneView.frame);
                }
            }else if (timeAbsView.hidden == NO){
                baseX = CGRectGetMaxX(timeAbsView.frame);
                baseY = CGRectGetMaxY(timeAbsView.frame);
            }
        }
        
        //Place
        if (placeTitleView.hidden == NO){
            baseY += TIME_BOTTOM_MARGIN;
            CGSize placeTitleSize = [placeTitleView.text sizeWithFont:placeTitleView.font forWidth:placeTitleView.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
            placeTitleView.frame = CGRectMake(CONTAINER_VERTICAL_PADDING, baseY, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , placeTitleSize.height);
            baseX = CGRectGetMinX(placeTitleView.frame);
            baseY = CGRectGetMaxY(placeTitleView.frame);
        }
        
        if (placeTitleView.hidden == NO && placeDescView.hidden == NO) {
            baseY += PLACE_TITLE_BOTTOM_MARGIN;
        }
        
        if (placeDescView.hidden == NO){
            CGSize constraintSize;
            constraintSize.width = width;
            constraintSize.height = MAXFLOAT;
            CGSize placeDescSize = [placeDescView.text sizeWithFont:placeDescView.font constrainedToSize:constraintSize lineBreakMode:placeDescView.lineBreakMode];
            CGFloat ph = placeDescSize.height;
            if (ph < PLACE_DESC_MIN_HEIGHT){
                ph = PLACE_DESC_MIN_HEIGHT;
            }else if (ph > PLACE_DESC_MAX_HEIGHT){
                ph = PLACE_DESC_MAX_HEIGHT;
            }
            placeDescView.frame = CGRectMake(baseX, baseY, width, ph);
        }else{
            placeDescView.frame = CGRectMake(baseX, baseY, 0, 0);
        }
        
        // Map
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) ;
        int b = (CGRectGetMaxY(placeDescView.frame) - CGRectGetMinY(placeTitleView.frame) + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + container.frame.origin.y  + OVERLAP /*+ SMALL_SLOT */);
        mapView.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b);
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = CGRectGetMinY(container.frame) + CGRectGetMaxY(placeDescView.frame) + OVERLAP;
        }else{
            s.height = CGRectGetMinY(container.frame) + CGRectGetMaxY(mapView.frame) + OVERLAP;
        }
        container.contentSize = s;
        
        [self clearLayoutDirty];
    }
}

- (void)setLayoutDirty{
    layoutDirty = YES;
}

- (void)clearLayoutDirty{
    layoutDirty = NO;
}

#pragma mark EXImagesCollectionView Datasource methods

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView{
    return [exfeeInvitations count];
}
- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView itemAtIndex:(int)index{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Invitation *invitation =[exfeeInvitations objectAtIndex:index];
    
    EXInvitationItem *item=[[EXInvitationItem alloc] initWithInvitation:invitation];
    item.backgroundColor=[UIColor clearColor];
    item.isGather=YES;
    
    if(app.userid ==[invitation.identity.connected_user_id intValue]){
        item.isMe = YES;
    }
    
    Identity *identity = invitation.identity;
    UIImage *img = nil;
    if(identity.avatar_filename != nil)
        img = [[ImgCache sharedManager] checkImgFrom:identity.avatar_filename];
    if(img != nil && ![img isEqual:[NSNull null]]){
        item.avatar = img;
    }
    else{
        item.avatar = [UIImage imageNamed:@"portrait_default.png"];
        if(identity.avatar_filename != nil) {
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                __block UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                        item.avatar = avatar;
                        [item setNeedsDisplay];
                    }
                });
            });
            dispatch_release(imgQueue);
        }
    }
    //    item.isHost = [invitation.host boolValue];
    //    item.mates = [invitation.mates intValue];
    //    item.rsvp_status = invitation.rsvp_status;
    //    NSString *name=identity.name;
    //    if(name==nil)
    //        name=identity.external_username;
    //    if(name==nil)
    //        name=identity.external_id;
    //    item.name=name;
    //[arr release];
    return item;
}

- (void)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView shouldResizeHeightTo:(float)height{
    
    //    if(viewmode==YES && exfeeShowview.editmode==NO)
    //    {
    //        if(height==120 && [exfeeIdentities count]==6)
    //            return;
    //    }
    //    [exfeeShowview setFrame:CGRectMake(exfeeShowview.frame.origin.x, exfeeShowview.frame.origin.y, exfeeShowview.frame.size.width, height)];
    //    [exfeeShowview calculateColumn];
    //    if(viewmode==NO || exfeeShowview.editmode==YES){
    //    [self reArrangeViews];
    //    }
    
    //    [exfeeIdentities count]
    NSLog(@"Exfee Collection should resize to %f", height);
    if (height > 0){
        exfeeSuggestHeight = height;
    }
    [self setLayoutDirty];
    [self relayoutUI];
    
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect {
    NSArray* reducedExfeeIdentities=exfeeInvitations;//[self getReducedExfeeIdentities];
    if(index == [reducedExfeeIdentities count])
    {
        ExfeeInputViewController *exfeeinputViewController=[[ExfeeInputViewController alloc] initWithNibName:@"ExfeeInputViewController" bundle:nil];
        exfeeinputViewController.gatherview=self;
        [self presentModalViewController:exfeeinputViewController animated:YES];

    }
    else if(index < [reducedExfeeIdentities count]){
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *arr=exfeeInvitations;//[self getReducedExfeeIdentities];
        Invitation *invitation =[arr objectAtIndex:index];
        
        
        int x=exfeeShowview.frame.origin.x+(col+1)*(50+5*2)+5;
        int y=exfeeShowview.frame.origin.y+row*(50+5*2)+y_start_offset;
        
        if(x + 180 > self.view.frame.size.width){
            x = x - 180;
        }
        if(rsvpstatusview==nil){
            rsvpstatusview=[[EXRSVPStatusView alloc] initWithFrame:CGRectMake(x, y-44, 180, 44) withDelegate:self];
            [self.view addSubview:rsvpstatusview];
        }
        rsvpstatusview.invitation=invitation;
        
        
        float avatar_center=rect.origin.x+rect.size.width/2;
        int rsvpstatus_x=avatar_center-rsvpstatusview.frame.size.width/2;
        if(rsvpstatus_x<0)
            rsvpstatus_x=0;
        if(rsvpstatus_x+rsvpstatusview.frame.size.width>self.view.frame.size.width)
            rsvpstatus_x=self.view.frame.size.width-rsvpstatusview.frame.size.width;
        
        if(app.userid ==[invitation.identity.connected_user_id intValue]){
            [self showMenu:invitation];
            [self hideStatusView];
            [rsvpstatusview setHidden:YES];
        }else{
            [rsvpstatusview setHidden:NO];
            //            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:
            //                                                 @"transform.scale"];
            //            scaleAnimation.duration= 1;
            //            scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            //            scaleAnimation.fromValue = [NSNumber numberWithFloat:0.5];
            //            scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
            //            [[rsvpstatusview layer] addAnimation:scaleAnimation forKey:@"scaleAnimation"];
            
            
            NSLog(@"from %f to %i position %f",rsvpstatusview.frame.origin.x,rsvpstatus_x,[rsvpstatusview layer].position.x);
            
            [rsvpstatusview setFrame:CGRectMake(rsvpstatus_x, y-rsvpstatusview.frame.size.height, rsvpstatusview.frame.size.width, rsvpstatusview.frame.size.height)];
            
            //            [[rsvpstatusview layer] setValue:[NSNumber numberWithInt:y-rsvpstatusview.frame.size.height+30-rsvpstatusview.frame.origin.y] forKeyPath:@"transform.translation.y"];
            //
            rsvpstatus_x-=rsvpstatusview.frame.origin.x;
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:
                                               @"transform.translation.y"];
            moveAnimation.duration= 0.233;
            moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            
            moveAnimation.fromValue =[NSNumber numberWithFloat:y-rsvpstatusview.frame.size.height+30-rsvpstatusview.frame.origin.y];
            moveAnimation.toValue =[NSNumber numberWithFloat:y-rsvpstatusview.frame.size.height-rsvpstatusview.frame.origin.y];
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.fillMode = kCAFillModeForwards;
            [[rsvpstatusview layer] addAnimation:moveAnimation forKey:@"moveAnimation"];
            
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:
                                                @"transform.scale"];
            scaleAnimation.duration= 0.2;
            scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            
            scaleAnimation.fromValue =[NSNumber numberWithInt:0.1];
            scaleAnimation.toValue =[NSNumber numberWithInt:1];
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            [[rsvpstatusview layer] addAnimation:scaleAnimation forKey:@"scaleAnimation"];
            
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:
                                                  @"opacity"];
            opacityAnimation.duration= 0.3;
            opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            opacityAnimation.fromValue =[NSNumber numberWithInt:0];
            opacityAnimation.toValue =[NSNumber numberWithInt:1];
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [[rsvpstatusview layer] addAnimation:opacityAnimation forKey:@"opacityAnimation"];
            
            
            [rsvpstatusview setNeedsDisplay];
            [self hideMenu];
        }
    }
    //        [crosstitle resignFirstResponder];
    //        [crosstitle endEditing:YES];
    //        BOOL select_status=[[exfeeSelected objectAtIndex:index] boolValue];
    //        for( int i=0;i<[exfeeSelected count];i++){
    //            [exfeeSelected replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    //        }
    //        [exfeeSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!select_status]];
    //        [exfeeShowview reloadData];
    //        BOOL isSelect=NO;
    //        for(NSNumber *number in exfeeSelected){
    //            if([number boolValue]==YES)
    //                isSelect=YES;
    //        }
    //        if(isSelect){
    //            CGRect f=imageCollectionView.frame;
    //            float x=f.origin.x+rect.origin.x+rect.size.width/2;
    //            float y=f.origin.y+rect.origin.y;
    //            Invitation *invitation=[reducedExfeeIdentities objectAtIndex:index];
    //            [self ShowExfeePopOver:invitation pointTo:CGPointMake(x,y) arrowx:rect.origin.x+rect.size.width/2+f.origin.x];
    //            if(viewmode==YES && exfeeShowview.editmode==NO){
    //                [self ShowRsvpToolBar];
    //            }
    //            else
    //                [self ShowGatherToolBar];
    //        }
    //        else {
    //            if(viewmode==YES&& exfeeShowview.editmode==NO)
    //                [self ShowRsvpButton];
    //            else //if(exfeeShowview.editmode==YES)
    //                [gathertoolbar setHidden:YES];
    //
    //        }
    //    }
}

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)map didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id < MKAnnotation >)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != nil)
    {
        static NSString *defaultPinID = @"com.exfe.pin";
        pinView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ){
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"map_pin_blue.png"];
            
            UIButton *btnNav = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [btnNav addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
            pinView.leftCalloutAccessoryView = btnNav;
        }else{
            pinView.annotation = annotation;
        }
    }
    return pinView;
}

- (void)mapView:(MKMapView *)map didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"Click on the annotation");
}

- (void)onClick:(id)sender{
    NSLog(@"Click to Navigation");
}

- (void) showMenu:(Invitation*)_invitation{
    if(rsvpmenu==nil){
        rsvpmenu=[[EXRSVPMenuView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, exfeeShowview.frame.origin.y-20, 125, 152) withDelegate:self ];
        [self.view addSubview:rsvpmenu];
    }
    rsvpmenu.invitation=_invitation;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width-125, exfeeShowview.frame.origin.y-20, 125, 152)];
    if(rsvpstatusview!=nil)
        [rsvpstatusview setHidden:YES];
    
    [UIView commitAnimations];
    
}

- (void)hideMenu{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width, rsvpmenu.frame.origin.y, 125, 152)];
    [UIView commitAnimations];
}

- (void)hideStatusView{
    [rsvpstatusview setHidden:YES];
}

- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"ACCEPTED" invitation:menu.invitation];
    [self hideMenu];
}

- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"DECLINED" invitation:menu.invitation];
    [self hideMenu];
}

- (void)RSVPPendinMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"INTERESTED" invitation:menu.invitation];
    [self hideMenu];
}

- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation{
    //    NSError *error;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Identity *myidentity=[self getMyInvitation].identity;
    NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:_invitation.identity.identity_id,@"identity_id",myidentity.identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
    
    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:[NSString stringWithFormat:@"[%@]",[rsvpdict JSONString]] forParam:@"rsvp"];
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
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
                            [APICrosses LoadCrossWithCrossId:[cross.cross_id intValue] updatedtime:@"" delegate:self source:[NSDictionary dictionaryWithObjectsAndKeys:@"cross_reload",@"name",cross.cross_id,@"cross_id", nil]];
                            
                        }
                }
                //We got an error!
            }else {
                //Check Response Body to get Data!
            }
        };
        request.onDidFailLoadWithError=^(NSError *error){
            NSString *errormsg=[error.userInfo objectForKey:@"NSLocalizedDescription"];
            if(error.code==2)
                errormsg=@"A connection failure has occurred.";
            else
                errormsg=@"Could not connect to the server.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        };
    }];
    
}

- (Invitation*) getMyInvitation{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    for(Invitation *invitation in exfeeInvitations)
    {
        if([invitation.identity.connected_user_id intValue] == app.userid)
            return invitation;
    }
    return nil;
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    
    if([objects count]>0)
    {
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app GatherCrossDidFinish];
    }else{
        NSLog(@"gather error");
    }

//    NSLog(@"%@",objects);
//    if([objects count]>0){
//        
//        [self fillExfee];
//    }
    
}
- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
}

@end
