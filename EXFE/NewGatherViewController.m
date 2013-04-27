//
//  NewGatherViewController.m
//  EXFE
//
//  Created by huoju on 1/4/13.
//
//

#import "NewGatherViewController.h"
#import "Util.h"
#import "ImgCache.h"
#import "MapPin.h"
#import "Place+Helper.h"
#import "CrossTime+Helper.h"
#import "EFTime+Helper.h"
#import "NSString+EXFE.h"
#import "EFChoosePeopleViewController.h"
#import "MBProgressHUD.h"
#import "EXSpinView.h"


#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (16)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (80)
#define DECTOR_HEIGHT_EXTRA              (20)
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


@interface NewGatherViewController ()

@end

@implementation NewGatherViewController
@synthesize cross = _cross;
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
    CGRect a = [UIScreen mainScreen].applicationFrame;
    self.view.frame = a;
    //CGRect f = self.view.frame;
    CGRect b = self.view.bounds;
    CGRect c = CGRectMake(0, CONTAINER_TOP_MARGIN, CGRectGetWidth(a), CGRectGetHeight(a) - CONTAINER_TOP_MARGIN);
    container = [[UIScrollView alloc] initWithFrame:c];
    container.delegate=self;
    {
        int left = CONTAINER_VERTICAL_PADDING;
        descView = [[EXLabel alloc] initWithFrame:CGRectMake(left, CONTAINER_TOP_PADDING, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, 44)];
        descView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
        descView.numberOfLines = 4;
        descView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        descView.shadowColor = [UIColor whiteColor];
        descView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        descView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
        descView.lineBreakMode = NSLineBreakByWordWrapping;
        descView.placeholder = @"Take some notes";
        descView.placehlderColor = [UIColor COLOR_WA(0xA3, 0xFF)];
        descView.text = @"";
        descView.minimumHeight = 44;
        [container addSubview:descView];
        
        exfeeSuggestHeight = 70;
        exfeeShowview = [[EXImagesCollectionGatherView alloc]initWithFrame:CGRectMake(c.origin.x+10, CGRectGetMaxY(descView.frame) + DESC_BOTTOM_MARGIN - EXFEE_OVERLAP, c.size.width-20, exfeeSuggestHeight + EXFEE_OVERLAP)];
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
        [container addSubview:timeRelView];
        
        timeAbsView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeRelView.frame.origin.y + timeRelView.frame.size.height + TIME_RELATIVE_BOTTOM_MARGIN, c.size.width /2 -  CONTAINER_VERTICAL_PADDING, TIME_ABSOLUTE_HEIGHT)];
        timeAbsView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        timeAbsView.shadowColor = [UIColor whiteColor];
        timeAbsView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        timeAbsView.backgroundColor = [UIColor clearColor];
        
        [container addSubview:timeAbsView];
        
        timeZoneView= [[UILabel alloc] initWithFrame:CGRectMake(left + timeAbsView.frame.size.width + TIME_ABSOLUTE_RIGHT_MARGIN, timeAbsView.frame.origin.y, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 - timeAbsView.frame.size.width  - TIME_ABSOLUTE_RIGHT_MARGIN , TIME_ZONE_HEIGHT)];
        timeZoneView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        timeZoneView.backgroundColor = [UIColor clearColor];
        [container addSubview:timeZoneView];
        
        placeTitleView= [[UILabel alloc] initWithFrame:CGRectMake(left, timeAbsView.frame.origin.y + timeAbsView.frame.size.height + TIME_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_TITLE_HEIGHT)];
        placeTitleView.textColor = [UIColor COLOR_RGB(0x3A, 0x6E, 0xA5)];
        placeTitleView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21];
        placeTitleView.shadowColor = [UIColor whiteColor];
        placeTitleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        placeTitleView.numberOfLines = 2;
        placeTitleView.backgroundColor = [UIColor clearColor];
        [container addSubview:placeTitleView];
        
        placeDescView= [[UILabel alloc] initWithFrame:CGRectMake(left, placeTitleView.frame.origin.y + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_DESC_HEIGHT)];
        placeDescView.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
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
        mapView.scrollEnabled = NO;
        mapView.delegate = self;
        [container addSubview:mapView];
        mapShadow = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(mapView.frame), CGRectGetMinY(mapView.frame), CGRectGetWidth(mapView.frame), 4)];
        [mapShadow setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"shadow_4.png"]]];
        [container addSubview:mapShadow];
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = container.frame.origin.y + placeDescView.frame.origin.y + placeDescView.frame.size.height;
        }else{
            s.height = container.frame.origin.y + mapView.frame.origin.y + mapView.frame.size.height;
        }
        container.contentSize = s;
        
    }
    container.backgroundColor = [UIColor COLOR_SNOW];
    [self.view addSubview:container];
    
    headview = [[EXCurveView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA) withCurveFrame:CGRectMake(CGRectGetWidth(b) - 122,  DECTOR_HEIGHT, 122, DECTOR_HEIGHT_EXTRA) ];
    headview.backgroundColor=[UIColor grayColor];
    {
        CGFloat scale = CGRectGetWidth(headview.bounds) / 880.0f;
        CGFloat startY = 0 - 198 * scale;
        dectorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, startY, 880 * scale, 495 * scale)];
        dectorView.image=[UIImage imageNamed:@"x_titlebg_default.jpg"];
        [headview addSubview:dectorView];
        
        UIView* dectorMask = [[UIView alloc] initWithFrame:headview.bounds];
        dectorMask.backgroundColor = [UIColor COLOR_WA(0x00, 0x55)];
        [headview addSubview:dectorMask];
        [dectorMask release];
        
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(20 + TITLE_HORIZON_MARGIN, TITLE_VERTICAL_MARGIN, CGRectGetWidth(b) - 20 - TITLE_HORIZON_MARGIN * 2, DECTOR_HEIGHT - TITLE_VERTICAL_MARGIN * 2)];
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
    UIImageView *headerShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x_shadow.png"]];
    headerShadow.frame = CGRectMake(0, DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA - 25, 320 * 2, 30);
    [self.view addSubview:headerShadow];
    [headerShadow release];
    
    [self.view addSubview:headview];
    
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, DECTOR_HEIGHT / 2 - 44 /2, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(Close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    UIView *pannel=[[UIView alloc] initWithFrame:CGRectMake(0,screenframe.size.height-44-20, self.view.frame.size.width, 44)];
    UIImageView *pannelbackimg=[[UIImageView alloc] initWithFrame:CGRectMake(0,0, pannel.frame.size.width, 44)];
    pannelbackimg.image=[UIImage imageNamed:@"glassbar.png"];
    [pannel addSubview:pannelbackimg];
    [pannelbackimg release];
    
//    [pannel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.33]];

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

    pannellight=[[UIImageView alloc] initWithFrame:CGRectMake(0,screenframe.size.height-44-20, self.view.frame.size.width, 46)];
    pannellight.image=[UIImage imageNamed:@"glassbar_light.png"];
    [self.view addSubview:pannellight];
    [self GlassBarlightAnimation];
    identitypicker=[[UIPickerView alloc] initWithFrame:CGRectMake(0, screenframe.size.height-216-[UIApplication sharedApplication].statusBarFrame.size.height, self.view.frame.size.width, 216)];
    identitypicker.dataSource=self;
    identitypicker.delegate=self;
    identitypicker.showsSelectionIndicator = YES;
    [identitypicker setHidden:YES];
    
    [self.view addSubview:identitypicker];
    
    pickertoolbar = [[UIView alloc] initWithFrame:CGRectMake(0, screenframe.size.height-216-[UIApplication sharedApplication].statusBarFrame.size.height-44, self.view.frame.size.width, 44)];
    [pickertoolbar setBackgroundColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:0.96]];
    pickertoolbar.tag=1200;

    UIButton *pickdone=[UIButton buttonWithType:UIButtonTypeCustom];
    [pickdone setFrame:CGRectMake(265, 7, 50, 30)];
    [pickdone setTitle:@"Done" forState:UIControlStateNormal];
    [pickdone.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [pickdone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pickdone.titleLabel.shadowColor=[UIColor blackColor];
    pickdone.titleLabel.shadowOffset=CGSizeMake(0, 1);
    
    [pickdone setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)] forState:UIControlStateNormal];
    [pickdone addTarget:self action:@selector(pickdone) forControlEvents:UIControlEventTouchUpInside];
    [pickertoolbar addSubview:pickdone];

    UILabel *pickerlabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 140, 23)];
    pickerlabel.text=@"Host as identity:";
    pickerlabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    pickerlabel.textColor=[UIColor whiteColor];
    pickerlabel.backgroundColor=[UIColor clearColor];
    [pickertoolbar addSubview:pickerlabel];
    [pickerlabel release];
    
    [self.view addSubview:pickertoolbar];
    [pickertoolbar release];
    [pickertoolbar setHidden:YES];
    
}

- (void) GlassBarlightAnimation{

    CABasicAnimation *opacityAnimation_out = [CABasicAnimation animationWithKeyPath:
                                          @"opacity"];
    opacityAnimation_out.duration= 2;
    opacityAnimation_out.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    opacityAnimation_out.fromValue =[NSNumber numberWithInt:1];
    opacityAnimation_out.toValue =[NSNumber numberWithInt:0];
    opacityAnimation_out.removedOnCompletion = NO;
    opacityAnimation_out.fillMode = kCAFillModeForwards;

    CABasicAnimation *opacityAnimation_in = [CABasicAnimation animationWithKeyPath:
                                          @"opacity"];
    opacityAnimation_in.duration= 2;
    opacityAnimation_in.beginTime=2;
    opacityAnimation_in.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    opacityAnimation_in.fromValue =[NSNumber numberWithInt:0];
    opacityAnimation_in.toValue =[NSNumber numberWithInt:1];
    opacityAnimation_in.removedOnCompletion = NO;
    opacityAnimation_in.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations=[NSArray arrayWithObjects:opacityAnimation_out,opacityAnimation_in, nil];
    group.duration=4;
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    group.repeatCount=FLT_MAX;
                      
    [[pannellight layer] addAnimation:group forKey:@"opacityAnimation"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"ENTER_GATHER"];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self initUI];
    [self refreshUI];
    [exfeeShowview reloadData];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    gestureRecognizer.delegate=self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [gestureRecognizer release];
  
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideMenu];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO; 
    }
    return YES;
}

- (void) initData{
    title_be_edit = NO;
    myIdentities = [[NSArray alloc] initWithArray:[[User getDefaultUser] sortedIdentiesById]];
    Identity *default_identity = [myIdentities objectAtIndex:0];
    
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    if (self.cross == nil) {
        NSEntityDescription *crossEntity = [NSEntityDescription entityForName:@"Cross" inManagedObjectContext:context];
        self.cross = [[Cross alloc] initWithEntity:crossEntity insertIntoManagedObjectContext:context];
    }
    
    NSArray *cross_default_backgrounds=[[NSUserDefaults standardUserDefaults] objectForKey:@"cross_default_backgrounds"];
    NSString *default_background=@"";
    if(cross_default_backgrounds!=nil && [cross_default_backgrounds count]>0){
        int idx=arc4random()%[cross_default_backgrounds count];
        default_background=[cross_default_backgrounds objectAtIndex:idx];
    }
    NSMutableDictionary *widget=[NSMutableDictionary dictionaryWithObjectsAndKeys:default_background,@"image",@"Background",@"type", nil];
    if (self.cross.widget == nil) {
        self.cross.widget = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    }
    [_cross.widget addObject:widget];
    
    
    self.cross.title=[NSString stringWithFormat:@"·X· %@",default_identity.name];
    self.cross.cross_description = @"";
    
    if (self.cross.exfee == nil) {
        NSEntityDescription *exfeeEntity = [NSEntityDescription entityForName:@"Exfee" inManagedObjectContext:context];
        self.cross.exfee =[[[Exfee alloc] initWithEntity:exfeeEntity insertIntoManagedObjectContext:context] autorelease];
    }
    self.cross.exfee.invitations = [[[NSMutableSet alloc] initWithCapacity:12] autorelease];
    [self.cross.exfee addDefaultInvitationBy:default_identity];
    
    self.sortedInvitations = [self.cross.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
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
    [myIdentities release];
    [titleView release];
    
    [_sortedInvitations release];
    [super dealloc];
}

- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];

//    if (descView.hidden == NO && CGRectContainsPoint(descView.frame, location)) {
//        [self showDescriptionFullContent: (descView.numberOfLines != 0)];
//        return;
//    }
    if ((CGRectContainsPoint([identitypicker frame], location) && identitypicker.hidden==NO )|| (CGRectContainsPoint([pickertoolbar frame], location) && pickertoolbar.hidden==NO)){
        return;
    }
    else{
        [identitypicker setHidden:YES];
        [pickertoolbar setHidden:YES];
    }

    CGPoint containerLocation = [container convertPoint:location fromView:sender.view];
    if (CGRectContainsPoint([titleView frame], location) || CGRectContainsPoint([descView frame], containerLocation)){
        NSInteger editHint = 2;
        if (CGRectContainsPoint([titleView frame], location) ) {
            editHint = 1;
        }
        
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
        titleViewController.editFieldHint = editHint;
        [self presentModalViewController:titleViewController animated:YES];
        [titleViewController setCrossTitle:_cross.title desc:_cross.cross_description];
        [titleViewController release];
    }

    if (CGRectContainsPoint([timeRelView frame], containerLocation) || CGRectContainsPoint([timeAbsView frame], containerLocation)|| CGRectContainsPoint([timeZoneView frame], containerLocation))
    {
        TimeViewController *timeViewController=[[TimeViewController alloc] initWithNibName:@"TimeViewController" bundle:nil];
        timeViewController.delegate=self;
        [timeViewController setDateTime:_cross.time];
        [self presentModalViewController:timeViewController animated:YES];
        [timeViewController release];
    }
    if (CGRectContainsPoint([placeTitleView frame], containerLocation) || CGRectContainsPoint([placeDescView frame], location))
    {
        [self ShowPlaceView:@"search"];
    }
    if (CGRectContainsPoint([exfeeShowview frame], containerLocation)) {
        //        [crosstitle resignFirstResponder];
        [exfeeShowview becomeFirstResponder];
        CGPoint exfeeviewlocation = [sender locationInView:exfeeShowview];
        [exfeeShowview onImageTouch:exfeeviewlocation];
    }else{
        [self hideMenu];
        [self hideStatusView];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Close:(UIButton*)sender{
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    if(self.cross){
        if(self.cross.time.begin_at){
            [context deleteObject:self.cross.time.begin_at];
        }
        if(self.cross.time){
            [context deleteObject:self.cross.time];
        }
        if(self.cross.exfee){
            for (Invitation *invitation in self.sortedInvitations){
                [objectManager.managedObjectStore.mainQueueManagedObjectContext deleteObject:invitation];
                [objectManager.managedObjectStore.mainQueueManagedObjectContext save:nil];
            }
            [context deleteObject:self.cross.exfee];
        }
        [context deleteObject:self.cross];
        [context save:nil];
    }
    [objectManager.operationQueue cancelAllOperations];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) reFormatTitle{
    NSString *newtitle = @"·X· ";
    if(title_be_edit == NO){
        int count = 0;
        for(Invitation *invitation in self.sortedInvitations){
            if(count == 3){
                break;
            }
            if(count < 3 && count >= 1){
                newtitle = [newtitle stringByAppendingString:@", "];
            }
            newtitle = [newtitle stringByAppendingFormat:@"%@", invitation.identity.name];
            count++;
        }
        _cross.title = newtitle;
        titleView.text = newtitle;
    }
}

- (void) setTitle:(NSString*)title Description:(NSString*)desc{
    if(_cross.title!=title)
        title_be_edit=YES;
    _cross.title=title;
    _cross.cross_description=desc;
    [self fillTitleAndDescription:_cross];
    [self relayoutUI];
}

- (IBAction) Gather:(id) sender{
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    hud.labelText = @"Loading";
  
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    
    _cross.by_identity = [myIdentities objectAtIndex:0];
    if(_cross.time == nil){
      NSEntityDescription *crosstimeEntity = [NSEntityDescription entityForName:@"CrossTime" inManagedObjectContext:context];
      _cross.time = [[[CrossTime alloc] initWithEntity:crosstimeEntity insertIntoManagedObjectContext:context] autorelease];
      NSEntityDescription *eftimeEntity = [NSEntityDescription entityForName:@"EFTime" inManagedObjectContext:context];
      _cross.time.begin_at = [[[EFTime alloc] initWithEntity:eftimeEntity insertIntoManagedObjectContext:context] autorelease];
      _cross.time.begin_at.timezone = [DateTimeUtil timezoneString:[NSTimeZone localTimeZone]];
    }
    [Flurry logEvent:@"GATHER_SEND"];
    [APICrosses GatherCross:_cross
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [app GatherCrossDidFinish];
                    }
                    failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    }];
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

#pragma mark Refresh UI content methods
- (void)refreshUI{
    [self fillCross:self.cross];
}

- (void)fillCross:(Cross*) x{
    if (x != nil){
        [self fillTitleAndDescription:x];
        [self fillBackground:x.widget];
        [self fillExfee:x.exfee];
        [self fillTime:x.time];
        [self fillPlace:x.place];
    }
    [self relayoutUI];
}

- (void) fillTitleAndDescription:(Cross*)x{
    [titleView setText:x.title];
    [self setLayoutDirty];
    
    descView.text = x.cross_description;
    [self setLayoutDirty];
    
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
                        dectorView.image = [UIImage imageNamed:@"x_titlebg_default.jpg"];
                        UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(backimg!=nil && ![backimg isEqual:[NSNull null]]){
                                if(dectorView.image!=nil){
                                    CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                                    fadeoutAnimation.fillMode = kCAFillModeForwards;
                                    fadeoutAnimation.duration=0.5;
                                    fadeoutAnimation.removedOnCompletion =NO;
                                    fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
                                    fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
                                    [dectorView.layer addAnimation:fadeoutAnimation forKey:@"fadeout"];
                                }
                                dectorView.image = backimg;
                                CABasicAnimation *fadeinAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                                fadeinAnimation.fillMode = kCAFillModeForwards;
                                fadeinAnimation.duration=0.5;
                                fadeinAnimation.removedOnCompletion =NO;
                                fadeinAnimation.fromValue=[NSNumber numberWithFloat:0.0];
                                fadeinAnimation.toValue=[NSNumber numberWithFloat:1.0];
                                [dectorView.layer addAnimation:fadeinAnimation forKey:@"fadein"];

                            }
                        });
                    });
                    dispatch_release(imgQueue);
                }else{
                    if(dectorView.image!=nil){
                        CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                        fadeoutAnimation.fillMode = kCAFillModeForwards;
                        fadeoutAnimation.duration=0.5;
                        fadeoutAnimation.removedOnCompletion =NO;
                        fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
                        fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
                        [dectorView.layer addAnimation:fadeoutAnimation forKey:@"fadeout"];
                    }
                    dectorView.image = backimg;
                    CABasicAnimation *fadeinAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
                    fadeinAnimation.fillMode = kCAFillModeForwards;
                    fadeinAnimation.duration=0.5;
                    fadeinAnimation.removedOnCompletion =NO;
                    fadeinAnimation.fromValue=[NSNumber numberWithFloat:0.0];
                    fadeinAnimation.toValue=[NSNumber numberWithFloat:1.0];
                    [dectorView.layer addAnimation:fadeinAnimation forKey:@"fadein"];

                }
                flag = YES;
                break;
            }
        }
    }
    if (flag == NO){
        dectorView.image = [UIImage imageNamed:@"x_titlebg_default.jpg"];
    }
}

- (void)fillExfee:(Exfee*)exfee{
    self.sortedInvitations = [exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
    [exfeeShowview reloadData];
}

- (void) setTime:(CrossTime*)time{
    _cross.time=time;
    [self fillTime:time];
    [self relayoutUI];
}

- (void) setPlace:(Place*)place{
    _cross.place=place;
    [self fillPlace:place];
    [self relayoutUI];
}

- (void)fillTime:(CrossTime*)time{
    if (time != nil){
        NSString *title = [[time getTimeTitle] sentenceCapitalizedString];
        [title retain];
        if (title == nil || title.length == 0) {
            timeRelView.text = @"Sometime";
            timeAbsView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
            timeAbsView.text = @"Pick a time";
            timeAbsView.hidden = NO;
            timeZoneView.text = @"";
            timeZoneView.hidden = YES;
        }else{
            timeRelView.text = title;//[title copy];
            
            timeAbsView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
            NSString* desc = [[time getTimeDescription] sentenceCapitalizedString];
            [desc retain];
            if(desc != nil && desc.length > 0){
                timeAbsView.text = desc;
                timeAbsView.hidden = NO;
                [timeAbsView sizeToFit];
                
                NSString* tz = [time getTimeZoneLine];
                [tz retain];
                if (tz != nil && tz.length > 0) {
                    timeZoneView.hidden = NO;
                    timeZoneView.text = tz;//[tz copy];
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
//            NSString *placeTitle = place.title;
//            if (placeTitle == nil || place.title.length == 0) {
//                placeTitle = @"Somewhere";
//            }
            MapPin *pin = [[[MapPin alloc] initWithCoordinates:region.center placeName:place.title description:@""] autorelease];
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
//        NSLog(@"relayoutUI");
        //CGRect f = self.view.frame;
        CGRect c = container.frame;
        
        float left = CONTAINER_VERTICAL_PADDING;
        float width = c.size.width - CONTAINER_VERTICAL_PADDING * 2;
        
        float baseX = CONTAINER_VERTICAL_PADDING;
        float baseY = CONTAINER_TOP_PADDING;
        
        // Description
        if (descView.hidden == NO) {
            descView.frame = CGRectMake(left , baseY, width, 88);
            [descView sizeToFit];
            baseX = CGRectGetMaxX(descView.frame);
            baseY = CGRectGetMaxY(descView.frame) ;
        }
        
        // Exfee
        if (exfeeShowview.hidden == NO){
            baseY += DESC_BOTTOM_MARGIN;
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
        int b = (CGRectGetMaxY(placeDescView.frame) - CGRectGetMinY(placeTitleView.frame) + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + container.frame.origin.y  + OVERLAP + 8/*+ SMALL_SLOT */);
        mapView.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b);
        mapShadow.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width , 4);
        mapShadow.hidden = mapView.hidden;
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = CGRectGetMinY(container.frame) + CGRectGetMaxY(placeDescView.frame);
        }else{
            s.height = CGRectGetMinY(container.frame) + CGRectGetMaxY(mapView.frame);
        }
        if (s.height < CGRectGetHeight(self.view.bounds)){
            s.height = CGRectGetHeight(self.view.bounds) + 1;
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
    return self.sortedInvitations.count;
}

- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView itemAtIndex:(int)index{
    Invitation *invitation =[self.sortedInvitations objectAtIndex:index];
    
    EXInvitationItem *item=[[[EXInvitationItem alloc] initWithInvitation:invitation] autorelease];
    item.backgroundColor=[UIColor clearColor];
    item.isGather=YES;
    item.isMe = [[User getDefaultUser] isMe:invitation.identity];
  
    Identity *identity = invitation.identity;
    
    [[ImgCache sharedManager] fillAvatarWith:identity.avatar_filename byDefault:[UIImage imageNamed:@"portrait_default.png"] using:^(UIImage *image) {
        item.avatar = image;
        [item setNeedsDisplay];
    }];
    return item;
}

- (void)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView shouldResizeHeightTo:(float)height{
    if (height > 0){
        exfeeSuggestHeight = height;
    }
    [self setLayoutDirty];
    [self relayoutUI];
    
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect {
    if (index == self.sortedInvitations.count) {
        [self hideMenu];
        
        EFChoosePeopleViewController *viewController = [[EFChoosePeopleViewController alloc] initWithNibName:@"EFChoosePeopleViewController"
                                                                                                      bundle:nil];
        viewController.completionHandler = ^(NSArray *identities){
            NSAssert(dispatch_get_main_queue() == dispatch_get_current_queue(), @"WTF! MUST on main queue! boy!");
            
            NSMutableSet *invitations = [[NSMutableSet alloc] init];
            for (NSArray *personIdentities in identities) {
                BOOL hasAddedNoresponse = NO;
                RKObjectManager *objectManager = [RKObjectManager sharedManager];
                NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
                
                for (Identity *identity in personIdentities) {
                    NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:context];
                    Invitation *invitation = [[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:context];
                    
                    if (!hasAddedNoresponse) {
                        hasAddedNoresponse = YES;
                        invitation.rsvp_status = @"NORESPONSE";
                    } else {
                        invitation.rsvp_status = @"NOTIFICATION";
                    }
                    
                    NSAssert(identity.managedObjectContext == invitation.managedObjectContext, @"WTF!!!");
                    
                    invitation.identity = identity;
                    Invitation *myinvitation = [self.cross.exfee getMyInvitation];
                    if (myinvitation != nil) {
                        invitation.updated_by = myinvitation.identity;
                    } else {
                        invitation.updated_by = [[[User getDefaultUser].identities allObjects] objectAtIndex:0];
                    }
                    
                    [invitations addObject:invitation];
                    [invitation release];
                }
            }
            
            [self.cross.exfee addInvitations:invitations];
            [invitations release];
            
            self.sortedInvitations = [self.cross.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
            [self reFormatTitle];
            [exfeeShowview reloadData];
            if ([self.sortedInvitations count] >= 12) { // TODO we want to move the hard limit to server result
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exfees Limit" message:[NSString stringWithFormat:@"This ·X· is limited to 12 participants."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        };
        [self presentViewController:viewController
                           animated:YES
                         completion:nil];
        [viewController release];
    } else if (index < self.sortedInvitations.count) {
        Invitation *invitation =[self.sortedInvitations objectAtIndex:index];
      
        if ([[User getDefaultUser] isMe:invitation.identity]) {
            [identitypicker setHidden:NO];
            [pickertoolbar setHidden:NO];
        } else {
            [self showMenu:invitation items:[NSArray arrayWithObjects:@"Delete", nil]];
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
        static NSString *defaultPinID = @"com.exfe.pin";
        pinView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ){
            pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
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
//    NSLog(@"Click on the annotation");
}

- (void)onClick:(id)sender{
//    NSLog(@"Click to Navigation");
}

- (void) showMenu:(Invitation*)_invitation items:(NSArray*)itemslist{
    if(rsvpmenu!=nil){
        [rsvpmenu removeFromSuperview];
        [rsvpmenu release];
    }
    BOOL showtitlebar=YES;
    float titlebarheight=20;
    if([itemslist count]==1){
        showtitlebar=NO;
        titlebarheight=0;
    }
    
    rsvpmenu=[[EXRSVPMenuView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, exfeeShowview.frame.origin.y, 125, 44*[itemslist count]+titlebarheight) withDelegate:self items:itemslist showTitleBar:showtitlebar];
    [self.view addSubview:rsvpmenu];
    rsvpmenu.invitation=_invitation;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width-125, exfeeShowview.frame.origin.y, 125, 44*[itemslist count]+titlebarheight)];
    
    [UIView commitAnimations];
    
}

- (void)hideMenu{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [rsvpmenu setFrame:CGRectMake(self.view.frame.size.width, rsvpmenu.frame.origin.y, self.view.frame.size.width, rsvpmenu.frame.size.height)];
    [UIView commitAnimations];
}

- (void)hideStatusView{
//    [rsvpstatusview setHidden:YES];
}

- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu{
    [self setrsvp:@"ACCEPTED" invitation:menu.invitation];
    [self hideMenu];
}

- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu{
    [self setrsvp:@"DECLINED" invitation:menu.invitation];
    [self hideMenu];
}

- (void)RSVPPendingMenuView:(EXRSVPMenuView *) menu{
    [self setrsvp:@"INTERESTED" invitation:menu.invitation];
    [self hideMenu];
}

- (void)RSVPRemoveMenuView:(EXRSVPMenuView *) menu{
    [self hideMenu];
    
    if ([self.cross.exfee hasInvitation:menu.invitation]) {
        [self.cross.exfee removeInvitationsObject:menu.invitation];
        self.sortedInvitations = [self.cross.exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
        [exfeeShowview reloadData];
        [self reFormatTitle];
        return;
    }
}

- (void) setrsvp:(NSString*)status invitation:(Invitation*)_invitation{
    for (Invitation *invitation in self.sortedInvitations) {
        if ([invitation.identity.identity_id isEqualToNumber:_invitation.identity.identity_id]) {
            invitation.rsvp_status = status;
            [exfeeShowview reloadData];
            return;
        }
    }
}

- (void) sendrsvp:(NSString*)status invitation:(Invitation*)_invitation{
  NSLog(@"send rsvp");
    //    NSError *error;
//    Identity *myidentity=[_cross.exfee getMyInvitation].identity;
//    NSDictionary *rsvpdict=[NSDictionary dictionaryWithObjectsAndKeys:_invitation.identity.identity_id,@"identity_id",myidentity.identity_id,@"by_identity_id",status,@"rsvp_status",@"rsvp",@"type", nil];
//RESTKIT0.2
//    RKParams* rsvpParams = [RKParams params];
//    [rsvpParams setValue:[NSString stringWithFormat:@"[%@]",[rsvpdict JSONString]] forParam:@"rsvp"];
//    RKClient *client = [RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//    NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/rsvp?token=%@",[cross.exfee.exfee_id intValue],app.accesstoken];
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
//                            [APICrosses LoadCrossWithCrossId:[cross.cross_id intValue] updatedtime:@"" delegate:self source:[NSDictionary dictionaryWithObjectsAndKeys:@"cross_reload",@"name",cross.cross_id,@"cross_id", nil]];
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
//        };
//    }];
  
}

#pragma mark RKObjectLoaderDelegate methods

//- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    if([objects count]>0)
//    {
//        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [app GatherCrossDidFinish];
//    }else{
////        NSLog(@"gather error");
//    }
//  
//}
//- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
//  [MBProgressHUD hideHUDForView:self.view animated:YES];
////    NSLog(@"%@",error);
//}

#pragma mark UIPickerviewDatasource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [[User getDefaultUser].identities count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 300;
    
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    NSString *username=((Identity*)[myIdentities objectAtIndex:row]).name;
    if(username ==nil)
      username=((Identity*)[myIdentities objectAtIndex:row]).external_username;
  
    NSString *provider=((Identity*)[myIdentities objectAtIndex:row]).provider;
    
    CGRect rowFrame = CGRectMake(0.0f, 0.0f, 300, 40);
    
    UIView *rowview=[[[UIView alloc] initWithFrame:rowFrame] autorelease];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(30, 0,300-30,40)];
    
    label.text=username;
    label.backgroundColor=[UIColor clearColor];
    
    rowview.backgroundColor=[UIColor clearColor];
    [rowview addSubview:label];
    [label release];
    
    NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",provider];
    UIImage *icon=[UIImage imageNamed:iconname];
    
    UIImageView *imgprovider=[[UIImageView alloc] initWithFrame:CGRectMake(6, (40-18)/2, icon.size.width, icon.size.height)];
    imgprovider.backgroundColor=[UIColor clearColor];
    imgprovider.image=icon;
    [rowview addSubview:imgprovider];
    [imgprovider release];
    return rowview;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//    NSLog(@"select %i",row);
}

- (void) pickdone{
    int idx=[identitypicker selectedRowInComponent:0];
    [[_cross.exfee getMyInvitation] replaceIdentity:[myIdentities objectAtIndex:idx]];
    [identitypicker setHidden:YES];
    [pickertoolbar setHidden:YES];
    [self reFormatTitle];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
#pragma mark motion shake event

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
        NSArray *cross_default_backgrounds=[[NSUserDefaults standardUserDefaults] objectForKey:@"cross_default_backgrounds"];
        NSString *default_background=@"";
        
        if(cross_default_backgrounds!=nil && [cross_default_backgrounds count]>0){
            int idx=arc4random()%[cross_default_backgrounds count];
            default_background=[cross_default_backgrounds objectAtIndex:idx];
        }
        
//        NSMutableDictionary *widget=[NSMutableDictionary dictionaryWithObjectsAndKeys:default_background,@"image",@"Background",@"type", nil];
        if(_cross.widget==nil)
            _cross.widget=[[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        else{
            for (int i=0;i<[_cross.widget count];i++){
                NSMutableDictionary *widget=[_cross.widget objectAtIndex:i];
                if([[widget objectForKey:@"type"] isEqualToString:@"Background"]){
                    [widget setObject:default_background forKey:@"image"];
                }
            }
        }
        [self fillBackground:_cross.widget];
    }

}

@end
