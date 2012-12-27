//
//  CrossDetailViewController.m
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import "CrossDetailViewController.h"
#import "Util.h"
#import "EFTime.h"
#import "ImgCache.h"


#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (16)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (88)
#define DECTOR_HEIGHT_EXTRA              (LARGE_SLOT)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define OVERLAP                          (0)
#define CONTAINER_TOP_MARGIN             (DECTOR_HEIGHT - OVERLAP)
#define CONTAINER_TOP_PADDING            (DECTOR_HEIGHT_EXTRA + DECTOR_MARGIN + OVERLAP)
#define CONTAINER_VERTICAL_PADDING       (8)
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


@interface CrossDetailViewController ()

@end

@implementation CrossDetailViewController
@synthesize cross;
@synthesize default_user;



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
        descView = [[UITextView alloc] initWithFrame:CGRectMake(left, CONTAINER_TOP_PADDING, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, 40)];
        descView.editable = NO;
        descView.textColor = [UIColor COLOR_RGB(0x33, 0x33, 0x33)];
        descView.delegate = self;
        descView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        descView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:descView];
        
        exfeeSuggestHeight = 70;
        exfeeShowview = [[EXImagesCollectionView alloc]initWithFrame:CGRectMake(c.origin.x, CGRectGetMaxY(descView.frame) + DESC_BOTTOM_MARGIN - EXFEE_OVERLAP, c.size.width, exfeeSuggestHeight + EXFEE_OVERLAP)];
        exfeeShowview.backgroundColor = [UIColor grayColor];
        [exfeeShowview calculateColumn];
        [exfeeShowview setDataSource:self];
        [exfeeShowview setDelegate:self];
        [container addSubview:exfeeShowview];
        
        timeRelView = [[UILabel alloc] initWithFrame:CGRectMake(left, exfeeShowview.frame.origin.y + exfeeShowview.frame.size.height + EXFEE_BOTTOM_MARGIN, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, TIME_RELATIVE_HEIGHT)];
        timeRelView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        timeRelView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        timeRelView.shadowColor = [UIColor whiteColor];
        timeRelView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeRelView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:timeRelView];
        
        timeAbsView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeRelView.frame.origin.y + timeRelView.frame.size.height + TIME_RELATIVE_BOTTOM_MARGIN, c.size.width /2 -  CONTAINER_VERTICAL_PADDING, TIME_ABSOLUTE_HEIGHT)];
        timeAbsView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        timeAbsView.shadowColor = [UIColor whiteColor];
        timeAbsView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeAbsView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:timeAbsView];
        
        timeZoneView= [[UILabel alloc] initWithFrame:CGRectMake(left + timeAbsView.frame.size.width + TIME_ABSOLUTE_RIGHT_MARGIN, timeAbsView.frame.origin.y, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 - timeAbsView.frame.size.width  - TIME_ABSOLUTE_RIGHT_MARGIN , TIME_ZONE_HEIGHT)];
        timeZoneView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        timeZoneView.backgroundColor = [UIColor greenColor];
        [container addSubview:timeZoneView];
        
        placeTitleView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeAbsView.frame.origin.y + timeAbsView.frame.size.height + TIME_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_TITLE_HEIGHT)];
        placeTitleView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        placeTitleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        placeTitleView.shadowColor = [UIColor whiteColor];
        placeTitleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeTitleView.preferredMaxLayoutWidth = c.size.width  -  CONTAINER_VERTICAL_PADDING * 2;
        placeTitleView.numberOfLines = 2;
        placeTitleView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:placeTitleView];
        
        placeDescView= [[UILabel alloc] initWithFrame:CGRectMake(left, placeTitleView.frame.origin.y + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_DESC_HEIGHT)];
        placeDescView.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        placeDescView.shadowColor = [UIColor whiteColor];
        placeDescView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeDescView.preferredMaxLayoutWidth = c.size.width  -  CONTAINER_VERTICAL_PADDING * 2;
        placeDescView.numberOfLines = 4;
        placeDescView.lineBreakMode = NSLineBreakByWordWrapping;
        placeDescView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:placeDescView];
        
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) ;
        int b = (placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + c.origin.y + OVERLAP /*+ DECTOR_HEIGHT_EXTRA*/);
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, placeDescView.frame.origin.y + placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b)];
        mapView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:mapView];
        UIImage *pin = [UIImage imageNamed:@"map_pin_blue.png"];
        CGRect pinRect = CGRectMake(mapView.center.x, mapView.center.y, pin.size.width, pin.size.height);
        mapPin = [[UIImageView alloc] initWithFrame: CGRectOffset(pinRect, pin.size.width / -2, pin.size.height * -1)];
        mapPin.image = pin;
        [container addSubview:mapPin];
        
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
    
    dectorView = [[EXCurveImageView alloc] initWithFrame:CGRectMake(f.origin.x, f.origin.y, f.size.width, DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA) withCurveFrame:CGRectMake(f.origin.x + f.size.width * 0.6,  f.origin.y +  DECTOR_HEIGHT, 40, DECTOR_HEIGHT_EXTRA) ];
    dectorView.backgroundColor = [UIColor COLOR_WA(0x00, 0)];
    [self.view addSubview:dectorView];
    
    btnBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 24, DECTOR_HEIGHT - 20 * 2)];
    btnBack.backgroundColor = [UIColor lightGrayColor];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
   
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnBack.frame) + TITLE_HORIZON_MARGIN, TITLE_VERTICAL_MARGIN, f.size.width - 24 - TITLE_HORIZON_MARGIN * 2, DECTOR_HEIGHT - TITLE_VERTICAL_MARGIN * 2)];
    titleView.textColor = [UIColor COLOR_RGB(0xFE, 0xFF,0xFF)];
    titleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.lineBreakMode = UILineBreakModeWordWrap;
    titleView.numberOfLines = 2;
    titleView.shadowColor = [UIColor blackColor];
    titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.view addSubview:titleView];
    self.view.backgroundColor = [UIColor grayColor];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
    [self refreshUI];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [container addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];

    
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
    [mapPin release];
    [container release];
    [dectorView release];
    [btnBack release];
    [titleView release];
    
    [super dealloc];
}

- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
//    if (CGRectContainsPoint([placetitle frame], location) || CGRectContainsPoint([placedesc frame], location))
//    {
//        [crosstitle resignFirstResponder];
//        [map becomeFirstResponder];
//        if(viewmode==YES)
//            [self ShowPlaceView:@"detail"];
//        else{
//            [self ShowPlaceView:@"search"];
//        }
//    }
    
//    if (CGRectContainsPoint([timetitle frame], location) || CGRectContainsPoint([timedesc frame], location))
//    {
//        [self ShowTimeView];
//    }
    
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
    if (CGRectContainsPoint([exfeeShowview frame], location))
    {
//        [crosstitle resignFirstResponder];
        [exfeeShowview becomeFirstResponder];
        CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
        [exfeeShowview onImageTouch:exfeeviewlocation];
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




#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    CGRect frame = textView.frame;
    frame.size.height = [textView contentSize].height;
    textView.frame = frame;
    [self setLayoutDirty];
    [self relayoutUI];
}

- (void)gotoBack:(UIButton*)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark Refresh UI content methods
- (void)refreshUI{
    [self fillCross:self.cross];
}

- (void)fillCross:(Cross*) x{
    if (x != nil){
        [titleView setText:x.title];
        [self setLayoutDirty];
        
        if (x.cross_description == nil || x.cross_description.length == 0){
            [descView setText:@"(Tap to add description...)"];
            [self setLayoutDirty];
        }else{
            [descView setText:x.cross_description];
            [self setLayoutDirty];
        }
        
        [self fillBackground:x.widget];
        [self fillExfee];
        [self fillTime:x.time];
        [self fillPlace:x.place];   
    }
    [self relayoutUI];
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
                            //[self setLayoutDirty];
                        }
                    });
                });
                dispatch_release(imgQueue);
            }else{
                dectorView.image = backimg;
                //[self setLayoutDirty];
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
    exfeeInvitations = [[NSArray alloc] initWithArray:exfee];
    [exfee release];
    [exfeeShowview reloadData];
}

- (void)fillTime:(CrossTime*)time{
    if (time != nil){
        timeRelView.text = [Util getTimeTitle:time localTime:NO];
        NSString* desc = [Util getTimeDesc:time];
        if(desc != nil && desc.length > 0){
            timeAbsView.text = desc;
            timeAbsView.hidden = false;
            timeZoneView.hidden = false;
            timeZoneView.text = time.begin_at.timezone;
        }else{
            timeAbsView.text = @"";
            timeAbsView.hidden = YES;
            timeZoneView.hidden = YES;
            timeZoneView.text = @"";
        }
       
    }else{
        timeRelView.text = @"Sometime";
        timeAbsView.text = @"";
        timeAbsView.hidden = YES;
        timeZoneView.text = @"";
        timeZoneView.hidden = YES;
    }
    [self setLayoutDirty];
}

- (void)fillPlace:(Place*)place{
    if([Util placeIsEmpty:place]){
        placeTitleView.text = @"Shomewhere";
        placeDescView.text = @"";
        mapView.hidden = YES;
        mapPin.hidden = YES;
        [self setLayoutDirty];
    }else {
        
        if ([Util placeHasTitle:place]){
            placeTitleView.text = place.title;
        }else{
            placeTitleView.text = @"Shomewhere";
        }
        
        if ([Util placeHasDescription:place]){
            placeDescView.text = place.place_description;
        }else{
            placeDescView.text = @"";
        }
        
        if ([Util placeHasGeo:place]){
            mapView.hidden = NO;
            mapPin.hidden = NO;
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
        }else{
            mapView.hidden = YES;
            mapPin.hidden = YES;
            //mapView.image = [UIImage imageNamed:@"map_framepin.png"];
        }
        [self setLayoutDirty];
    }
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
        float descHeight = descView.contentSize.height;
        if (descHeight  < DESC_MIN_HEIGHT){
            descHeight = DESC_MIN_HEIGHT;
        }else if ( descHeight > DESC_MAX_HEIGHT){
            descHeight = DESC_MAX_HEIGHT;
        }
        descView.frame = CGRectMake(0, baseY, c.size.width, descHeight);
        
        if (descView.hidden == NO) {
            baseX = CGRectGetMinX(descView.frame);
            baseY = CGRectGetMaxY(descView.frame) + DESC_BOTTOM_MARGIN;
        }
        
        // Exfee
        exfeeShowview.frame = CGRectMake(CGRectGetMinX(c), baseY - EXFEE_OVERLAP, CGRectGetWidth(c), exfeeSuggestHeight + EXFEE_OVERLAP);
        
        baseX = CGRectGetMinX(exfeeShowview.frame);
        if (exfeeShowview.hidden == NO) {
            baseY = CGRectGetMaxY(exfeeShowview.frame) + EXFEE_BOTTOM_MARGIN;
        }
        
        // Time
        if (timeRelView.hidden == NO){
            CGSize timeRelSize = [timeRelView.text sizeWithFont:timeRelView.font];
            timeRelView.frame = CGRectMake(left, baseY, timeRelSize.width, timeRelSize.height);
            if (timeRelView.hidden == NO) {
                baseX = CGRectGetMinX(timeRelView.frame);
                baseY = CGRectGetMaxY(timeRelView.frame);
                
            }
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
            baseX = CGRectGetMinX(timeAbsView.frame);
            baseY = CGRectGetMaxY(timeAbsView.frame);
        }
        
        if (timeAbsView.hidden == NO || timeRelView.hidden == NO || timeZoneView.hidden == NO){
            baseY += TIME_BOTTOM_MARGIN;
        }
        
        //Place
        if (placeTitleView.hidden == NO){
            CGSize placeTitleSize = [placeTitleView.text sizeWithFont:placeTitleView.font forWidth:placeTitleView.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
            placeTitleView.frame = CGRectMake(baseX, baseY, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , placeTitleSize.height);
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
        }
        
        // Map
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) ;
        int b = (placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + c.origin.y + OVERLAP /*+ SMALL_SLOT */);
        mapView.frame = CGRectMake(0, placeDescView.frame.origin.y + placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b);
        
        UIImage *pin = mapPin.image;
        CGRect pinRect = CGRectMake(mapView.center.x, mapView.center.y, pin.size.width, pin.size.height);
        mapPin.frame = CGRectOffset(pinRect, pin.size.width / -2, pin.size.height * -1);
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = container.frame.origin.y + placeDescView.frame.origin.y + placeDescView.frame.size.height;
        }else{
            s.height = container.frame.origin.y + mapView.frame.origin.y + mapView.frame.size.height;
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

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [exfeeInvitations count];
}
- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView itemAtIndex:(int)index{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Invitation *invitation =[exfeeInvitations objectAtIndex:index];
    
    EXInvitationItem *item=[[EXInvitationItem alloc] initWithInvitation:invitation];
    
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

- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView shouldResizeHeightTo:(float)height{
    
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
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect {
    NSArray* reducedExfeeIdentities=exfeeInvitations;//[self getReducedExfeeIdentities];
    if(index==[reducedExfeeIdentities count])
    {
        //        if(viewmode==YES && exfeeShowview.editmode==NO)
        //            return;
        //        [self ShowGatherToolBar];
        //        [self ShowExfeeView];
    }
    else if(index <[reducedExfeeIdentities count]){
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *arr=exfeeInvitations;//[self getReducedExfeeIdentities];
        Invitation *invitation =[arr objectAtIndex:index];
        
        rsvpstatusview.invitation=invitation;

        int x=exfeeShowview.frame.origin.x+(col+1)*(50+5*2)+5;
        int y=exfeeShowview.frame.origin.y+row*(50+5*2)+y_start_offset;
        
        if(x+180 > self.view.frame.size.width){
            x= x-180;
        }
        if(rsvpstatusview==nil){
            if(app.userid ==[invitation.identity.connected_user_id intValue]){
                [self showMenu:invitation];
            }else{
                rsvpstatusview=[[EXRSVPStatusView alloc] initWithFrame:CGRectMake(x, y-44, 180, 44) withDelegate:self];
                [container addSubview:rsvpstatusview];
            }
        }else{
            [rsvpstatusview setFrame:CGRectMake(x, y-44, 180, 44)];
        }
        [rsvpstatusview setNeedsDisplay];
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

- (void) showMenu:(Invitation*)_invitation{
    if(rsvpmenu==nil){
        rsvpmenu=[[EXRSVPMenuView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 41, 125, 152) withDelegate:self ];
        [self.view addSubview:rsvpmenu];
    }
    rsvpmenu.invitation=_invitation;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width-125, 41, 125, 152)];
    [UIView commitAnimations];

    NSLog(@"menu");
}

- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu{
    NSLog(@"RSVPAcceptedMenuView:%@",menu.invitation);
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:[postarray JSONString] forParam:@"rsvp"];
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    
//    NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/rsvp?token=%@",[cross.exfee.exfee_id intValue],app.accesstoken];

    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width, 41, 125, 152)];
    [UIView commitAnimations];

}
- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu{
    NSLog(@"RSVPUnavailableMenuView");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width, 41, 125, 152)];
    [UIView commitAnimations];
    
}
- (void)RSVPPendinMenuView:(EXRSVPMenuView *) menu{
    NSLog(@"RSVPPendinMenuView");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width, 41, 125, 152)];
    [UIView commitAnimations];
    
}


@end
