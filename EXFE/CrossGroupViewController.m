//
//  CrossGroupViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import "CrossGroupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "ImgCache.h"
#import "EXLabel.h"
#import "EXRSVPStatusView.h"
#import "MapPin.h"
#import "Cross.h"
#import "Exfee.h"
#import "User.h"
#import "Place+Helper.h"
#import "CrossTime+Helper.h"
#import "EFTime+Helper.h"
#import "APICrosses.h"
#import "TitleDescEditViewController.h"
#import "TimeViewController.h"
#import "PlaceViewController.h"
#import "CrossesViewController.h"
#import "WidgetConvViewController.h"

#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (16)
#define SMALL_SLOT                       (5)
#define ADDITIONAL_SLOT                  (8)

#define DECTOR_HEIGHT                    (88)
#define DECTOR_HEIGHT_EXTRA              (15)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define OVERLAP                          (0)
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
#define TIME_RELATIVE_BOTTOM_MARGIN      (0)
#define TIME_ABSOLUTE_HEIGHT             (ALTERNATIVE_TEXT_HIEGHT)
#define TIME_ABSOLUTE_RIGHT_MARGIN       (SMALL_SLOT)
#define TIME_ZONE_HEIGHT                 (ALTERNATIVE_TEXT_HIEGHT)
#define TIME_BOTTOM_MARGIN               (LARGE_SLOT)
#define PLACE_TITLE_HEIGHT               (MAIN_TEXT_HIEGHT)
#define PLACE_TITLE_BOTTOM_MARGIN        (0)
#define PLACE_DESC_HEIGHT                (ALTERNATIVE_TEXT_HIEGHT * 4)
#define PLACE_DESC_MIN_HEIGHT            (20)
#define PLACE_DESC_MAX_HEIGHT            (90)
#define PLACE_DESC_BOTTOM_MARGIN         (LARGE_SLOT)
#define TITLE_HORIZON_MARGIN             (SMALL_SLOT)
#define TITLE_VERTICAL_MARGIN            (18)

#define kPopupTypeEditTitle              (0x0101)
#define kPopupTypeEditDescription        (0x0102)
#define kPopupTypeEditTime               (0x0103)
#define kPopupTypeEditPlace              (0x0104)
#define kPopupTypeEditStatus             (0x0205)
#define kPopupTypeVewStatus              (0x0306)
#define MASK_HIGH_BITS                   (0xFF00)
#define MASK_LOW_BITS                    (0x00FF)

#define kViewTagMaskRoot                 (0100000)
#define kViewTagMaskOne                  (0070000)
#define kViewTagMaskTwo                  (0007700)
#define kViewTagMaskThree                (0000077)
#define kViewTagMaskLayerTwo             (0077700)
#define kViewTagRootView                 (0100000)
#define kViewTagHeader                   (0110000)
#define kViewTagContainer                (0120000)
#define kViewTagTabBar                   (0130000)
#define kViewTagBack                     (0140000)
#define kViewTagTitle                    (0110101)
#define kViewTagDescription              (0120102)
#define kViewTagTimeTitle                (0120201)
#define kViewTagTimeDescription          (0120202)
#define kViewTagTimeAdditional           (0120203)
#define kViewTagPlaceTitle               (0120301)
#define kViewTagPlaceDescription         (0120302)
@interface CrossGroupViewController ()

- (void) changeHeaderStyle:(NSInteger)style;

@end

@implementation CrossGroupViewController
@synthesize cross = _cross;
@synthesize default_user = _default_user;
@synthesize currentViewController = _currentViewController;
@synthesize headerStyle = _headerStyle;
@synthesize widgetId = _widgetId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _headerStyle = kHeaderStyleFull;
        _widgetId = kWidgetCross;
        popupCtrolId = 0;
        savedFrame = CGRectNull;
        savedScrollEnable = NO;
    }
    return self;
}

#pragma mark ViewController life cycle & callbacks
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect b = self.view.bounds;
    CGRect a = [UIScreen mainScreen].applicationFrame;
    self.view.frame = a;
    
    CGFloat head_bg_img_scale = CGRectGetWidth(self.view.bounds) / HEADER_BACKGROUND_WIDTH;
    head_bg_img_startY = 0 - HEADER_BACKGROUND_Y_OFFSET * head_bg_img_scale;
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), 88 + 20)];
    {
        dectorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, head_bg_img_startY, HEADER_BACKGROUND_WIDTH * head_bg_img_scale, HEADER_BACKGFOUND_HEIGHT * head_bg_img_scale)];
        CALayer *sublayer = [CALayer layer];
        sublayer.backgroundColor = [UIColor blackColor].CGColor;
        sublayer.opacity = COLOR255(0x55);
        sublayer.frame = dectorView.bounds;
        [dectorView.layer addSublayer:sublayer];
        [headerView addSubview:dectorView];
    }
    [self.view addSubview:headerView];
    
    container = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 88, CGRectGetWidth(b), CGRectGetHeight(a) - 88)];
    container.backgroundColor = [UIColor COLOR_SNOW];
    container.alwaysBounceVertical = YES;
    container.delegate = self;
    container.tag = kViewTagContainer;
    CGRect c = container.bounds;
    {
        int left = CONTAINER_VERTICAL_PADDING;
        descView = [[EXLabel alloc] initWithFrame:CGRectMake(left, CONTAINER_TOP_PADDING, CGRectGetWidth(c) -  CONTAINER_VERTICAL_PADDING * 2, 80)];
        descView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
        descView.numberOfLines = 4;
        descView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        descView.shadowColor = [UIColor whiteColor];
        descView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        descView.backgroundColor = [UIColor clearColor];
        descView.lineBreakMode = NSLineBreakByWordWrapping;
        descView.tag = kViewTagDescription;
        [container addSubview:descView];
        
        exfeeSuggestHeight = 70;
        exfeeShowview = [[EXImagesCollectionView alloc]initWithFrame:CGRectMake(CGRectGetMinX(c) + 10, CGRectGetMaxY(descView.frame) + DESC_BOTTOM_MARGIN - EXFEE_OVERLAP, c.size.width-20, exfeeSuggestHeight + EXFEE_OVERLAP)];
        exfeeShowview.backgroundColor = [UIColor clearColor];
        [exfeeShowview calculateColumn];
        [exfeeShowview setDataSource:self];
        [exfeeShowview setDelegate:self];
        [container addSubview:exfeeShowview];
        
        timeRelView = [[UILabel alloc] initWithFrame:CGRectMake(left, exfeeShowview.frame.origin.y + exfeeShowview.frame.size.height + EXFEE_BOTTOM_MARGIN, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, TIME_RELATIVE_HEIGHT)];
        timeRelView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        timeRelView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21];
        timeRelView.shadowColor = [UIColor whiteColor];
        timeRelView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeRelView.backgroundColor = [UIColor clearColor];
        timeRelView.tag = kViewTagTimeTitle;
        [container addSubview:timeRelView];
        
        timeAbsView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeRelView.frame.origin.y + timeRelView.frame.size.height + TIME_RELATIVE_BOTTOM_MARGIN, c.size.width /2 -  CONTAINER_VERTICAL_PADDING, TIME_ABSOLUTE_HEIGHT)];
        timeAbsView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        timeAbsView.shadowColor = [UIColor whiteColor];
        timeAbsView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeAbsView.backgroundColor = [UIColor clearColor];
        timeAbsView.tag = kViewTagTimeDescription;
        [container addSubview:timeAbsView];
        
        timeZoneView= [[UILabel alloc] initWithFrame:CGRectMake(left + timeAbsView.frame.size.width + TIME_ABSOLUTE_RIGHT_MARGIN, timeAbsView.frame.origin.y, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 - timeAbsView.frame.size.width  - TIME_ABSOLUTE_RIGHT_MARGIN , TIME_ZONE_HEIGHT)];
        timeZoneView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        timeZoneView.backgroundColor = [UIColor clearColor];
        timeZoneView.hidden = YES;
        timeZoneView.tag = kViewTagTimeAdditional;
        [container addSubview:timeZoneView];
        
        placeTitleView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeAbsView.frame.origin.y + timeAbsView.frame.size.height + TIME_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_TITLE_HEIGHT)];
        placeTitleView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        placeTitleView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21];
        placeTitleView.shadowColor = [UIColor whiteColor];
        placeTitleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeTitleView.numberOfLines = 2;
        placeTitleView.backgroundColor = [UIColor clearColor];
        placeTitleView.tag = kViewTagPlaceTitle;
        [container addSubview:placeTitleView];
        
        placeDescView= [[UILabel alloc] initWithFrame:CGRectMake(left, placeTitleView.frame.origin.y + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_DESC_HEIGHT)];
        placeDescView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        placeDescView.shadowColor = [UIColor whiteColor];
        placeDescView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeDescView.numberOfLines = 4;
        placeDescView.lineBreakMode = NSLineBreakByWordWrapping;
        placeDescView.backgroundColor = [UIColor clearColor];
        placeDescView.tag = kViewTagPlaceDescription;
        [container addSubview:placeDescView];
        
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) ;
        int b = (placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + c.origin.y + OVERLAP /*+ DECTOR_HEIGHT_EXTRA*/);
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, placeDescView.frame.origin.y + placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b)];
        mapView.backgroundColor = [UIColor lightGrayColor];
        mapView.scrollEnabled = NO;
        mapView.delegate = self;
        
        [container addSubview:mapView];
        mapShadow = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(mapView.frame), CGRectGetMinY(mapView.frame), CGRectGetWidth(mapView.frame), 4)];
        [mapShadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow_4.png"]]];
        [container addSubview:mapShadow];
        
        
    }
    [self.view addSubview:container];
    
    headerShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x_shadow.png"]];
    headerShadow.frame = CGRectMake(0, CGRectGetMinY(container.frame), 320, 25);
    [self.view addSubview:headerShadow];
    
    {
        tabLayer = [[EXTabLayer alloc] init];
        tabLayer.frame = CGRectMake(0, head_bg_img_startY, HEADER_BACKGROUND_WIDTH * head_bg_img_scale, HEADER_BACKGFOUND_HEIGHT * head_bg_img_scale);
        tabLayer.curveBase = 0 - head_bg_img_startY;
        tabLayer.curveCenter = CGPointMake(269, tabLayer.curveBase + 100);
        [tabLayer setNeedsLayout];
        //[tabLayer setNeedsDisplay];
        head_bg_point = tabLayer.mask.position;
        [self.view.layer addSublayer:tabLayer];
    }
    
    titleView = [[UILabel alloc] initWithFrame:CGRectMake(25, 19, 290, 50)];
    titleView.textColor = [UIColor COLOR_RGB(0xFE, 0xFF,0xFF)];
    titleView.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.lineBreakMode = UILineBreakModeWordWrap;
    titleView.numberOfLines = 2;
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.shadowColor = [UIColor blackColor];
    titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
    titleView.tag = kViewTagTitle;
    [self.view addSubview:titleView];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.tag = kViewTagBack;
    [self.view  addSubview:btnBack];
    
    // Gesture handler: need merge
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [container addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    UITapGestureRecognizer *headTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderTap:)];
    [headerView addGestureRecognizer:headTapRecognizer];
    [headTapRecognizer release];
    
    UISwipeGestureRecognizer *headSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderSwipe:)];
    headSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [headerView addGestureRecognizer:headSwipeRecognizer];
    [headSwipeRecognizer release];
    
    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapTap:)];
    mapTap.delegate = self;
    [mapView addGestureRecognizer:mapTap];
    [mapTap release];
    
    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightRecognizer];
    [swipeRightRecognizer release];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftRecognizer];
    [swipeLeftRecognizer release];
    
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // fill data & relayout
    if(_cross == nil){
        _cross = [Cross object];
        _cross.cross_description=@"";
    }
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    if(users!=nil && [users count] > 0)
    {
        _default_user = [[users objectAtIndex:0] retain];
    }

    
    [self refreshUI];
    
    if (_widgetId > 0) {
        [self swapChildViewController:_widgetId];
    }
    
    if (tabWidget == nil) {
        NSArray* imgs = [NSArray arrayWithObjects:[UIImage imageNamed:@"widget_x_30"], [UIImage imageNamed:@"widget_conv_30"], nil];
        tabWidget = [[EXTabWidget alloc] initWithFrame:CGRectMake(0, 66, CGRectGetWidth(self.view.bounds), 40) withImages:imgs current:_widgetId];
        tabWidget.delegate = self;
        [self.view insertSubview:tabWidget belowSubview:btnBack];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSString *updated_at = [formatter stringFromDate:_cross.updated_at];
    [formatter release];
    
    //  [NSDictionary dictionaryWithObjectsAndKeys:@"cross_reload",@"name",_cross.cross_id,@"cross_id", nil]
    //    [APICrosses LoadCrossWithUserId:[_cross.cross_id intValue] updatedtime:updated_at success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    //    [APICrosses LoadCrossWithCrossId:[_cross.cross_id intValue] updatedtime:updated_at  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    //    } failure:^[(RKObjectRequestOperation *operation, NSError *error) {
    //    }];
    [APICrosses LoadCrossWithCrossId:[_cross.cross_id intValue] updatedtime:updated_at success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]])
        {
            Meta* meta=(Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
            if([meta.code intValue]==403){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                alert.tag=403;
                [alert show];
                [alert release];
            }else if([meta.code intValue]==200){
                [self refreshUI];
            }
            
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [titleView release];
    [dectorView release];
    [headerView release];
    
    [descView release];
    [exfeeShowview release];
    [timeRelView release];
    [timeAbsView release];
    [timeZoneView release];
    [placeTitleView release];
    [placeDescView release];
    [mapView release];
    [mapShadow release];
    [container release];
    
    [tabLayer release];
    [tabWidget release];
    
    [headerShadow release];
    
    [super dealloc];
}

#pragma mark == Update UI Views
- (void)refreshUI{
    [self fillCross:self.cross];
}

- (void)fillCross:(Cross*) x{
    if (x != nil){
        [self fillTitle:x];
        [self fillBackground:x.widget];
        [self fillDescription:x];
        [self fillExfee];
        [self fillTime:x.time];
        [self fillPlace:x.place];
        [self fillConversationCount:x.conversation_count];
    }
    [self relayoutUI];
}

- (void) fillTitle:(Cross*)x{
    [titleView setText:x.title];
}

- (void) fillBackground:(NSArray*)widgets{
    BOOL flag = NO;
    for(NSDictionary *widget in widgets) {
        if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            NSString* url = [widget objectForKey:@"image"];
            if (url && url.length > 0) {
                NSString *imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
                UIImage *backimg = [[ImgCache sharedManager] getImgFromCache:imgurl];
                if(backimg == nil || [backimg isEqual:[NSNull null]]){
                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                    dispatch_async(imgQueue, ^{
                        // Not in Cache
                        dectorView.image = [UIImage imageNamed:@"x_titlebg_default.jpg"];
                        [tabLayer setimage:[UIImage imageNamed:@"x_titlebg_default.jpg"]];
                        UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(backimg!=nil && ![backimg isEqual:[NSNull null]]){
                                // Fill after download
                                dectorView.image = backimg;
                                [tabLayer setimage:backimg];
                            }
                        });
                    });
                    dispatch_release(imgQueue);
                }else{
                    // Find in cache
                    dectorView.image = backimg;
                    [tabLayer setimage:backimg];
                }
                flag = YES;
                break;
            }
        }
    }
    if (flag == NO){
        // Missing Background widget
        dectorView.image = [UIImage imageNamed:@"x_titlebg_default.jpg"];
        [tabLayer setimage:[UIImage imageNamed:@"x_titlebg_default.jpg"]];
    }
}

- (void) fillDescription:(Cross*)x{
    if (x.cross_description == nil || x.cross_description.length == 0){
        descView.hidden = YES;
        descView.text = @"";
        [self setLayoutDirty];
    }else{
        descView.text = x.cross_description;
        descView.hidden = NO;
        [self setLayoutDirty];
    }
}

- (void)fillExfee{
    //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *exfee = [[NSMutableArray alloc]  initWithCapacity:12];
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"invitation_id" ascending:YES];
    NSArray *invitations=[_cross.exfee.invitations sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    int myself = 0;
    int accepts = 0;
    
    for(Invitation *invitation in invitations) {
        if([self isMe:invitation.identity]){
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

- (void)fillTime:(CrossTime*)time{
    if (time != nil){
        NSString *title = [time getTimeTitle];
        [title retain];
        if (title == nil || title.length == 0) {
            timeRelView.text = @"Sometime";
            timeAbsView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
            timeAbsView.text = @"Pick a time";
            timeAbsView.hidden = NO;
            timeZoneView.text = @"";
            timeZoneView.hidden = YES;
        }else{
            timeRelView.text = title;
            
            timeAbsView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
            NSString* desc = [time getTimeDescription];
            [desc retain];
            if(desc != nil && desc.length > 0){
                timeAbsView.text = desc;
                timeAbsView.hidden = NO;
                [timeAbsView sizeToFit];
                
                NSString* tz = [time getTimeZoneLine];
                [tz retain];
                if (tz != nil && tz.length > 0) {
                    timeZoneView.hidden = NO;
                    timeZoneView.text = [NSString stringWithFormat:@"(%@)", tz];
                    [timeZoneView sizeToFit];
                }else{
                    timeZoneView.hidden = YES;
                    timeZoneView.text = @"";
                }
                [tz release];
                
            }else{
                timeAbsView.text = @"";
                timeAbsView.hidden = YES;
                timeZoneView.hidden = YES;
                timeZoneView.text = @"";
            }
            [desc release];
        }
        [title release];
    }else{
        timeRelView.text = @"Sometime";
        timeAbsView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
        timeAbsView.text = @"Pick a time";
        timeAbsView.hidden = NO;
        timeZoneView.text = @"";
        timeZoneView.hidden = YES;
    }
    [self setLayoutDirty];
}

- (void)fillPlace:(Place*)place{
    if(place == nil || [place isEmpty]){
        placeTitleView.text = @"Somewhere";
        placeDescView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
        placeDescView.text = @"Choose a place";
        placeDescView.hidden = NO;
        mapView.hidden = YES;
        [self setLayoutDirty];
    }else {
        placeDescView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
        if ([place hasTitle]){
            placeTitleView.text = place.title;
            
            if ([place hasDescription]){
                placeDescView.text = place.place_description;
                placeDescView.hidden = NO;
                [placeDescView sizeToFit];
            }else{
                placeDescView.text = @"";
                placeDescView.hidden = YES;
            }
        }else{
            placeTitleView.text = @"Somewhere";
            placeDescView.hidden = YES;
            //mapView.hidden = YES;
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
            NSString *placeTitle = place.title;
            if (placeTitle == nil || place.title.length == 0) {
                placeTitle = @"Somewhere";
            }
            MapPin *pin = [[MapPin alloc] initWithCoordinates:region.center placeName:placeTitle description:@""];
            [mapView addAnnotation:pin];
            [pin release];
            mapView.showsUserLocation = YES;
            
        }else{
            mapView.showsUserLocation = NO;
            mapView.hidden = YES;
        }
        [self setLayoutDirty];
    }
}

- (void)fillConversationCount:(NSNumber*)count{
//    if ([count intValue] > 0){
//        widgetTabBar.contents = [NSArray arrayWithObjects:@"", [count stringValue], nil];
//        tabBar.contents = [NSArray arrayWithObjects:@"", [count stringValue], nil];
//    }else{
//        widgetTabBar.contents = nil;
//        tabBar.contents = nil;
//    }
}

#pragma mark ==== Relayout methods
- (void)relayoutUI{
    [self relayoutUIwithAnimation:NO];
}

- (void)relayoutUIwithAnimation:(BOOL)Animated{
    if (layoutDirty == YES){
        //        NSLog(@"relayoutUI");
        CGRect c = container.frame;
        
        float left = CONTAINER_VERTICAL_PADDING;
        float width = c.size.width - CONTAINER_VERTICAL_PADDING * 2;
        
        float baseX = CONTAINER_VERTICAL_PADDING;
        float baseY = CONTAINER_TOP_PADDING;
        
        // Description
        if (descView.hidden == NO) {
            CGSize size = [descView sizeThatFits:CGSizeMake(width, INFINITY)];
            //descView.frame = CGRectMake(left , baseY, descView.frame.size.width, descView.frame.size.height);
            if (Animated) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.233];
            }
            CGRect newRect = CGRectMake(left , baseY, width, size.height);
            descView.center = CGPointMake(CGRectGetMidX(newRect), CGRectGetMidY(newRect));
            descView.bounds = CGRectMake(0 , 0, width, size.height);
            if (Animated) {
                [UIView commitAnimations];
            }
            baseX = left + size.width;
            baseY = baseY + size.height;
        }
        if (Animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.233];
        }
        // Exfee
        if (exfeeShowview.hidden == NO){
            if (descView.hidden == NO) {
                baseY += DESC_BOTTOM_MARGIN;
            }
            exfeeShowview.frame = CGRectMake(CGRectGetMinX(c)+10, baseY - EXFEE_OVERLAP, CGRectGetWidth(c)-20, exfeeSuggestHeight + EXFEE_OVERLAP);
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
            }else{
                baseY += ADDITIONAL_SLOT;
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
                baseY = CGRectGetMaxY(timeAbsView.frame);
            }
        }
        
        //Place
        if (placeTitleView.hidden == NO){
            baseY += TIME_BOTTOM_MARGIN;
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
        }else{
            placeDescView.frame = CGRectMake(baseX, baseY, 0, ADDITIONAL_SLOT);
        }
        
        // Map
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) - DECTOR_HEIGHT;
        int b = (CGRectGetMaxY(placeDescView.frame) - CGRectGetMinY(placeTitleView.frame) + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + OVERLAP + 8 /*+ SMALL_SLOT */);
        mapView.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width , a - b);
        mapShadow.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width , 4);
        mapShadow.hidden = mapView.hidden;
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = CGRectGetMaxY(placeDescView.frame);
        }else{
            s.height = CGRectGetMaxY(mapView.frame);
        }
        container.contentSize = s;
        
        if (Animated) {
            [UIView commitAnimations];
        }
        [self clearLayoutDirty];
    }
}

- (void)setLayoutDirty{
    layoutDirty = YES;
}

- (void)clearLayoutDirty{
    layoutDirty = NO;
}

#pragma mark ==== Others
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
    [self relayoutUIwithAnimation:YES];
}

#pragma mark ==== Helpers
- (BOOL) isMe:(Identity*)my_identity{
//    for(Identity *_identity in _default_user.identities){
//        if([_identity.identity_id isEqual:my_identity.identity_id])
//            return YES;
//    }
    return NO;
    
}

#pragma mark == selector/delegate from UI Views
- (void)gotoBack:(id)sender{
    [self goBack];
}

- (void)switchWidget:(id)sender{
    [self hidePopupIfShown];
    [self swapChildViewController:(_headerStyle + 1) % 2];
}

#pragma mark EXImagesCollectionView Datasource methods

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [exfeeInvitations count];
}
- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView itemAtIndex:(int)index{
    Invitation *invitation =[exfeeInvitations objectAtIndex:index];
    EXInvitationItem *item=[[EXInvitationItem alloc] initWithInvitation:invitation];
    if([self isMe:invitation.identity]){
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
    return item;
}

- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView shouldResizeHeightTo:(float)height{
    if (height > 0){
        exfeeSuggestHeight = height;
    }
    [self setLayoutDirty];
    [self relayoutUI];
    
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect {
    NSArray* reducedExfeeIdentities=exfeeInvitations;//[self getReducedExfeeIdentities];
    if(index == [reducedExfeeIdentities count])
    {
        //        if(viewmode==YES && exfeeShowview.editmode==NO)
        //            return;
        //        [self ShowGatherToolBar];
        //        [self ShowExfeeView];
    }
    else if(index < [reducedExfeeIdentities count]){
        //AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *arr=exfeeInvitations;//[self getReducedExfeeIdentities];
        Invitation *invitation =[arr objectAtIndex:index];
        
        
        CGPoint location = CGPointMake(CGRectGetMinX(exfeeShowview.frame) + (col+1)*(50+5*2)+5, CGRectGetMinY(exfeeShowview.frame) + row*(50+5*2)+y_start_offset);
        CGPoint newLocation = [self.view convertPoint:location fromView:exfeeShowview.superview];
        
        int x = newLocation.x;
        int y = newLocation.y;
        
        if(x + 180 > self.view.frame.size.width){
            x = x - 180;
        }
        if(rsvpstatusview==nil){
            rsvpstatusview=[[EXRSVPStatusView alloc] initWithFrame:CGRectMake(x, y-55, 180+12, 50) withDelegate:self];
            [self.view addSubview:rsvpstatusview];
        }
        rsvpstatusview.invitation=invitation;
        
        
        float avatar_center = rect.origin.x + rect.size.width / 2;
        int rsvpstatus_x = avatar_center - rsvpstatusview.frame.size.width /2;
        if(rsvpstatus_x < 0)
            rsvpstatus_x = 0;
        if(rsvpstatus_x + rsvpstatusview.frame.size.width > self.view.frame.size.width)
            rsvpstatus_x = self.view.frame.size.width - rsvpstatusview.frame.size.width;
        
        if([self isMe:invitation.identity]){
            NSInteger ctrlId = popupCtrolId;
            [self hidePopupIfShown:kPopupTypeEditStatus];
            if (ctrlId != kPopupTypeEditStatus) {
                [self showMenu:invitation items:[NSArray arrayWithObjects:@"Accepted",@"Unavailable",@"Interested", nil]];
            }
        }else{
            [rsvpstatusview setHidden:NO];
            
            [rsvpstatusview setFrame:CGRectMake(rsvpstatus_x, y-rsvpstatusview.frame.size.height, rsvpstatusview.frame.size.width, rsvpstatusview.frame.size.height)];
            
            rsvpstatus_x-=rsvpstatusview.frame.origin.x;
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:
                                               @"transform.translation.y"];
            moveAnimation.duration= 0.233;
            moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            
            moveAnimation.fromValue =[NSNumber numberWithFloat:y-rsvpstatusview.frame.size.height+30-rsvpstatusview.frame.origin.y];
            moveAnimation.toValue =[NSNumber numberWithFloat:y-rsvpstatusview.frame.size.height-rsvpstatusview.frame.origin.y+7];
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.fillMode = kCAFillModeForwards;
            [[rsvpstatusview layer] addAnimation:moveAnimation forKey:@"moveAnimation"];
            
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:
                                                @"transform.scale"];
            scaleAnimation.duration= 0.233;
            scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            
            scaleAnimation.fromValue =[NSNumber numberWithInt:0.1];
            scaleAnimation.toValue =[NSNumber numberWithInt:1];
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            [[rsvpstatusview layer] addAnimation:scaleAnimation forKey:@"scaleAnimation"];
            
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:
                                                  @"opacity"];
            opacityAnimation.duration= 0.3;
            opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            
            opacityAnimation.fromValue =[NSNumber numberWithInt:0];
            opacityAnimation.toValue =[NSNumber numberWithInt:1];
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            [[rsvpstatusview layer] addAnimation:opacityAnimation forKey:@"opacityAnimation"];
            
            
            [rsvpstatusview setNeedsDisplay];
            [self hidePopupIfShown:kPopupTypeVewStatus];
        }
    }
}

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)map didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id < MKAnnotation >)annotation{
    MKAnnotationView *pinView = nil;
    if(annotation != nil)
    {
        if ([annotation class] == MKUserLocation.class) {
            return nil;
        }
        
        static NSString *defaultPinID = @"com.exfe.pin";
        pinView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ){
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"map_pin_blue.png"];
            
            UIButton *btnNav = [UIButton buttonWithType:UIButtonTypeCustom];
            btnNav.frame = CGRectMake(0, 0, 30, 30);
            [btnNav setImage:[UIImage imageNamed:@"navi_btn.png"] forState:UIControlStateNormal];
            pinView.rightCalloutAccessoryView = btnNav;
        }else{
            pinView.annotation = annotation;
        }
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    //    NSLog(@"Click to Navigation");
    id<MKAnnotation> annotation = view.annotation;
    //NSString *title = annotation.title;
    CLLocationDegrees latitude = annotation.coordinate.latitude;
    CLLocationDegrees longitude = annotation.coordinate.longitude;
    //int zoom = 13;
    
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
    //        MKPlacemark *endLocation = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
    //        MKMapItem *endingItem = [[MKMapItem alloc] initWithPlacemark:endLocation];
    //        NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
    //        [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
    //        [endingItem openInMapsWithLaunchOptions:launchOptions];
    //        [launchOptions release];
    //        [endLocation release];
    //        [endingItem release];
    //    }else{
    //        //NSString * query = [NSString stringWithFormat:@"q=%@@%1.6f,%1.6f&z=%d", title, latitude, longitude, zoom];
    //        NSString * query = [NSString stringWithFormat:@"q=%@@%1.6f,%1.6f&z=%d", title, latitude, longitude, zoom];
    //
    //        NSString *mapurl = [NSString stringWithFormat:@"maps://maps?%@", query];
    //        NSString *url4google = [NSString stringWithFormat:@"http://maps.google.com/maps?%@", query];
    //        NSString *url4apple = [NSString stringWithFormat:@"http://maps.apple.com/?%@", query];
    //        NSURL *url = [NSURL URLWithString:mapurl];
    //        if ([[UIApplication sharedApplication] canOpenURL:url]) {
    //            [[UIApplication sharedApplication] openURL:url];
    //        }else{
    //            url = [NSURL URLWithString:url4google];
    //            [[UIApplication sharedApplication] openURL:url];
    //        }
    //    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        //using iOS6 native maps app
        //first create latitude longitude object
        CLLocationCoordinate2D coordinate = annotation.coordinate; //CLLocationCoordinate2DMake(latitude,longitude);
        
        //create MKMapItem out of coordinates
        MKPlacemark* placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem* destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
        //        // Open in own app
        //        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        // Open in map app
        [MKMapItem openMapsWithItems:[NSArray arrayWithObject:destination] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        [destination release];
        [placeMark release];
    } else{
        
        //using iOS 5 which has the Google Maps application
        NSString* mapurl = [NSString stringWithFormat: @"maps://maps?saddr=Current+Location&daddr=Destination@%f,%f", latitude, longitude];
        // hide saddr=My+Location for web
        NSString* mapurl4google = [NSString stringWithFormat: @"http://maps.google.com/maps?daddr=Destination@%f,%f", latitude, longitude];
        //        //add place title
        //        // title need encoding: invalide char->%xx & space->+
        //        // also change maps.google.com to maps.apple.com
        //        NSString *t = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        //        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?daddr=%@@%f,%f", t, latitude, longitude];
        NSURL *url = [NSURL URLWithString:mapurl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }else{
            url = [NSURL URLWithString:mapurl4google];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
    
    
}


#pragma mark == ViewController Navigation
- (void) goBack{
//RESTKIT0.2
//    RKObjectManager* manager =[RKObjectManager sharedManager];
//    [manager.requestQueue cancelAllRequests];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)moveLayer:(CALayer*)layer to:(CGPoint)point
{
    [self moveLayer:layer to:point duration:0.2];
}

-(void)moveLayer:(CALayer*)layer to:(CGPoint)point duration:(NSTimeInterval)time
{
    // Prepare the animation from the current position to the new position
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = time;
    animation.fromValue = [layer valueForKey:@"position"];
    // iOS
    animation.toValue = [NSValue valueWithCGPoint:point];
    
    // Update the layer's position so that the layer doesn't snap back when the animation completes.
    layer.position = point;
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"position"];
}

#pragma mark == Helper methods for Header
- (void) changeHeaderStyle:(NSInteger)style{
    //CGRect a = [UIScreen mainScreen].applicationFrame;
    switch (style) {
        case kHeaderStyleHalf:
            titleView.frame = CGRectMake(25, 0, 290, 50);
            titleView.lineBreakMode = UILineBreakModeTailTruncation;
            titleView.numberOfLines = 1;
            btnBack.frame = CGRectMake(0, 0, 20, 44);
            tabWidget.frame = CGRectMake(0, 66 - 44, CGRectGetWidth(self.view.bounds), 40);
            [self moveLayer:tabLayer.mask to:CGPointMake(head_bg_point.x, head_bg_point.y - 44)];
            break;
            
        default:
            titleView.frame = CGRectMake(25, 19, 290, 50);
            titleView.lineBreakMode = UILineBreakModeWordWrap;
            titleView.numberOfLines = 2;
            btnBack.frame = CGRectMake(0, DECTOR_HEIGHT / 2 - 44 / 2, 20, 44);
            tabWidget.frame = CGRectMake(0, 66, CGRectGetWidth(self.view.bounds), 40);
            [self moveLayer:tabLayer.mask to:head_bg_point];
            break;
    }
    _headerStyle = style;
}

#pragma mark == Helper methods for Content
-(void)swapViewControllers:childViewController{
    //UIViewController *aNewViewController = [[UIViewController alloc] initWithNibName:@"childViewController" bundle:nil] ;
    
    
    //[aNewViewController.view layoutIfNeeded];
    // Custom new view controller UI;
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:childViewController];
    
    __weak __block CrossGroupViewController *weakSelf=self;
    [self transitionFromViewController:self.currentViewController
                      toViewController:childViewController
                              duration:1.0
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:nil
                            completion:^(BOOL finished) {
                                
                                [weakSelf.currentViewController removeFromParentViewController];
                                [childViewController didMoveToParentViewController:weakSelf];
                                
                                weakSelf.currentViewController = [childViewController autorelease];
                            }];
}

- (void)swapChildViewController:(NSInteger)widget_id{
    
    if (_currentViewController) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self changeHeaderStyle:kHeaderStyleFull];
                         }];
        
        [UIView animateWithDuration:0.233
                              delay:0.2
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.currentViewController.view.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             
                             [self.currentViewController.view removeFromSuperview];
                             [self.currentViewController removeFromParentViewController];
                             [self.currentViewController didMoveToParentViewController:nil];
                             self.currentViewController = nil;
                             
                             [self showChinldViewController:widget_id];
                         }];
    }else{
        [self showChinldViewController:widget_id];
    }
}

- (void)showChinldViewController:(NSInteger)widget_id{
    switch (widget_id) {
        case 1:
        {
            WidgetConvViewController * conversationView =  [[WidgetConvViewController alloc]initWithNibName:@"WidgetConvViewController" bundle:nil] ;
            
            // prepare data for conversation
            conversationView.exfee_id = [_cross.exfee.exfee_id intValue];
            conversationView.cross_title = _cross.title;
            for(NSDictionary *widget in _cross.widget) {
                if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                    conversationView.headImgDict = widget;
                    break;
                }
            }
            Invitation* myInv = [self getMyInvitation];
            if (myInv != nil){
                conversationView.identity = myInv.identity;
            }
            
            // clean up data
            _cross.conversation_count = 0;
            [self fillConversationCount:0];
            
            [self addChildViewController:conversationView];
            [self.view insertSubview:conversationView.view aboveSubview:headerShadow];
            conversationView.view.alpha = 0;
            __weak __block CrossGroupViewController *weakSelf=self;
            [UIView animateWithDuration:0.233 animations:^{
                conversationView.view.alpha = 1;
            }
                             completion:^(BOOL finished){
                                 [conversationView didMoveToParentViewController:weakSelf];
                                 weakSelf.currentViewController = [conversationView autorelease];
                                 [UIView animateWithDuration:0.2
                                                  animations:^{
                                                      [self changeHeaderStyle:kHeaderStyleHalf];
                                                  }];
                                 
                             }];
        }
            break;
            
        default:
            
            
            
            break;
    }
}



#pragma mark TODO gesture handler
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    //    if (mapView.superview.tag == kViewTagContainer && mapView.scrollEnabled == YES){
    //        return NO;
    //    }
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint center = gestureRecognizer.view.center;
    if (ABS(location.x - center.x) < 30 && ABS(location.y - center.y) < 30){
        return NO;
    }
    
    return YES;
}

- (void)hidePopupIfShown{
    [self hidePopupIfShown:0];
}

- (void)hidePopupIfShown:(NSInteger)skipId{
    NSInteger ctrlid = skipId & MASK_LOW_BITS;
    
    if (ctrlid != (kPopupTypeEditStatus & MASK_LOW_BITS)) {
        [self hideMenuWithAnimation:YES];
    }
    if (ctrlid != (kPopupTypeVewStatus & MASK_LOW_BITS)) {
        [self hideStatusView];
    }
    if (ctrlid != (kPopupTypeEditTitle & MASK_LOW_BITS)) {
        [self hideTitleAndDescEditMenuWithAnimation:YES];
    }
    if (ctrlid != (kPopupTypeEditDescription & MASK_LOW_BITS)) {
        [self hideTitleAndDescEditMenuWithAnimation:YES];
    }
    if (ctrlid != (kPopupTypeEditTime & MASK_LOW_BITS)) {
        [self hideTimeEditMenuWithAnimation:YES];
    }
    if (ctrlid != (kPopupTypeEditPlace & MASK_LOW_BITS)) {
        [self hidePlaceEditMenuWithAnimation:YES];
    }
    
    popupCtrolId = skipId;
}

- (void)showPopup:(NSInteger)ctrlId{
    if (ctrlId == 0 ) {
        [self hidePopupIfShown];
        return;
    }
    
    if (ctrlId != popupCtrolId) {
        NSInteger low = ctrlId & MASK_LOW_BITS;
        [self hidePopupIfShown:ctrlId];
        switch (low) {
            case kPopupTypeEditTitle & MASK_LOW_BITS:
            case kPopupTypeEditDescription & MASK_LOW_BITS:
                [self showTtitleAndDescEditMenu:titleView];
                break;
            case kPopupTypeEditTime & MASK_LOW_BITS:
                [self showTimeEditMenu:timeRelView];
                break;
            case kPopupTypeEditPlace & MASK_LOW_BITS:
                [self showPlaceEditMenu:placeTitleView];
                break;
            case kPopupTypeEditStatus & MASK_LOW_BITS:
                break;
            case kPopupTypeVewStatus & MASK_LOW_BITS:
                break;
                
            default:
                break;
        }
        
    }
}

- (void)handleMapTap:(UITapGestureRecognizer*)sender{
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hidePopupIfShown];
        
        NSInteger tagId = mapView.superview.tag;
        if (tagId == kViewTagContainer) {
            [mapView removeFromSuperview];
            CGRect f2 = [self.view convertRect:mapView.frame fromView:mapView.superview];
            mapView.frame = CGRectOffset(f2, 0, CGRectGetMinY(container.frame) - container.contentOffset.y + 20);
            savedFrame = mapView.frame;
            savedScrollEnable = mapView.scrollEnabled;
            mapView.scrollEnabled = YES;
            [self.view addSubview:mapView];
            
            [UIView animateWithDuration:0.233 animations:^{
                mapView.frame = self.view.bounds;
            }];
        }else{
            [UIView animateWithDuration:0.233 animations:^{
                mapView.frame = savedFrame;
            } completion:^(BOOL finished){
                mapView.scrollEnabled = savedScrollEnable;
                [mapView removeFromSuperview];
                [mapShadow.superview insertSubview:mapView belowSubview:mapShadow];
                [self setLayoutDirty];
                [self relayoutUI];
            }];
            
            
        }
    }
}

- (void)handleHeaderTap:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (_currentViewController == nil) {
            if (titleView.hidden == NO && CGRectContainsPoint(titleView.frame, location)){
                [self showPopup:kPopupTypeEditTitle];
                return;
            }
        }
        [self hidePopupIfShown];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locInContainer = [container convertPoint:location fromView:self.view];
        
        [self hidePopupIfShown];
        if (descView.hidden == NO && CGRectContainsPoint([Util expandRect:descView.frame], locInContainer)) {
            [self showTimeEditMenu:descView];
            [self clickforTitleAndDescEdit:descView];
            return;
        }
        //        if (CGRectContainsPoint([Util expandRect:[exfeeShowview frame]], location)) {
        //            //        [crosstitle resignFirstResponder];
        //            [exfeeShowview becomeFirstResponder];
        //            CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
        //            [exfeeShowview onImageTouch:exfeeviewlocation];
        //            return;
        //        }
        
        CGRect r1 = CGRectNull;
        CGRect r2 = CGRectNull;
        CGRect r3 = CGRectNull;
        if (timeRelView.hidden == NO) {
            r1 = timeRelView.frame;
        }
        if (timeAbsView.hidden == NO) {
            r2 = timeAbsView.frame;
        }
        if (timeZoneView.hidden == NO) {
            r3 = timeZoneView.frame;
        }
        if (CGRectContainsPoint([Util expandRect:r1 with:r2 with:r3], locInContainer)) {
            [self showTimeEditMenu:timeRelView];
            [self clickforTimeEdit:timeRelView];
            return;
        }
        
        r1 = CGRectNull;
        r2 = CGRectNull;
        if (placeTitleView.hidden == NO) {
            r1 = placeTitleView.frame;
        }
        if (placeDescView.hidden == NO) {
            r2 = placeDescView.frame;
        }
        if (CGRectContainsPoint([Util expandRect:r1 with:r2], locInContainer)) {
            [self showPlaceEditMenu:placeTitleView];
            [self clickforPlaceEdit:placeTitleView];
            return;
        }
        
        
        
    }
}

- (void)handleHeaderSwipe:(UISwipeGestureRecognizer*)sender{
    //CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self hidePopupIfShown];
        
        [self goBack];
    }
}

- (void)handleTap:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        //UIView *tappedView = [sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
        
        if (descView.hidden == NO && CGRectContainsPoint([Util expandRect:descView.frame], location)) {
            [self showDescriptionFullContent: (descView.numberOfLines != 0)];
            [self showPopup:kPopupTypeEditDescription];
            return;
        }
        if (CGRectContainsPoint([Util expandRect:[exfeeShowview frame]], location)) {
            //        [crosstitle resignFirstResponder];
            [exfeeShowview becomeFirstResponder];
            CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
            [exfeeShowview onImageTouch:exfeeviewlocation];
            return;
        }
        
        CGRect r1 = CGRectNull;
        CGRect r2 = CGRectNull;
        CGRect r3 = CGRectNull;
        if (timeRelView.hidden == NO) {
            r1 = timeRelView.frame;
        }
        if (timeAbsView.hidden == NO) {
            r2 = timeAbsView.frame;
        }
        if (timeZoneView.hidden == NO) {
            r3 = timeZoneView.frame;
        }
        if (CGRectContainsPoint([Util expandRect:r1 with:r2 with:r3], location)) {
            [self showPopup:kPopupTypeEditTime];
            return;
        }
        
        r1 = CGRectNull;
        r2 = CGRectNull;
        if (placeTitleView.hidden == NO) {
            r1 = placeTitleView.frame;
        }
        if (placeDescView.hidden == NO) {
            r2 = placeDescView.frame;
        }
        if (CGRectContainsPoint([Util expandRect:r1 with:r2], location)) {
            [self showPopup:kPopupTypeEditPlace];
            return;
        }
        
        [self hidePopupIfShown];
    }
}


#pragma mark TODO trigger from gesture
- (void)clickforTitleAndDescEdit:(id)sender{
    [self showTitleAndDescView];
    [self performSelector:@selector(hidePopupIfShown) withObject:sender afterDelay:1];
    // title & desc need the current popupctrlid info to determing the focus. keep the sequence.
}

- (void)clickforTimeEdit:(id)sender{
    [self performSelector:@selector(hidePopupIfShown) withObject:sender afterDelay:1];
    //[self hidePopupIfShown];
    [self showTimeView];
}

- (void)clickforPlaceEdit:(id)sender{
    [self performSelector:@selector(hidePopupIfShown) withObject:sender afterDelay:1];
    [self ShowPlaceView:@"search"];
}

- (void)clickforMenuEdit:(id)sender{
    UIView *v = sender;
    switch (v.tag) {
        case kViewTagTitle & kViewTagMaskLayerTwo:
        case kViewTagDescription & kViewTagMaskLayerTwo:
            [self showTitleAndDescView];
            [self performSelector:@selector(hidePopupIfShown) withObject:sender afterDelay:1];
            break;
        case kViewTagTimeTitle & kViewTagMaskLayerTwo:
            [self performSelector:@selector(hidePopupIfShown) withObject:sender afterDelay:1];
            [self showTimeView];
            break;
        case kViewTagPlaceTitle & kViewTagMaskLayerTwo:
            [self performSelector:@selector(hidePopupIfShown) withObject:sender afterDelay:1];
            [self ShowPlaceView:@"search"];
            break;
        default:
            break;
    }
}

#pragma mark Edit Menu API
- (void) showTtitleAndDescEditMenu:(UIView*)sender{
    if (titleAndDescEditMenu == nil) {
        titleAndDescEditMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        titleAndDescEditMenu.frame = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetMinY(sender.frame), 50, 44);
        [titleAndDescEditMenu setImage:[UIImage imageNamed:@"edit_30.png"] forState:UIControlStateNormal];
        [titleAndDescEditMenu setImage:[UIImage imageNamed:@"edit_30_pressed.png"] forState:UIControlStateHighlighted];
        titleAndDescEditMenu.backgroundColor = [UIColor COLOR_WA(0x33, 0xF5)];
        titleAndDescEditMenu.layer.borderWidth = 0.5;
        titleAndDescEditMenu.layer.borderColor = [UIColor COLOR_WA(0xFF, 0x20)].CGColor;
        titleAndDescEditMenu.layer.cornerRadius = 1.5;
        titleAndDescEditMenu.layer.masksToBounds = YES;
        [titleAndDescEditMenu addTarget:self action:@selector(clickforTitleAndDescEdit:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:titleAndDescEditMenu];
    }
    CGRect original = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetMinY(sender.frame) + SMALL_SLOT, 50, 44);
    titleAndDescEditMenu.frame = original;
    titleAndDescEditMenu.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [titleAndDescEditMenu setFrame:CGRectOffset(titleAndDescEditMenu.frame, 2 - CGRectGetWidth(titleAndDescEditMenu.frame), 0)];
    [UIView commitAnimations];
}


- (void) hideTitleAndDescEditMenuWithAnimation:(BOOL)animated{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [titleAndDescEditMenu setFrame:CGRectOffset(titleAndDescEditMenu.frame, CGRectGetWidth(self.view.frame) - CGRectGetWidth(titleAndDescEditMenu.frame), 0)];
        [UIView setAnimationDidStopSelector:@selector(hideTitleAndDescEditMenuNow)];
        [UIView commitAnimations];
    }else{
        [self hideTitleAndDescEditMenuNow];
    }
}

- (void)hideTitleAndDescEditMenuNow{
    if (titleAndDescEditMenu != nil && titleAndDescEditMenu.hidden == NO) {
        titleAndDescEditMenu.hidden = YES;
    }
}


- (void) showTimeEditMenu:(UIView*)sender{
    if (timeEditMenu == nil) {
        timeEditMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        timeEditMenu.frame = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetMinY(sender.frame), 50, 44);
        [timeEditMenu setImage:[UIImage imageNamed:@"edit_30.png"] forState:UIControlStateNormal];
        [timeEditMenu setImage:[UIImage imageNamed:@"edit_30_pressed.png"] forState:UIControlStateHighlighted];
        timeEditMenu.backgroundColor = [UIColor COLOR_WA(0x33, 0xF5)];
        timeEditMenu.layer.borderWidth = 0.5;
        timeEditMenu.layer.borderColor = [UIColor COLOR_WA(0xFF, 0x20)].CGColor;
        timeEditMenu.layer.cornerRadius = 1.5;
        timeEditMenu.layer.masksToBounds = YES;
        [timeEditMenu addTarget:self action:@selector(clickforTimeEdit:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:timeEditMenu];
    }
    CGPoint newLocation = [timeEditMenu.superview convertPoint:sender.frame.origin fromView:sender.superview];
    CGRect original = CGRectMake(CGRectGetWidth(timeEditMenu.superview.bounds), newLocation.y + SMALL_SLOT, 50, 44);
    timeEditMenu.frame = original;
    timeEditMenu.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [timeEditMenu setFrame:CGRectOffset(timeEditMenu.frame, 2 - CGRectGetWidth(timeEditMenu.frame), 0)];
    [UIView commitAnimations];
}


- (void) hideTimeEditMenuWithAnimation:(BOOL)animated{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [timeEditMenu setFrame:CGRectOffset(timeEditMenu.frame, CGRectGetWidth(self.view.frame) - CGRectGetWidth(timeEditMenu.frame), 0)];
        [UIView setAnimationDidStopSelector:@selector(hideTimeEditMenuNow)];
        [UIView commitAnimations];
    }else{
        [self hideTimeEditMenuNow];
    }
}

- (void)hideTimeEditMenuNow{
    if (timeEditMenu != nil && timeEditMenu.hidden == NO) {
        timeEditMenu.hidden = YES;
    }
}

- (void) showPlaceEditMenu:(UIView*)sender{
    if (placeEditMenu == nil) {
        placeEditMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        placeEditMenu.frame = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetMinY(sender.frame), 50, 44);
        [placeEditMenu setImage:[UIImage imageNamed:@"edit_30.png"] forState:UIControlStateNormal];
        [placeEditMenu setImage:[UIImage imageNamed:@"edit_30_pressed.png"] forState:UIControlStateHighlighted];
        placeEditMenu.backgroundColor = [UIColor COLOR_WA(0x33, 0xF5)];
        placeEditMenu.layer.borderWidth = 0.5;
        placeEditMenu.layer.borderColor = [UIColor COLOR_WA(0xFF, 0x20)].CGColor;
        placeEditMenu.layer.cornerRadius = 1.5;
        placeEditMenu.layer.masksToBounds = YES;
        [placeEditMenu addTarget:self action:@selector(clickforPlaceEdit:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:placeEditMenu];
    }
    CGPoint newLocation = [placeEditMenu.superview convertPoint:sender.frame.origin fromView:sender.superview];
    CGRect original = CGRectMake(CGRectGetWidth(placeEditMenu.superview.bounds), newLocation.y + SMALL_SLOT, 50, 44);
    placeEditMenu.frame = original;
    placeEditMenu.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [placeEditMenu setFrame:CGRectOffset(placeEditMenu.frame, 2 - CGRectGetWidth(placeEditMenu.frame), 0)];
    [UIView commitAnimations];
}

- (void) hidePlaceEditMenuWithAnimation:(BOOL)animated{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [placeEditMenu setFrame:CGRectOffset(placeEditMenu.frame, CGRectGetWidth(self.view.frame) - CGRectGetWidth(placeEditMenu.frame), 0)];
        [UIView setAnimationDidStopSelector:@selector(hidePlaceEditMenuNow)];
        [UIView commitAnimations];
    }else{
        [self hidePlaceEditMenuNow];
    }
}

- (void)hidePlaceEditMenuNow{
    if (placeEditMenu != nil && placeEditMenu.hidden == NO) {
        placeEditMenu.hidden = YES;
    }
}

- (void) showPopupEditMenu:(UIView*)sender{
    UIButton* _popupEditMenu = nil;
    if (_popupEditMenu == nil) {
        _popupEditMenu = [UIButton buttonWithType:UIButtonTypeCustom];
        _popupEditMenu.frame = CGRectMake(CGRectGetWidth(self.view.frame), CGRectGetMinY(sender.frame), 50, 44);
        [_popupEditMenu setImage:[UIImage imageNamed:@"edit_30.png"] forState:UIControlStateNormal];
        [_popupEditMenu setImage:[UIImage imageNamed:@"edit_30_pressed.png"] forState:UIControlStateHighlighted];
        _popupEditMenu.backgroundColor = [UIColor COLOR_WA(0x33, 0xF5)];
        _popupEditMenu.layer.borderWidth = 0.5;
        _popupEditMenu.layer.borderColor = [UIColor COLOR_WA(0xFF, 0x20)].CGColor;
        _popupEditMenu.layer.cornerRadius = 1.5;
        _popupEditMenu.layer.masksToBounds = YES;
        [_popupEditMenu addTarget:self action:@selector(clickforMenuEdit:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_popupEditMenu];
    }
    CGPoint newLocation = [_popupEditMenu.superview convertPoint:sender.frame.origin fromView:sender.superview];
    CGRect original = CGRectMake(CGRectGetWidth(_popupEditMenu.superview.bounds), newLocation.y + SMALL_SLOT, 50, 44);
    _popupEditMenu.frame = original;
    _popupEditMenu.hidden = NO;
    _popupEditMenu.tag = sender.tag;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [_popupEditMenu setFrame:CGRectOffset(_popupEditMenu.frame, 2 - CGRectGetWidth(_popupEditMenu.frame), 0)];
    [UIView commitAnimations];
}

- (void) hidePopupEditMenuWithAnimation:(BOOL)animated{
    UIButton* _popupEditMenu = nil;
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [_popupEditMenu setFrame:CGRectOffset(_popupEditMenu.frame, CGRectGetWidth(self.view.frame) - CGRectGetWidth(_popupEditMenu.frame), 0)];
        [UIView setAnimationDidStopSelector:@selector(hidePopupEditMenuNow)];
        [UIView commitAnimations];
    }else{
        [self hidePopupEditMenuNow];
    }
}

- (void)hidePopupEditMenuNow{
    UIButton* _popupEditMenu = nil;
    if (_popupEditMenu != nil && _popupEditMenu.hidden == NO) {
        _popupEditMenu.hidden = YES;
    }
}


- (void) showMenu:(Invitation*)_invitation items:(NSArray*)itemslist{
    if(rsvpmenu == nil){
        rsvpmenu=[[EXRSVPMenuView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, exfeeShowview.frame.origin.y-20, 125, 20+[itemslist count]*44) withDelegate:self items:itemslist showTitleBar:YES];
        [self.view addSubview:rsvpmenu];
    }
    CGPoint newLocation = [rsvpmenu.superview convertPoint:exfeeShowview.frame.origin fromView:exfeeShowview.superview];
    [rsvpmenu setFrame:CGRectMake(CGRectGetWidth(rsvpmenu.superview.bounds), newLocation.y - 20, 125, 20+[itemslist count]*44)];
    
    rsvpmenu.invitation = _invitation;
    rsvpmenu.hidden = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    rsvpmenu.frame = CGRectOffset(rsvpmenu.frame, 0 - CGRectGetWidth(rsvpmenu.frame), 0);
    [UIView commitAnimations];
    
    
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.3];
    //
    //    if(rsvpstatusview!=nil)
    //       [rsvpstatusview setHidden:YES];
    //
    //    [UIView commitAnimations];
    
}




- (void)hideMenuWithAnimation:(BOOL)animated{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width, rsvpmenu.frame.origin.y, 125, 152)];
        [UIView setAnimationDidStopSelector:@selector(hideMenuNow)];
        [UIView commitAnimations];
    }else{
        [self hideMenuNow];
    }
    
}

- (void)hideMenuNow{
    if (rsvpmenu != nil && rsvpmenu.hidden == NO) {
        rsvpmenu.hidden = YES;
    }
}

- (void)hideStatusView{
    if(rsvpstatusview != nil && rsvpstatusview.hidden == NO){
        [rsvpstatusview setHidden:YES];
    }
}

- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"ACCEPTED" invitation:menu.invitation];
    [self hidePopupIfShown];
    //[self hideMenuWithAnimation:YES];
}

- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"DECLINED" invitation:menu.invitation];
    [self hidePopupIfShown];
    //[self hideMenuWithAnimation:YES];
}

- (void)RSVPPendingMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"INTERESTED" invitation:menu.invitation];
    [self hidePopupIfShown];
    //[self hideMenuWithAnimation:YES];
}

#pragma mark show Edit View Controller
- (void) showTitleAndDescView{
    TitleDescEditViewController *titleViewController=[[TitleDescEditViewController alloc] initWithNibName:@"TitleDescEditViewController" bundle:nil];
    titleViewController.delegate=self;
    NSString *imgurl = nil;
    for(NSDictionary *widget in (NSArray*)_cross.widget) {
        if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
            break;
        }
    }
    titleViewController.imgurl=imgurl;
    titleViewController.editFieldHint = popupCtrolId & MASK_LOW_BITS;
    [self presentModalViewController:titleViewController animated:YES];
    [titleViewController setCrossTitle:_cross.title desc:_cross.cross_description];
    [titleViewController release];
}

- (void) showTimeView{
    TimeViewController *timeViewController=[[TimeViewController alloc] initWithNibName:@"TimeViewController" bundle:nil];
    timeViewController.delegate=self;
    [timeViewController setDateTime:_cross.time];
    [self presentModalViewController:timeViewController animated:YES];
    [timeViewController release];
}

- (void) ShowPlaceView:(NSString*)status{
    PlaceViewController *placeViewController=[[PlaceViewController alloc]initWithNibName:@"PlaceViewController" bundle:nil];
    placeViewController.delegate=self;
    if(_cross.place!=nil){
        if(![_cross.place.title isEqualToString:@""] || ( ![_cross.place.lat isEqualToString:@""] || ![_cross.place.lng isEqualToString:@""])){
            [placeViewController setPlace:_cross.place isedit:YES];
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

#pragma mark API request for modification.
- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation{
    //    NSError *error;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    Identity *myidentity=[self getMyInvitation].identity;
    NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:_invitation.identity.identity_id,@"identity_id",myidentity.identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
    
    //    NSLog(@"%@",[rsvpdict JSONString]);
//RESTKIT0.2
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:[NSString stringWithFormat:@"[%@]",[rsvpdict JSONString]] forParam:@"rsvp"];
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/rsvp?token=%@",[_cross.exfee.exfee_id intValue],app.accesstoken];
//    [client post:endpoint usingBlock:^(RKRequest *request){
//        request.method=RKRequestMethodPOST;
//        request.params=rsvpParams;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code)
//                        if([code intValue]==200) {
//                            [APICrosses LoadCrossWithCrossId:[_cross.cross_id intValue] updatedtime:@"" delegate:self source:[NSDictionary dictionaryWithObjectsAndKeys:@"cross_reload",@"name",_cross.cross_id,@"cross_id", nil]];
//                            
//                        }
//                }
//                //We got an error!
//            }else {
//                //Check Response Body to get Data!
//            }
//        };
//        request.onDidFailLoadWithError=^(NSError *error){
//            NSString *errormsg=[error.userInfo objectForKey:@"NSLocalizedDescription"];
//            if(error.code==2)
//                errormsg=@"A connection failure has occurred.";
//            else
//                errormsg=@"Could not connect to the server.";
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//            
//            //            EXAlertView *alertview=[EXAlertView showAlertTo:self.view frame:CGRectMake(10, 10, self.view.frame.size.width-20, 22) message:@"alert" animated:YES];
//            //            [alertview setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:204/255.0 alpha:0.9]];
//            //            [EXAlertView hideAlertFrom:self.view animated:YES delay:2 ];
//            
//        };
//    }];
  
}

#pragma mark RKObjectLoaderDelegate methods
//RESTKIT0.2
//- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    if([objects count] > 0){
//        [self fillExfee];
//    }
//    
//}

#pragma mark Navigation

#pragma mark EditCrossDelegate
- (Invitation*) getMyInvitation{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    for(Invitation *invitation in exfeeInvitations)
    {
        //        if([invitation.identity.connected_user_id intValue] == app.userid)
        if([self isMe:invitation.identity])
            return invitation;
    }
    return nil;
}

- (void) addExfee:(NSArray*) invitations{
    if(exfeeInvitations==nil)
        exfeeInvitations = [[NSMutableArray alloc] initWithArray:invitations];
    else{
        for(Invitation *invitation in invitations){
            
            [exfeeInvitations addObject:invitation];
        }
    }
    
    [exfeeShowview reloadData];
}

- (void) setTime:(CrossTime*)time{
    _cross.time=time;
    [self saveCrossUpdate];
    [self fillTime:time];
    [self relayoutUI];
}

- (void) setPlace:(Place*)place{
    _cross.place=place;
    [self saveCrossUpdate];
    [self fillPlace:place];
    [self relayoutUI];
}

- (void) setTitle:(NSString*)title Description:(NSString*)desc{
    if(_cross.title!=title){
        //title_be_edit=YES;
    }
    _cross.title=title;
    _cross.cross_description=desc;
    [self saveCrossUpdate];
    [self fillTitle:_cross];
    [self fillDescription:_cross];
    [self relayoutUI];
}

- (void)submitEditCross:(Cross*)cross_diff{
    //    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    hud.labelText = @"Saving";
    //    hud.mode=MBProgressHUDModeCustomView;
    //    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    //    [bigspin startAnimating];
    //    hud.customView=bigspin;
    //    [bigspin release];
    
    _cross.by_identity=[self getMyInvitation].identity;
    
    NSError *error;
//RESTKIT0.2  
//    NSString *json = [[RKObjectSerializer serializerWithObject:_cross mapping:[[APICrosses getCrossMapping]  inverseMapping]] serializedObjectForMIMEType:RKMIMETypeJSON error:&error];
//    if(!error){
//        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//        RKClient *client = [RKClient sharedClient];
//        [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//        NSString *endpoint = [NSString stringWithFormat:@"/crosses/%u/edit?token=%@",[_cross.cross_id intValue],app.accesstoken];
//        [client post:endpoint usingBlock:^(RKRequest *request){
//            request.method=RKRequestMethodPOST;
//            
//            request.params=[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
//            request.onDidLoadResponse=^(RKResponse *response){
//                if (response.statusCode == 200) {
//                    NSDictionary *body=[response.body objectFromJSONData];
//                    NSDictionary *meta=[body objectForKey:@"meta"];
//                    if([[meta objectForKey:@"code"] isKindOfClass:[NSNumber class]])
//                    {
//                        if([(NSNumber*)[meta objectForKey:@"code"] intValue]==200){
//                            NSDictionary *responsedict=[body objectForKey:@"response"];
//                            NSDictionary *crossdict=[responsedict objectForKey:@"cross" ];
//                            NSNumber *cross_id=[crossdict objectForKey:@"id"];
//                            if([cross_id intValue]==[self.cross.cross_id intValue])
//                            {
//                                [app CrossUpdateDidFinish:[_cross.cross_id intValue]];
//                            }
//                        }else{
//                            [Util showErrorWithMetaDict:meta delegate:self];
//                        }
//                    }
//                }else {
//                    NSString *errormsg=@"Could not save this cross.";
//                    if(![errormsg isEqualToString:@""]){
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
//                        alert.tag=201; // 201 = Save Cross
//                        [alert show];
//                        [alert release];
//                    }
//                }
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            };
//            request.onDidFailLoadWithError=^(NSError *error){
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//                NSString *errormsg=@"";
//                if(error.code==2)
//                    errormsg=@"A connection failure has occurred.";
//                else
//                    errormsg=@"Could not connect to the server.";
//                if(![errormsg isEqualToString:@""]){
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
//                    alert.tag=201; // 201 = Save Cross
//                    [alert show];
//                    [alert release];
//                }
//                
//                //                [Util showConnectError:error delegate:self];
//            };
//            request.delegate=self;
//        }];
//    }
}

- (void)saveCrossUpdate{
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving";
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    
    _cross.by_identity=[self getMyInvitation].identity;
    //RESTKIT0.2
//    NSError *error;
//    NSString *json = [[RKObjectSerializer serializerWithObject:_cross mapping:[[APICrosses getCrossMapping]  inverseMapping]] serializedObjectForMIMEType:RKMIMETypeJSON error:&error];
//    if(!error){
//        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//        RKClient *client = [RKClient sharedClient];
//        [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//        NSString *endpoint = [NSString stringWithFormat:@"/crosses/%u/edit?token=%@",[_cross.cross_id intValue],app.accesstoken];
//        [client post:endpoint usingBlock:^(RKRequest *request){
//            request.method=RKRequestMethodPOST;
//            
//            request.params=[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
//            request.onDidLoadResponse=^(RKResponse *response){
//                if (response.statusCode == 200) {
//                    NSDictionary *body=[response.body objectFromJSONData];
//                    NSDictionary *meta=[body objectForKey:@"meta"];
//                    if([[meta objectForKey:@"code"] isKindOfClass:[NSNumber class]])
//                    {
//                        if([(NSNumber*)[meta objectForKey:@"code"] intValue]==200){
//                            NSDictionary *responsedict=[body objectForKey:@"response"];
//                            NSDictionary *crossdict=[responsedict objectForKey:@"cross" ];
//                            NSNumber *cross_id=[crossdict objectForKey:@"id"];
//                            if([cross_id intValue]==[self.cross.cross_id intValue])
//                            {
//                                [app CrossUpdateDidFinish:[_cross.cross_id intValue]];
//                            }
//                        }else{
//                            [Util showErrorWithMetaDict:meta delegate:self];
//                        }
//                    }
//                }else {
//                    NSString *errormsg=@"Could not save this cross.";
//                    if(![errormsg isEqualToString:@""]){
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
//                        alert.tag=201; // 201 = Save Cross
//                        [alert show];
//                        [alert release];
//                    }
//                }
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//            };
//            request.onDidFailLoadWithError=^(NSError *error){
//                [MBProgressHUD hideHUDForView:self.view animated:YES];
//                NSString *errormsg=@"";
//                if(error.code==2)
//                    errormsg=@"A connection failure has occurred.";
//                else
//                    errormsg=@"Could not connect to the server.";
//                if(![errormsg isEqualToString:@""]){
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
//                    alert.tag=201; // 201 = Save Cross
//                    [alert show];
//                    [alert release];
//                }
//                
//                //                [Util showConnectError:error delegate:self];
//            };
//            request.delegate=self;
//        }];
//    }
}

#pragma mark UIAlertView methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag 101: save cross
    //tag 102: save exfee
    if(buttonIndex==0)//cancel
    {
        if(alertView.tag==201){
          RKObjectManager *objectManager = [RKObjectManager sharedManager];
          [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
//            [[Cross currentContext] rollback];
            [self fillTime:_cross.time];
            [self fillPlace:_cross.place];
            [self relayoutUI];
            
            //            [self setTime:cross.time];
            //            [self setPlace:cross.place];
            //            crosstitle.text=cross.title;
            //            crossdescription.text=cross.cross_description;
        }else if(alertView.tag==202){
            //            [[Exfee currentContext] rollback];
            //            [[Cross currentContext] rollback];
            //            [self reloadExfeeIdentities];
        }else if(alertView.tag==403){ //privacy control
          RKObjectManager *objectManager = [RKObjectManager sharedManager];
          [objectManager.managedObjectStore.mainQueueManagedObjectContext deleteObject:self.cross];
          [objectManager.managedObjectStore.mainQueueManagedObjectContext save:nil];
//            [[Cross currentContext] deleteObject:self.cross];
//            [[Cross currentContext] save:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else if(buttonIndex==1) //retry
    {
        if(alertView.tag==201){
            [self saveCrossUpdate];
        }else if(alertView.tag==202){
            //            [self saveExfeeUpdate];
        }
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hidePopupIfShown];
    
    CGPoint offset = scrollView.contentOffset;
    if (mapView.hidden == NO) {
        CGSize size = scrollView.contentSize;
        if (size.height - offset.y <= CGRectGetHeight(scrollView.bounds) + 5) {
            mapView.scrollEnabled = YES;
        }else{
            mapView.scrollEnabled = NO;
        }
    }
    
    if (offset.y < 0) {
        headerShadow.hidden = YES;
    }else{
        if (headerShadow.hidden == YES) {
            headerShadow.hidden = NO;
        }
    }
}

#pragma mark EXTabWidgetDelegate
- (void)widgetClick:(id)tab withButton:(id)widget{
    [self switchWidget:widget];
}

- (void)updateLayout:(id)sender animationWithParam:(NSDictionary*)param{
    // @"width"
    // @"animationTime"
    NSString *w = [param objectForKey:@"width"];
    CGFloat width = [w floatValue];
    NSString *t = [param objectForKey:@"animationTime"];
    NSTimeInterval time = [t doubleValue];
    
    CGPoint p = head_bg_point;
    CGPoint c = tabLayer.curveCenter;
    float offset = 0;
    if (_headerStyle == kHeaderStyleHalf) {
        offset = 44;
    }
    
    [self moveLayer:tabLayer.mask to:CGPointMake(p.x - c.x + width, p.y - offset) duration:time];
}


@end
