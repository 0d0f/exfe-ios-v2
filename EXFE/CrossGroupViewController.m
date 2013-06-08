//
//  CrossGroupViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import "CrossGroupViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/BlocksKit.h>
#import "Util.h"
#import "ImgCache.h"
#import "EXLabel.h"
#import "EXRSVPStatusView.h"
#import "MapPin.h"
#import "Cross.h"
#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import "Place+Helper.h"
#import "CrossTime+Helper.h"
#import "EFTime+Helper.h"
#import "TitleDescEditViewController.h"
#import "TimeViewController.h"
#import "PlaceViewController.h"
#import "WidgetConvViewController.h"
#import "WidgetExfeeViewController.h"
#import "NSString+EXFE.h"
#import "EFAPI.h"

#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (16)
#define SMALL_SLOT                       (5)
#define ADDITIONAL_SLOT                  (8)

#define DECTOR_HEIGHT                    (80)
#define DECTOR_HEIGHT_EXTRA              (20)
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
@end

@interface CrossGroupViewController (Private)
- (void)_showMenu:(UIView *)view from:(UIView *)sender animated:(BOOL)animated;
- (void)_dismissMenu:(UIView *)view animated:(BOOL)animated;
@end

@implementation CrossGroupViewController
@synthesize cross = _cross;
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

#pragma mark - ViewController life cycle & callbacks

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:@"WIDGET_CROSS"];
    // Do any additional setup after loading the view from its nib.
    CGRect b = self.view.bounds;
    CGRect a = [UIScreen mainScreen].applicationFrame;
//    CGRect b = self.initFrame;
    
    CGRect viewFrame = (CGRect){{0.0f, 0.0f}, {CGRectGetWidth(b), CGRectGetHeight(a) - DECTOR_HEIGHT}};
    self.view.frame = viewFrame;
    
    CGFloat head_bg_img_scale = CGRectGetWidth(self.view.bounds) / HEADER_BACKGROUND_WIDTH;
    head_bg_img_startY = 0 - HEADER_BACKGROUND_Y_OFFSET * head_bg_img_scale;
    
    container = [[UIScrollView alloc] initWithFrame:viewFrame];
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
    
    UITapGestureRecognizer *mapTap = [UITapGestureRecognizer recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint point) {
        [self hidePopupIfShown];
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        
        NSInteger tagId = mapView.superview.tag;
        if (tagId == kViewTagContainer) {
            CGRect f2 = [rootView convertRect:mapView.frame fromView:mapView.superview];
            [mapView removeFromSuperview];
            mapView.frame = f2;
            savedFrame = mapView.frame;
            savedScrollEnable = mapView.scrollEnabled;
            mapView.scrollEnabled = YES;
            [rootView addSubview:mapView];
            
            container.scrollEnabled = NO;
            [UIView animateWithDuration:0.233f animations:^{
                mapView.frame = rootView.bounds;
            }];
        } else {
            [UIView animateWithDuration:0.233f animations:^{
                mapView.frame = savedFrame;
            } completion:^(BOOL finished){
                mapView.scrollEnabled = savedScrollEnable;
                [mapView removeFromSuperview];
                [mapShadow.superview insertSubview:mapView belowSubview:mapShadow];
                [self setLayoutDirty];
                [self relayoutUI];
                container.scrollEnabled = YES;
            }];
            
            
        }
    }];
    mapTap.delegate = self;
    [mapView addGestureRecognizer:mapTap];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [container addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightRecognizer];
    
    
    swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // fill data & relayout
    
    [self refreshUI];
    
    switch (_widgetId) {
        case kWidgetConversation:
        {
            NSArray *controllers = [self.tabBarViewController viewControllersForClass:[WidgetConvViewController class]];
            
            NSAssert(controllers.count, @"Should contain a WidgetExfeeViewController");
            
            WidgetConvViewController *exfeeViewController = controllers[0];
            NSUInteger index = [self.tabBarViewController.viewControllers indexOfObject:exfeeViewController];
            [self.tabBarViewController.tabBar setSelectedIndex:index];
            [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1.0f];
        }
            break;
        case kWidgetExfee:
        {
            NSArray *controllers = [self.tabBarViewController viewControllersForClass:[WidgetExfeeViewController class]];
            
            NSAssert(controllers.count, @"Should contain a WidgetExfeeViewController");
            
            WidgetExfeeViewController *exfeeViewController = controllers[0];
            NSUInteger index = [self.tabBarViewController.viewControllers indexOfObject:exfeeViewController];
            [self.tabBarViewController.tabBar setSelectedIndex:index];
            [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1.0f];
        }
            break;
        case kWidgetCross:
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *updated_at = _cross.updated_at;
    [[EFAPIServer sharedInstance] loadCrossWithCrossId:[_cross.cross_id intValue]
                                           updatedtime:updated_at
                                               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                   if ([[mappingResult dictionary] isKindOfClass:[NSDictionary class]]) {
                                                       Meta* meta = (Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                                                       if ([meta.code intValue] == 403){
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                           alert.tag = 403;
                                                           [alert show];
                                                           [alert release];
                                                       } else if([meta.code intValue] == 200) {
                                                           [self refreshUI];
                                                       }
                                                   }
                                               }
                                               failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                   
                                               }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hidePopupIfShown];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [_shadowImage release];
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

    self.sortedInvitations = nil;
    
    [swipeRightRecognizer release];
    [swipeLeftRecognizer release];

    [super dealloc];
}

#pragma mark - Setter && Getter

- (void)setCross:(Cross *)cross {
    if (cross == _cross)
        return;
    
    if (_cross) {
        [_cross removeObserver:self
                    forKeyPath:@"conversation_count"];
        [_cross release];
        _cross = nil;
    }
    
    if (cross) {
        _cross = [cross retain];
        
        // kvo
        [cross addObserver:self
                forKeyPath:@"conversation_count"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.cross) {
        if ([keyPath isEqualToString:@"conversation_count"]) {
            NSArray *viewControllers = [self.tabBarViewController viewControllersForClass:NSClassFromString(@"WidgetConvViewController")];
            NSAssert(viewControllers != nil && viewControllers.count, @"viewControllers 不应该为 nil 或 空");
            
            WidgetConvViewController *conversationViewController = viewControllers[0];
            
            NSUInteger count = [self.cross.conversation_count unsignedIntegerValue];
            if (count) {
                conversationViewController.customTabBarItem.title = [NSString stringWithFormat:@"%u", count];
            } else {
                conversationViewController.customTabBarItem.title = nil;
            }
        }
    }
}

#pragma mark - Update UI Views

- (void)refreshUI {
    [self fillCross:self.cross];
}

- (void)fillCross:(Cross*)x {
    if (x != nil) {
        [self fillDescription:x];
        [self fillExfee:x.exfee];
        [self fillTime:x.time];
        [self fillPlace:x.place];
        [self fillConversationCount:x.conversation_count];
    }
    
    [self relayoutUI];
}

- (void)fillDescription:(Cross*)x {
    if (x.cross_description == nil || x.cross_description.length == 0){
        descView.hidden = YES;
        descView.text = @"";
        [self setLayoutDirty];
    } else {
        descView.text = x.cross_description;
        descView.hidden = NO;
        [self setLayoutDirty];
    }
}

- (void)fillExfee:(Exfee*)exfee {
    self.sortedInvitations = [exfee getSortedInvitations:kInvitationSortTypeMeAcceptNoNotifications];
    [exfeeShowview reloadData];
}

- (void)fillTime:(CrossTime*)time {
    if (time != nil) {
        NSString *title = [[time getTimeTitle] sentenceCapitalizedString];
        [title retain];
        if (title == nil || title.length == 0) {
            timeRelView.text = @"Sometime";
            timeAbsView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
            timeAbsView.text = @"Pick a time";
            timeAbsView.hidden = NO;
            timeZoneView.text = @"";
            timeZoneView.hidden = YES;
        } else {
            timeRelView.text = title;
            
            timeAbsView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
            NSString *desc = [[time getTimeDescription] sentenceCapitalizedString];
            [desc retain];
            if (desc != nil && desc.length > 0) {
                timeAbsView.text = desc;
                timeAbsView.hidden = NO;
                [timeAbsView sizeToFit];
                
                NSString* tz = [time getTimeZoneLine];
                [tz retain];
                if (tz != nil && tz.length > 0) {
                    timeZoneView.hidden = NO;
                    timeZoneView.text = [NSString stringWithFormat:@"(%@)", tz];
                    [timeZoneView sizeToFit];
                } else {
                    timeZoneView.hidden = YES;
                    timeZoneView.text = @"";
                }
                [tz release];
                
            } else {
                timeAbsView.text = @"";
                timeAbsView.hidden = YES;
                timeZoneView.hidden = YES;
                timeZoneView.text = @"";
            }
            [desc release];
        }
        [title release];
    } else {
        timeRelView.text = @"Sometime";
        timeAbsView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
        timeAbsView.text = @"Pick a time";
        timeAbsView.hidden = NO;
        timeZoneView.text = @"";
        timeZoneView.hidden = YES;
    }
    
    [self setLayoutDirty];
}

- (void)fillPlace:(Place*)place {
    if (place == nil || [place isEmpty]) {
        placeTitleView.text = @"Somewhere";
        placeDescView.textColor = [UIColor COLOR_WA(0xB2, 0xFF)];
        placeDescView.text = @"Choose a place";
        placeDescView.hidden = NO;
        mapView.hidden = YES;
        [self setLayoutDirty];
    } else {
        placeDescView.textColor = [UIColor COLOR_WA(0x33, 0xFF)];
        if ([place hasTitle]) {
            placeTitleView.text = place.title;
            
            if ([place hasDescription]) {
                placeDescView.text = place.place_description;
                placeDescView.hidden = NO;
                [placeDescView sizeToFit];
            } else {
                placeDescView.text = @"";
                placeDescView.hidden = YES;
            }
        } else {
            placeTitleView.text = @"Somewhere";
            placeDescView.hidden = YES;
            //mapView.hidden = YES;
        }
        
        if ([place hasGeo]) {
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
        } else {
            mapView.showsUserLocation = NO;
            mapView.hidden = YES;
        }
        [self setLayoutDirty];
    }
}

- (void)fillConversationCount:(NSNumber*)count {
//    if ([count intValue] > 0){
//        widgetTabBar.contents = [NSArray arrayWithObjects:@"", [count stringValue], nil];
//        tabBar.contents = [NSArray arrayWithObjects:@"", [count stringValue], nil];
//    }else{
//        widgetTabBar.contents = nil;
//        tabBar.contents = nil;
//    }
}

#pragma mark - Relayout methods

- (void)relayoutUI {
    [self relayoutUIwithAnimation:NO];
}

- (void)relayoutUIwithAnimation:(BOOL)animated {
    if (layoutDirty) {
        CGRect c = container.frame;
        
        float left = CONTAINER_VERTICAL_PADDING;
        float width = c.size.width - CONTAINER_VERTICAL_PADDING * 2;
        
        float baseX = CONTAINER_VERTICAL_PADDING;
        float baseY = CONTAINER_TOP_PADDING;
        
        // Description
        if (descView.hidden == NO) {
            CGSize size = [descView sizeThatFits:CGSizeMake(width, INFINITY)];
            //descView.frame = CGRectMake(left , baseY, descView.frame.size.width, descView.frame.size.height);
            
//            [UIView setAnimationsEnabled:animated];
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDuration:0.233];
            
            [UIView animateWithDuration:0.233f
                             animations:^{
                                 CGRect newRect = CGRectMake(left , baseY, width, size.height);
                                 descView.center = CGPointMake(CGRectGetMidX(newRect), CGRectGetMidY(newRect));
                                 descView.bounds = CGRectMake(0 , 0, width, size.height);
                             }
                             completion:^(BOOL finished){
                                 [UIView setAnimationsEnabled:YES];
                             }];
            
            baseX = left + size.width;
            baseY = baseY + size.height;
        }
        
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.233];
        }
        // Exfee
        if (exfeeShowview.hidden == NO) {
            if (descView.hidden == NO) {
                baseY += DESC_BOTTOM_MARGIN;
            }
            exfeeShowview.frame = CGRectMake(CGRectGetMinX(c)+10, baseY - EXFEE_OVERLAP, CGRectGetWidth(c)-20, exfeeSuggestHeight + EXFEE_OVERLAP);
            baseX = CGRectGetMaxX(exfeeShowview.frame);
            baseY = CGRectGetMaxY(exfeeShowview.frame);
        }
        
        // Time
        if (timeRelView.hidden == NO) {
            baseY += EXFEE_BOTTOM_MARGIN;
            CGSize timeRelSize = [timeRelView.text sizeWithFont:timeRelView.font];
            timeRelView.frame = CGRectMake(left, baseY, timeRelSize.width, timeRelSize.height);
            if (timeRelView.hidden == NO) {
                baseX = CGRectGetMinX(timeRelView.frame);
                baseY = CGRectGetMaxY(timeRelView.frame);
            }
            
            if (timeAbsView.hidden == NO) {
                baseY += TIME_RELATIVE_BOTTOM_MARGIN;
            }else{
                baseY += ADDITIONAL_SLOT;
            }
            CGSize timeAbsSize = [timeAbsView.text sizeWithFont:timeAbsView.font];
            timeAbsView.frame = CGRectMake(left, baseY, timeAbsSize.width, timeAbsSize.height);
            
            if (timeZoneView.hidden == NO) {
                CGSize timeZoneSize = CGSizeZero;
                timeZoneSize = [timeZoneView.text sizeWithFont:timeZoneView.font];
                if (baseX + timeZoneSize.width <= width){
                    baseX = CGRectGetMaxX(timeAbsView.frame) + TIME_ABSOLUTE_RIGHT_MARGIN;
                    baseY = CGRectGetMinY(timeAbsView.frame);
                    timeZoneView.frame = CGRectMake(baseX, baseY, timeZoneSize.width, timeZoneSize.height);
                    baseX = CGRectGetMinX(timeAbsView.frame);
                    baseY = CGRectGetMaxY(timeAbsView.frame);
                } else {
                    baseX = CGRectGetMinX(timeAbsView.frame);
                    baseY = CGRectGetMaxY(timeAbsView.frame) + SMALL_SLOT;
                    timeZoneView.frame = CGRectMake(baseX, baseY, timeZoneSize.width, timeZoneSize.height);
                    baseX = CGRectGetMinX(timeZoneView.frame);
                    baseY = CGRectGetMaxY(timeZoneView.frame);
                }
            } else if (timeAbsView.hidden == NO){
                baseY = CGRectGetMaxY(timeAbsView.frame);
            }
        }
        
        //Place
        if (placeTitleView.hidden == NO) {
            baseY += TIME_BOTTOM_MARGIN;
            CGSize placeTitleSize = [placeTitleView.text sizeWithFont:placeTitleView.font forWidth:placeTitleView.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
            placeTitleView.frame = CGRectMake(baseX, baseY, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , placeTitleSize.height);
            baseX = CGRectGetMinX(placeTitleView.frame);
            baseY = CGRectGetMaxY(placeTitleView.frame);
        }
        
        if (placeTitleView.hidden == NO && placeDescView.hidden == NO) {
            baseY += PLACE_TITLE_BOTTOM_MARGIN;
        }
        
        if (placeDescView.hidden == NO) {
            CGSize constraintSize;
            constraintSize.width = width;
            constraintSize.height = MAXFLOAT;
            CGSize placeDescSize = [placeDescView.text sizeWithFont:placeDescView.font constrainedToSize:constraintSize lineBreakMode:placeDescView.lineBreakMode];
            CGFloat ph = placeDescSize.height;
            if (ph < PLACE_DESC_MIN_HEIGHT) {
                ph = PLACE_DESC_MIN_HEIGHT;
            } else if (ph > PLACE_DESC_MAX_HEIGHT) {
                ph = PLACE_DESC_MAX_HEIGHT;
            }
            placeDescView.frame = CGRectMake(baseX, baseY, width, ph);
        } else {
            placeDescView.frame = CGRectMake(baseX, baseY, 0, ADDITIONAL_SLOT);
        }
        
        // Map
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) - DECTOR_HEIGHT;
        int b = (CGRectGetMaxY(placeDescView.frame) - CGRectGetMinY(placeTitleView.frame) + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + OVERLAP + 8 /*+ SMALL_SLOT */);
        mapView.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width , a - b);
        mapShadow.frame = CGRectMake(0, CGRectGetMaxY(placeDescView.frame) + PLACE_DESC_BOTTOM_MARGIN, c.size.width , 4);
        mapShadow.hidden = mapView.hidden;
        
        CGSize s = container.contentSize;
        if (mapView.hidden) {
            s.height = CGRectGetMaxY(placeDescView.frame);
        } else {
            s.height = CGRectGetMaxY(mapView.frame);
        }
        container.contentSize = s;
        
        if (animated) {
            [UIView commitAnimations];
        }
        [self clearLayoutDirty];
    }
}

- (void)setLayoutDirty {
    layoutDirty = YES;
}

- (void)clearLayoutDirty {
    layoutDirty = NO;
}

#pragma mark - Others

- (void)showDescriptionFullContent:(BOOL)needfull {
    if (needfull) {
        if (descView.numberOfLines != 0){
            descView.numberOfLines = 0;
            [self setLayoutDirty];
        }
    } else {
        if (descView.numberOfLines == 0) {
            descView.numberOfLines = 4;
            [self setLayoutDirty];
        }
    }
    
    [self relayoutUIwithAnimation:YES];
}

#pragma mark - EXRSVPStatusViewDelegate methods

- (void)RSVPStatusView:(EXRSVPStatusView *)view clickfor:(Invitation *)invitation {
    view.hidden = YES;
    NSArray *controllers = [self.tabBarViewController viewControllersForClass:[WidgetExfeeViewController class]];
    
    NSAssert(controllers.count, @"Should contain a WidgetExfeeViewController");
    
    WidgetExfeeViewController *exfeeViewController = controllers[0];
    exfeeViewController.selected_invitation = invitation;
    NSUInteger index = [self.tabBarViewController.viewControllers indexOfObject:exfeeViewController];
    [self.tabBarViewController.tabBar setSelectedIndex:index];
    [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1.0f];
}

#pragma mark - EXImagesCollectionView Datasource methods

- (NSInteger)numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [self.sortedInvitations count];
}

- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView itemAtIndex:(int)index {
    Invitation *invitation = [self.sortedInvitations objectAtIndex:index];
    EXInvitationItem *item = [[EXInvitationItem alloc] initWithInvitation:invitation];
    item.isMe = [[User getDefaultUser] isMe:invitation.identity];
    
    [[ImgCache sharedManager] fillAvatarWith:invitation.identity.avatar_filename
                                   byDefault:[UIImage imageNamed:@"portrait_default.png"]
                                       using:^(UIImage *image) {
                                           item.avatar = image;
                                           [item setNeedsDisplay];
                                      }];
    
    return [item autorelease];
}

- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView shouldResizeHeightTo:(float)height {
    if (height > 0) {
        exfeeSuggestHeight = height;
    }
    
    [self setLayoutDirty];
    [self relayoutUI];
}

#pragma mark - EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if (index < [self.sortedInvitations count]) {
        Invitation *invitation = [self.sortedInvitations objectAtIndex:index];
        CGPoint location = CGPointMake(CGRectGetMinX(exfeeShowview.frame) + (col + 1) * (50 + 5 * 2) + 5, CGRectGetMinY(exfeeShowview.frame) + row * (50 + 5 * 2) + y_start_offset);
        CGPoint newLocation = [rootView convertPoint:location fromView:exfeeShowview.superview];
        
        int x = newLocation.x;
        int y = newLocation.y;
        
        if(x + 180 > self.view.frame.size.width){
            x = x - 180;
        }
        if (rsvpstatusview == nil) {
            rsvpstatusview = [[EXRSVPStatusView alloc] initWithFrame:CGRectMake(x, y - 55, 180+12, 56)];
            rsvpstatusview.delegate = self;
            rsvpstatusview.hidden = YES;
            [rootView addSubview:rsvpstatusview];
        }
        rsvpstatusview.invitation = invitation;
        
        float avatar_center = rect.origin.x + rect.size.width / 2;
        int rsvpstatus_x = avatar_center - rsvpstatusview.frame.size.width /2;
        
        if (rsvpstatus_x < 0) {
            rsvpstatus_x = 0;
        }
        
        if (rsvpstatus_x + rsvpstatusview.frame.size.width > self.view.frame.size.width) {
            rsvpstatus_x = self.view.frame.size.width - rsvpstatusview.frame.size.width;
        }
        
        if ([[User getDefaultUser] isMe:invitation.identity]) {
            NSInteger ctrlId = popupCtrolId;
            [self hidePopupIfShown:kPopupTypeEditStatus];
            if (ctrlId != kPopupTypeEditStatus) {
                [self showMenu:invitation items:[NSArray arrayWithObjects:@"I'm in", @"Unavailable", nil]];
            }
        } else {
            rsvpstatusview.hidden = NO;
            
            [rsvpstatusview setFrame:CGRectMake(rsvpstatus_x, y-rsvpstatusview.frame.size.height, rsvpstatusview.frame.size.width, rsvpstatusview.frame.size.height)];
            
            rsvpstatus_x -= rsvpstatusview.frame.origin.x;
            
            CGFloat translationY = y - rsvpstatusview.frame.size.height - rsvpstatusview.frame.origin.y + 7;
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
            moveAnimation.duration = 0.233f;
            moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            moveAnimation.fromValue = [NSNumber numberWithDouble:y - rsvpstatusview.frame.size.height + 30 - rsvpstatusview.frame.origin.y];
            moveAnimation.toValue = [NSNumber numberWithDouble:translationY];
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.fillMode = kCAFillModeForwards;
            
            [[rsvpstatusview layer] addAnimation:moveAnimation forKey:@"moveAnimation"];
            
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.duration = 0.233f;
            scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            scaleAnimation.fromValue = [NSNumber numberWithDouble:0.1f];
            scaleAnimation.toValue = [NSNumber numberWithDouble:1.0f];
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeForwards;
            
            [[rsvpstatusview layer] addAnimation:scaleAnimation forKey:@"scaleAnimation"];
            
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.duration= 0.3;
            opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            opacityAnimation.fromValue =[NSNumber numberWithDouble:0.0f];
            opacityAnimation.toValue =[NSNumber numberWithDouble:1.0f];
            opacityAnimation.removedOnCompletion = NO;
            opacityAnimation.fillMode = kCAFillModeForwards;
            
            [[rsvpstatusview layer] addAnimation:opacityAnimation forKey:@"opacityAnimation"];
            
            [rsvpstatusview setNeedsDisplay];
            [self hidePopupIfShown:kPopupTypeVewStatus];
        }
    }
}

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)map didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated {
    
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id < MKAnnotation >)annotation {
    MKAnnotationView *pinView = nil;
    if (annotation != nil) {
        if ([annotation class] == MKUserLocation.class) {
            return nil;
        }
        
        static NSString *defaultPinID = @"com.exfe.pin";
        pinView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        
        if (pinView == nil) {
            pinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"map_pin_blue.png"];
            
            UIButton *btnNav = [UIButton buttonWithType:UIButtonTypeCustom];
            btnNav.frame = CGRectMake(0, 0, 30, 30);
            [btnNav setImage:[UIImage imageNamed:@"navi_btn.png"] forState:UIControlStateNormal];
            pinView.rightCalloutAccessoryView = btnNav;
        } else {
            pinView.annotation = annotation;
        }
    }
    return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id<MKAnnotation> annotation = view.annotation;
    //NSString *title = annotation.title;
    CLLocationDegrees latitude = annotation.coordinate.latitude;
    CLLocationDegrees longitude = annotation.coordinate.longitude;
    //int zoom = 13;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        //using iOS6 native maps app
        //first create latitude longitude object
        CLLocationCoordinate2D coordinate = annotation.coordinate; //CLLocationCoordinate2DMake(latitude,longitude);
        
        //create MKMapItem out of coordinates
        MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *destination =  [[MKMapItem alloc] initWithPlacemark:placeMark];
        //        // Open in own app
        //        [destination openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        // Open in map app
        [MKMapItem openMapsWithItems:[NSArray arrayWithObject:destination] launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
        [destination release];
        [placeMark release];
    } else{
        
        //using iOS 5 which has the Google Maps application
        NSString *mapurl = [NSString stringWithFormat: @"maps://maps?saddr=Current+Location&daddr=Destination@%f,%f", latitude, longitude];
        // hide saddr=My+Location for web
        NSString *mapurl4google = [NSString stringWithFormat: @"http://maps.google.com/maps?daddr=Destination@%f,%f", latitude, longitude];
        //        //add place title
        //        // title need encoding: invalide char->%xx & space->+
        //        // also change maps.google.com to maps.apple.com
        //        NSString *t = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        //        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?daddr=%@@%f,%f", t, latitude, longitude];
        
        NSURL *url = [NSURL URLWithString:mapurl];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            url = [NSURL URLWithString:mapurl4google];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark － TODO gesture handler

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint center = gestureRecognizer.view.center;
    
    if (ABS(location.x - center.x) < 30 && ABS(location.y - center.y) < 30) {
        return NO;
    }
    
    return YES;
}

- (void)hidePopupIfShown {
    [self hidePopupIfShown:0];
}

- (void)hidePopupIfShown:(NSInteger)skipId {
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

- (void)showPopup:(NSInteger)ctrlId {
    if (ctrlId == 0 ) {
        [self hidePopupIfShown];
        return;
    }
    
    if (ctrlId != popupCtrolId) {
        NSInteger low = ctrlId & MASK_LOW_BITS;
        [self hidePopupIfShown:ctrlId];
        switch (low) {
            case kPopupTypeEditTitle & MASK_LOW_BITS:
                [self showTtitleAndDescEditMenu:self.tabBarViewController.tabBar.titleLabel];
                break;
            case kPopupTypeEditDescription & MASK_LOW_BITS:
                [self showTtitleAndDescEditMenu:descView];
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

- (void)handleSwipe:(UISwipeGestureRecognizer*)sender {
    CGPoint location = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint locInContainer = [container convertPoint:location fromView:self.view];
        
        [self hidePopupIfShown];
        if (descView.hidden == NO && CGRectContainsPoint([Util expandRect:descView.frame], locInContainer)) {
            [self showTimeEditMenu:descView];
            [self clickforTitleAndDescEdit:descView];
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

- (void)handleTap:(UITapGestureRecognizer*)sender {
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

- (void)clickforTitleAndDescEdit:(id)sender {
    [self showTitleAndDescView];
    [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1];
    // title & desc need the current popupctrlid info to determing the focus. keep the sequence.
}

- (void)clickforTimeEdit:(id)sender {
    [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1];
    [self showTimeView];
}

- (void)clickforPlaceEdit:(id)sender {
    [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1];
    [self showPlaceView:@"search"];
}

- (void)clickforMenuEdit:(id)sender {
    UIView *v = sender;
    switch (v.tag) {
        case kViewTagTitle & kViewTagMaskLayerTwo:
        case kViewTagDescription & kViewTagMaskLayerTwo:
            [self showTitleAndDescView];
            [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1];
            break;
        case kViewTagTimeTitle & kViewTagMaskLayerTwo:
            [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1];
            [self showTimeView];
            break;
        case kViewTagPlaceTitle & kViewTagMaskLayerTwo:
            [self performSelector:@selector(hidePopupIfShown) withObject:nil afterDelay:1];
            [self showPlaceView:@"search"];
            break;
        default:
            break;
    }
}

#pragma mark - Edit Menu API

- (void)showTtitleAndDescEditMenu:(UIView *)sender {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
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
        [rootView addSubview:titleAndDescEditMenu];
    }
    
    [self _showMenu:titleAndDescEditMenu from:sender animated:YES];
}

- (void)hideTitleAndDescEditMenuWithAnimation:(BOOL)animated {
    [self _dismissMenu:titleAndDescEditMenu animated:animated];
}

- (void)showTimeEditMenu:(UIView*)sender {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
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
        [rootView addSubview:timeEditMenu];
    }
    
    [self _showMenu:timeEditMenu from:sender animated:YES];
}

- (void)hideTimeEditMenuWithAnimation:(BOOL)animated {
    [self _dismissMenu:timeEditMenu animated:animated];
}

- (void)showPlaceEditMenu:(UIView*)sender {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
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
        [rootView addSubview:placeEditMenu];
    }

    // show animation
    [self _showMenu:placeEditMenu from:sender animated:YES];
}

- (void)hidePlaceEditMenuWithAnimation:(BOOL)animated {
    [self _dismissMenu:placeEditMenu animated:animated];
    
}

- (void)showMenu:(Invitation*)_invitation items:(NSArray*)itemslist {
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if (rsvpmenu == nil) {
        rsvpmenu = [[EXRSVPMenuView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, exfeeShowview.frame.origin.y-20, 125, 20+[itemslist count]*44) withDelegate:self items:itemslist showTitleBar:YES];
        [rootView addSubview:rsvpmenu];
    }
    
    CGPoint newLocation = [rootView convertPoint:exfeeShowview.frame.origin fromView:exfeeShowview.superview];
    [rsvpmenu setFrame:CGRectMake(CGRectGetWidth(rsvpmenu.superview.bounds), newLocation.y - 20, 125, 20+[itemslist count]*44)];
    
    rsvpmenu.invitation = _invitation;
    rsvpmenu.hidden = NO;
    
    [self _showMenu:rsvpmenu from:nil animated:YES];
}

- (void)hideMenuWithAnimation:(BOOL)animated{
    [self _dismissMenu:rsvpmenu animated:animated];
}

- (void)hideStatusView{
    if(rsvpstatusview != nil && rsvpstatusview.hidden == NO){
        [rsvpstatusview setHidden:YES];
    }
}

#pragma mark - RSVP Action Handler

- (void)RSVPAcceptedMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"ACCEPTED" invitation:menu.invitation];
    [self hidePopupIfShown];
}

- (void)RSVPUnavailableMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"DECLINED" invitation:menu.invitation];
    [self hidePopupIfShown];
}

- (void)RSVPPendingMenuView:(EXRSVPMenuView *) menu{
    [self sendrsvp:@"INTERESTED" invitation:menu.invitation];
    [self hidePopupIfShown];
}

#pragma mark - Show Edit View Controller

- (void)showTitleAndDescView {
    TitleDescEditViewController *titleViewController = [[TitleDescEditViewController alloc] initWithNibName:@"TitleDescEditViewController" bundle:nil];
    titleViewController.delegate = self;
    NSString *imgurl = nil;
    for (NSDictionary *widget in (NSArray*)_cross.widget) {
        if ([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
            break;
        }
    }
    titleViewController.imgurl = imgurl;
    titleViewController.editFieldHint = popupCtrolId & MASK_LOW_BITS;
    [self.tabBarViewController presentViewController:titleViewController
                                            animated:YES
                                          completion:nil];
    [titleViewController setCrossTitle:_cross.title desc:_cross.cross_description];
    [titleViewController release];
}

- (void)showTimeView {
    TimeViewController *timeViewController = [[TimeViewController alloc] initWithNibName:@"TimeViewController" bundle:nil];
    timeViewController.delegate = self;
    [timeViewController setDateTime:_cross.time];
    [self.tabBarViewController presentViewController:timeViewController
                                            animated:YES
                                          completion:nil];
    [timeViewController release];
}

- (void)showPlaceView:(NSString*)status {
    PlaceViewController *placeViewController = [[PlaceViewController alloc]initWithNibName:@"PlaceViewController" bundle:nil];
    placeViewController.delegate = self;
    
    if (_cross.place != nil) {
        if(![_cross.place isEmpty]){
            placeViewController.selecetedPlace = _cross.place;
        } else {
            placeViewController.isaddnew = YES;
            placeViewController.showtableview = YES;
            status=@"search";
        }
    } else {
        placeViewController.isaddnew=YES;
    }
    
    if ([status isEqualToString:@"detail"]) {
        placeViewController.showdetailview = YES;
    } else if([status isEqualToString:@"search"]) {
        placeViewController.showtableview = YES;
    }
    
    [self.tabBarViewController presentViewController:placeViewController
                                            animated:YES
                                          completion:nil];
    [placeViewController release];
}

#pragma mark - API request for modification.
- (void)sendrsvp:(NSString*)status invitation:(Invitation*)_invitation {
    Identity *myidentity = [_cross.exfee getMyInvitation].identity;
    
    [[EFAPIServer sharedInstance] submitRsvp:status
                                          on:_invitation
                                  myIdentity:[myidentity.identity_id intValue]
                                     onExfee:[_cross.exfee.exfee_id intValue]
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         if ([operation.response statusCode] == 200 && [responseObject isKindOfClass:[NSDictionary class]]) {
                                             if([responseObject isKindOfClass:[NSDictionary class]]) {
                                                 NSDictionary* meta=(NSDictionary*)[responseObject objectForKey:@"meta"];
                                                 if ([[meta objectForKey:@"code"] intValue] == 403) {
                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Control" message:@"You have no access to this private ·X·." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                     alert.tag = 403;
                                                     [alert show];
                                                     [alert release];
                                                 } else if ([[meta objectForKey:@"code"] intValue] == 200) {
                                                     [[EFAPIServer sharedInstance] loadCrossWithCrossId:[_cross.cross_id intValue]
                                                                                            updatedtime:@""
                                                                                                success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                                                                    if ([[mappingResult dictionary] isKindOfClass:[NSDictionary class]]) {
                                                                                                        Meta *meta = (Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                                                                                                        if ([meta.code intValue]==200) {
                                                                                                            [self refreshUI];
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                                failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                                                                }];
                                                     
                                                     [self refreshUI];
                                                 }
                                                 
                                             }
                                         }
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [Util showConnectError:error delegate:self]; 
                                     }];
}

#pragma mark - EditCrossDelegate

- (void)addExfee:(NSArray *)invitations {
    [_cross.exfee addInvitations:[NSSet setWithArray:invitations]];
    //[self saveCrossUpdate];
    [self fillExfee:_cross.exfee];
}

- (void)setTime:(CrossTime *)time {
    _cross.time = time;
    [self saveCrossUpdate];
    [self fillTime:time];
    [self relayoutUI];
}

- (void)setPlace:(Place*)place {
    _cross.place = place;
    [self saveCrossUpdate];
    [self fillPlace:place];
    [self relayoutUI];
}

- (void)setTitle:(NSString*)title Description:(NSString*)desc {
    if (_cross.title != title) {
        //title_be_edit=YES;
    }
    _cross.title = title;
    _cross.cross_description = desc;
    
    // walkaround.
    // we should use notification to update title.
    if ([self.parentViewController isKindOfClass:[EFTabBarViewController class]]) {
        EFTabBarViewController *vc = (EFTabBarViewController *)self.parentViewController;
        vc.tabBar.titleLabel.text = title;
    }

    [self saveCrossUpdate];
    [self fillDescription:_cross];
    [self relayoutUI];
}

- (void)saveCrossUpdate {
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving";
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    
    _cross.by_identity=[_cross.exfee getMyInvitation].identity;
    [[EFAPIServer sharedInstance] editCross:_cross
                                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                        if (operation.HTTPRequestOperation.response.statusCode == 200) {
                                            if([[mappingResult dictionary] isKindOfClass:[NSDictionary class]]) {
                                                Meta *meta = (Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
                                                
                                                if ([meta.code intValue] == 200) {
                                                    Cross *responsecross = [[mappingResult dictionary] objectForKey:@"response.cross"];
                                                    if ([responsecross.cross_id intValue] == [self.cross.cross_id intValue]) {
                                                        [app crossUpdateDidFinish:[responsecross.cross_id intValue]];
                                                    }
                                                } else {
                                                    [Util showErrorWithMetaObject:meta delegate:self];
                                                }
                                            }
                                        } else {
                                            NSString *errormsg = @"Could not save this cross.";
                                            if (![errormsg isEqualToString:@""]) {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
                                                alert.tag = 201; // 201 = Save Cross
                                                [alert show];
                                                [alert release];
                                            }
                                        }
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    }
                                    failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                        
                                    }];
}

#pragma mark - UIAlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //tag 101: save cross
    //tag 102: save exfee
    switch (alertView.tag) {
        case 201:{
            if (buttonIndex == alertView.cancelButtonIndex) {
                RKObjectManager *objectManager = [RKObjectManager sharedManager];
                [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                //            [[Cross currentContext] rollback];
                [self fillTime:_cross.time];
                [self fillPlace:_cross.place];
                [self relayoutUI];
            } else if (buttonIndex == alertView.firstOtherButtonIndex){
                [self saveCrossUpdate];
            }
        }
            break;
        case 202:{
            if (buttonIndex == alertView.cancelButtonIndex) {
                //            [self setTime:cross.time];
                //            [self setPlace:cross.place];
                //            crosstitle.text=cross.title;
                //            crossdescription.text=cross.cross_description;
            } else if (buttonIndex == alertView.firstOtherButtonIndex){
                //            [self saveExfeeUpdate];
            }
        }
            break;
        case 403:{
            if (buttonIndex == alertView.cancelButtonIndex) {
                // remove self from local storage
                if (self.cross) {
                    [[self.cross managedObjectContext] deleteObject:self.cross];
                }
                // exit current page
                [self.navigationController popToRootViewControllerAnimated:YES];
                // notify the list to reload from local
                [NSNotificationCenter.defaultCenter postNotificationName:EXCrossListDidChangeNotification object:self];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hidePopupIfShown];
    
    CGPoint offset = scrollView.contentOffset;
    if (mapView.hidden == NO) {
        CGSize size = scrollView.contentSize;
        if (size.height - offset.y <= CGRectGetHeight(scrollView.bounds) + 5) {
            mapView.scrollEnabled = YES;
        } else {
            mapView.scrollEnabled = NO;
        }
    }
}

#pragma mark - Private

- (void)_showMenu:(UIView *)view from:(UIView *)sender animated:(BOOL)animated {
    if ([view.layer animationForKey:@"show"])
        return;
    
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    
    if (sender) {
        CGPoint newLocation = [rootView convertPoint:sender.frame.origin fromView:sender.superview];
        CGRect original = CGRectMake(CGRectGetWidth(self.view.frame), newLocation.y + SMALL_SLOT, 50, 44);
        view.frame = original;
    }
    
    view.hidden = NO;
    
    // show animation
    CATransform3D newTransform = CATransform3DMakeTranslation(2.0f - CGRectGetWidth(view.frame), 0.0f, 0.0f);
    
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.233f;
        animation.fromValue = [view.layer valueForKey:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:newTransform];
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [view.layer addAnimation:animation forKey:@"show"];
    }
    
    view.layer.transform = newTransform;
}

- (void)_dismissMenu:(UIView *)view animated:(BOOL)animated {
    if ([view.layer animationForKey:@"hide"])
        return;
    
    CATransform3D newTransform = CATransform3DIdentity;
    
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.duration = 0.233f;
        animation.fromValue = [view.layer valueForKey:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:newTransform];
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        [view.layer addAnimation:animation forKey:@"hide"];
    }
    
    view.layer.transform = newTransform;
}

@end
