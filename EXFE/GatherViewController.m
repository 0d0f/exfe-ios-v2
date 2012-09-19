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
@synthesize exfeeIdentities;
@synthesize default_user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        viewmode=false;
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    if([cross.conversation_count intValue]>0 && [cross.conversation_count intValue]<=64){
        [ccbuttonText setText:[cross.conversation_count stringValue]];
    }
    else if([cross.conversation_count intValue]==0)
        [ccbuttonText setText:@""];
    [ccbuttonText setNeedsDisplay];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    
    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
    screenframe.size.height-=statusframe.size.height;
    [self.view setFrame:screenframe];

    firstLoad=YES;
    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]]];
    [self.view addSubview:toolbar];
    
    UIButton *closebutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [closebutton setFrame:CGRectMake(5, 7, 50, 30)];
    [closebutton setTitle:@"Close" forState:UIControlStateNormal];
    [closebutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [closebutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
    [closebutton setBackgroundImage:[[UIImage imageNamed:@"btn_dark.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];
    [closebutton addTarget:self action:@selector(Close:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:closebutton];

    UIButton *gatherbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    [gatherbutton setFrame:CGRectMake(toolbar.frame.size.width-5-50, 7, 50, 30)];
    [gatherbutton setTitle:@"Gather" forState:UIControlStateNormal];
    [gatherbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [gatherbutton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
    [gatherbutton setBackgroundImage:[[UIImage imageNamed:@"btn_blue_dark.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];

    [gatherbutton addTarget:self action:@selector(Gather:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:gatherbutton];
    
    if(viewmode==YES){
        [Flurry logEvent:@"VIEW_CROSS"];
        UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [homeButton setFrame:CGRectMake(0, 0, 55, 30)];
        [homeButton setTitle:@"Home  " forState:UIControlStateNormal];
        [homeButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
        [homeButton setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
        homeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [homeButton setBackgroundImage:[[UIImage imageNamed:@"btn_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 6)] forState:UIControlStateNormal];
        [homeButton addTarget:self action:@selector(toHome) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftbarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:homeButton];
        
        self.navigationItem.leftBarButtonItem = leftbarButtonItem;
        [leftbarButtonItem release];
    }else{
        [Flurry logEvent:@"GATHER_CROSS"];
    }
    [self buildView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusbarResize) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}
- (void) statusbarResize{
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
    screenframe.size.height-=statusframe.size.height;

    CGRect myrsvptoolbarframe=[myrsvptoolbar frame];
    myrsvptoolbarframe.origin.y=screenframe.size.height-44-50;
    [myrsvptoolbar setFrame:myrsvptoolbarframe];
    
    [rsvpbutton setFrame:CGRectMake(self.view.frame.size.width/2-30, screenframe.size.height-44-33, 60, 44)];
    
    CGRect gatherframe=[gathertoolbar frame];
    gatherframe.origin.y=screenframe.size.height-50;
    [gathertoolbar setFrame:gatherframe];
    
    CGRect rsvpframe=[rsvptoolbar frame];
    rsvpframe.origin.y=screenframe.size.height-44-50;
    [rsvptoolbar setFrame:rsvpframe];
}

-(void) toHome{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)buildView{
    [self.view setBackgroundColor:[UIColor grayColor]];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    float width=self.view.frame.size.width-VIEW_MARGIN*2;
    CGRect containviewframe=CGRectMake(0,toolbar.frame.size.height,self.view.frame.size.width, self.view.frame.size.height-44);

    if(viewmode==YES){
//        NSLog(@"%f",self.view.frame.origin.y);
//        NSLog(@"%f",toolbar.frame.size.height);
        containviewframe=CGRectMake(0,self.view.frame.origin.y,self.view.frame.size.width, self.view.frame.size.height-44);
    }
    
    containview=[[UIScrollView alloc] initWithFrame:containviewframe];
    [containview setDelegate:self];
    [self.view addSubview:containview];

    backgroundview=[[UIView alloc] initWithFrame:containview.frame];
    [backgroundview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cross_bg.png"]]];
    if(viewmode==YES)
        [containview addSubview:backgroundview];
    
    containcardview=[[EXOverlayView alloc] initWithFrame:CGRectMake(VIEW_MARGIN, 0, containview.frame.size.width-2*VIEW_MARGIN, containview.frame.size.height-6)];

    if(viewmode==YES)
        [containcardview setFrame:CGRectMake(0, 0, containview.frame.size.width, containview.frame.size.height)];
    containcardview.backgroundimage=[UIImage imageNamed:@"paper_texture.png"];
    containcardview.cornerRadius=5;
//    containcardview.backgroundColor=[UIColor blackColor];
    [containview addSubview:containcardview];

    title_input_img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gather_title_input_area.png"]];
    [title_input_img setFrame:CGRectMake(0, 0, containcardview.frame.size.width, 69)];
    [containcardview addSubview:title_input_img];

    crosstitle=[[UITextView alloc] initWithFrame:CGRectMake(40, 5,containcardview.frame.size.width-40, 48)];
    [crosstitle setReturnKeyType:UIReturnKeyDone];
    crosstitle.tag=101;
    crosstitle.delegate=self;

    [containcardview addSubview:crosstitle];
    crosstitle.text=[NSString stringWithFormat:@"Meet %@",app.username];
    [crosstitle setSelectedRange:NSMakeRange(0, [crosstitle.text length])];
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

    exfeenum=[[EXAttributedLabel alloc] initWithFrame:CGRectMake(VIEW_MARGIN, toolbar.frame.size.height+6+crosstitle.frame.size.height+15, width, 24)];
    [exfeenum setBackgroundColor:[UIColor clearColor]];
//    exfeenum.textAlignment=UITextAlignmentRight;
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
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(showPan)];
//    panGesture.delegate = self;
//    [map addGestureRecognizer:panGesture];
//    [panGesture release];
    
    mapbox=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_nil.png"]];
    [containcardview addSubview:mapbox];

    WildcardGestureRecognizer * tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    tapInterceptor.touchesEndCallback = ^(NSSet * touches, UIEvent * event) {
        [self ShowPlaceView:@"view"];
    };
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
//        [self ShowPlaceView:@"view"];
    };
//    tapInterceptor.touchesMoveCallback = ^(NSSet * touches, UIEvent * event) {
////        NSLog(@"move");
//        //        [self ShowPlaceView:@"view"];
//    };
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

    placetitle=[[UILabel alloc] initWithFrame:CGRectMake(INNER_MARGIN,toolbar.frame.size.height+6+crosstitle.frame.size.height+15+exfeenum.frame.size.height+8+exfeeShowview.frame.size.height+15+timetitle.frame.size.height+timedesc.frame.size.height+15,160,48)];
    placetitle.lineBreakMode=UILineBreakModeWordWrap;
    [placetitle setBackgroundColor:[UIColor clearColor]];
    placetitle.text=@"Somwhere";
    [placetitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    placetitle.textColor=[Util getHighlightColor];
    placetitle.numberOfLines=2;
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
//    crossdescription
//    Write some notes here.
    crossdescbackimg=[[UIView alloc] initWithFrame:CGRectMake(crossdescription.frame.origin.x, crossdescription.frame.origin.y, crossdescription.frame.size.width, 75)];
    crossdescbackimg.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"gather_describe_area.png"]];

    [containcardview addSubview:crossdescbackimg];
    [crossdescription setBackgroundColor:[UIColor clearColor]];
    [crossdescription setDelegate:self];
    crossdescription.text=@"Write some notes here.";
    [containcardview addSubview:crossdescription];

    if(viewmode==YES){
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        chatButton.frame = CGRectMake(0, 0, 30, 30);
        [chatButton setBackgroundImage:[[UIImage imageNamed:@"btn_dark.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];

        [chatButton addTarget:self action:@selector(toconversation) forControlEvents:UIControlEventTouchUpInside];

        if([cross.conversation_count intValue]>0 && [cross.conversation_count intValue]<=64){
            [chatButton setImage:[UIImage imageNamed:@"conv_navbarbtn.png"] forState:UIControlStateNormal];

            ccbuttonText=[[UILabel alloc]initWithFrame:CGRectMake(7, 3, 12, 22)];
            ccbuttonText.textAlignment=UITextAlignmentCenter;
            ccbuttonText.backgroundColor=[UIColor clearColor];
            [ccbuttonText setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:9]];
            ccbuttonText.textColor=[UIColor whiteColor];
            [chatButton addSubview:ccbuttonText];
        }else if([cross.conversation_count intValue]==0)
            [chatButton setImage:[UIImage imageNamed:@"conv_navbarbtn.png"] forState:UIControlStateNormal];
        else if([cross.conversation_count intValue]>64)
            [chatButton setImage:[UIImage imageNamed:@"conv_many_navbarbtn.png"] forState:UIControlStateNormal];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        self.navigationItem.rightBarButtonItem = barButtonItem;
        [barButtonItem release];
        ((ProfileBackgroundView*)(self.view)).hideGradient=YES;
    }
    
    [self initData];
    if(viewmode==NO){
    }

    [self reArrangeViews];
    [self setExfeeNum];
    
        if(viewmode==YES){
            for (UIGestureRecognizer *recognizer in crossdescription.gestureRecognizers) {
                if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
                    recognizer.enabled = NO;
                }
            }
        
        UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didlongpress:)];
        longpress.minimumPressDuration = 0.610;
        [containview addGestureRecognizer:longpress];
        [longpress release];
    }
    
    if(viewmode==YES){
        [self ShowRsvpButton];
        self.navigationItem.title=cross.title;
    }
}
//- (void)showPan
//{
//    NSLog(@"pan!");
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}
- (void) initData{

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    if(cross==nil)
        cross=[Cross object];
    if(users!=nil && [users count] >0)
    {
        default_user=[[users objectAtIndex:0] retain];
    }
    [users release];
    if(self.cross!=nil && viewmode==YES){
        crosstitle.text=cross.title;
        [self setExfeeNum];
        NSArray *widgets=cross.widget;
        for(NSDictionary *widget in widgets) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                NSString *imgurl=[Util getBackgroundLink:[widget objectForKey:@"image"]];
                UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, containview.frame.size.width, 180)];
                imageview.image=nil;
                
                UIImage *backimg=[[ImgCache sharedManager] getImgFromCache:imgurl];
                if(backimg==nil || [backimg isEqual:[NSNull null]]){
                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                    dispatch_async(imgQueue, ^{
                        UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(backimg!=nil && ![backimg isEqual:[NSNull null]])
                                imageview.image=backimg;
                        });
                    });
                    dispatch_release(imgQueue);
                }else
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
        [self setPlace:cross.place];
        
        crossdescription.text=cross.cross_description;
        [self reloadExfeeIdentities];
    }
    else if(viewmode==NO){
        exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
        exfeeSelected=[[NSMutableArray alloc] initWithCapacity:12];

        [self addDefaultIdentity];
    }

}
- (void) updateMapImage{
//    UIGraphicsBeginImageContextWithOptions(map.bounds.size, map.opaque, 0.0);
//    [map.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    mapbox.image=img;
//    [map setHidden:YES];
    
    UIGraphicsBeginImageContext(map.frame.size);
    [map.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    mapbox.image=viewImage;
    [map setHidden:YES];
    
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"regionDidChangeAnimated");
//    [self updateMapImage];
}
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView{
//    [self updateMapImage];
    NSLog(@"mapViewWillStartLoadingMap");
}
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
//    [self updateMapImage];
    NSLog(@"mapViewDidFinishLoadingMap");
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
    NSLog(@"mapViewDidFailLoadingMap");
}
- (void) reloadExfeeIdentities{
    if(exfeeIdentities!=nil){
        [exfeeIdentities release];
        exfeeIdentities=nil;
        [exfeeSelected release];
        exfeeSelected=nil;
    }
    exfeeIdentities=[[NSMutableArray alloc] initWithCapacity:12];
    exfeeSelected=[[NSMutableArray alloc] initWithCapacity:12];

    NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"invitation_id" ascending:YES];
    NSArray *invitations=[cross.exfee.invitations sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    for(Invitation *invitation in invitations) {
        if([invitation.host boolValue]==YES)
            [exfeeIdentities insertObject:invitation atIndex:0];
        else{
            [exfeeIdentities addObject:invitation];
        }
        [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
    }
    [exfeeShowview reloadData];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)aRange replacementText:(NSString*)aText
{
    if(textView.tag==101)
    {
        if ([aText isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            if(viewmode==YES){
                cross.title = crosstitle.text;
                crosstitle_view.text=crosstitle.text;
                [crosstitle setHidden:YES];
                [crosstitle_view setHidden:NO];
                [title_input_img setHidden:YES];
                [self saveCrossUpdate];
            }
        }
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
    [timetitle setFrame:CGRectMake(INNER_MARGIN, exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+15,timetitlesize.width,24)];
    
    CGSize timedescconstraint = CGSizeMake(160,timedesc.frame.size.height);
    CGSize timedescsize = [timedesc.text sizeWithFont:timedesc.font constrainedToSize:timedescconstraint lineBreakMode:UILineBreakModeWordWrap];
    [timedesc setFrame:CGRectMake(INNER_MARGIN,timetitle.frame.origin.y+timetitle.frame.size.height,timedescsize.width,18)];

    CGSize placetitleconstraint = CGSizeMake(160,48);
    CGSize placetitlesize = [placetitle.text sizeWithFont:placetitle.font constrainedToSize:placetitleconstraint lineBreakMode:UILineBreakModeTailTruncation];
    [placetitle setFrame:CGRectMake(INNER_MARGIN,timedesc.frame.origin.y+timedesc.frame.size.height+15,placetitlesize.width,placetitlesize.height)];
    
    CGSize placedescconstraint = CGSizeMake(containcardview.frame.size.width-INNER_MARGIN*2,400);
    CGSize placedescsize = [placedesc.text sizeWithFont:placedesc.font constrainedToSize:placedescconstraint lineBreakMode:UILineBreakModeWordWrap];
    [placedesc setFrame:CGRectMake(INNER_MARGIN,placetitle.frame.origin.y+placetitle.frame.size.height,placedescsize.width,placedescsize.height)];

    [map setFrame:CGRectMake(INNER_MARGIN+170+6,exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10+7,115,70)];
    [mapbox setFrame:CGRectMake(INNER_MARGIN+170,exfeeShowview.frame.origin.y+exfeeShowview.frame.size.height+10,126,84)];
    
    float height=crossdescription.contentSize.height;
    if(height<crossdescription.frame.size.height)
        height=crossdescription.frame.size.height;
    
    float crossdescriptionframeheight=crossdescription.frame.size.height;
    float crossdescriptoiny=placedesc.frame.origin.y+placedesc.frame.size.height+9+15;
    if(map.frame.origin.y+map.frame.size.height+9>placedesc.frame.origin.y+placedesc.frame.size.height+9)
        crossdescriptoiny=map.frame.origin.y+map.frame.size.height+9+15;
    
    height=containcardview.frame.size.height-crossdescriptoiny;

    [crossdescription setFrame:CGRectMake(0,crossdescriptoiny,containview.frame.size.width,height)];
    
    float offset=height-crossdescriptionframeheight;
    if(offset<0)
        offset=0;
    
    [containview setContentSize:CGSizeMake(containview.frame.size.width, containview.frame.size.height+offset)];

    [crossdescbackimg setFrame:CGRectMake(crossdescription.frame.origin.x, crossdescription.frame.origin.y-9, crossdescription.frame.size.width, 75)];

    containview.alwaysBounceVertical=YES;
    

    if(viewmode==YES){
        [containcardview setFrame:CGRectMake(containview.frame.origin.x, 0, containview.frame.size.width, containview.contentSize.height)];
        CGRect backgroundrect=backgroundview.frame;
        if(backgroundrect.origin.y>=0)
        {
            backgroundrect.origin.y=-72;
        }
        if(containview.contentSize.height>containview.frame.size.height)
            backgroundrect.size.height=containview.contentSize.height;
        backgroundrect.size.height=backgroundrect.size.height+72;
        [backgroundview setFrame:backgroundrect];
        [crosstitle resignFirstResponder];
        [toolbar setHidden:YES];
        [crosstitle setHidden:YES];
        [title_input_img setHidden:YES];
        [crosstitle_view setHidden:NO];
        crosstitle_view.text=crosstitle.text;
        [exfeenum setHidden:NO];
        
        containcardview.backgroundimage=nil;
        [crossdescription setEditable:NO];
//         exfeeedit
        if(exfeeShowview.editmode==NO)
            [exfeeShowview HiddenAddButton];
        else
            [exfeeShowview ShowAddButton];
        CGRect exfeshowframe=exfeeShowview.frame;
        exfeshowframe.origin.x=15-5;
        [exfeeShowview setFrame:exfeshowframe];

        CGRect timetitleframe=timetitle.frame;
        timetitleframe.origin.x=15;
        
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

//        [backgroundview setHidden:YES];
        
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
        CGRect rect=CGRectMake(VIEW_MARGIN,0, containview.frame.size.width-2*VIEW_MARGIN, crossdescription.frame.origin.y+crossdescription.frame.size.height);
        CGRect containrect=containview.frame;
        containrect.origin.y=0;
    }
    
    [containcardview setNeedsDisplay];
}
- (void) setViewMode{
    viewmode=YES;
}
    
- (void) addDefaultIdentity{
        User *user=default_user;
        Identity *default_identity=user.default_identity;
        if(user!=nil){
            Invitation *invitation=[Invitation object];
            invitation.rsvp_status=@"ACCEPTED";
            invitation.host=[NSNumber numberWithBool:YES];
            invitation.mates=0;
            invitation.identity=default_identity;
            invitation.by_identity=default_identity;
            invitation.updated_at=[NSDate date];
            invitation.created_at=[NSDate date];
            [exfeeIdentities addObject:invitation];
            [exfeeSelected addObject:[NSNumber numberWithBool:NO]];
            [exfeeShowview reloadData];
        }
}

- (void) refreshExfeePopOver{
    for(Invitation *invitation in exfeeIdentities){
        if([invitation.invitation_id isEqual:popover.invitation.invitation_id])
            [self ShowExfeePopOver:invitation pointTo:popover.point arrowx:popover.arrowleft];
    }
}
- (void)ShowExfeePopOver:(Invitation*) invitation pointTo:(CGPoint)point  arrowx:(float)arrowx
{
    float width=131;
    float height=58;
    float arrow_height=6;
    float framex=point.x-width/2;
    if([invitation.mates intValue]>0)
        width=182;
    float framey=point.y-height;

    if(popover==nil){
        popover =[[EXInvitationQuoteView alloc]initWithFrame:CGRectMake(framex,framey,width,height)];
        [containcardview addSubview:popover];
    }
    popover.point=point;
    popover.arrowHeight=arrow_height;
    popover.cornerRadius=5;
    popover.layer.shadowColor=[UIColor blackColor].CGColor;
    popover.layer.shadowOpacity = 0.5;
    popover.layer.shadowRadius = 5;
    popover.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    
    NSString *rsvp_status=@"Pending";
    if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
        rsvp_status=@"Accepted";
    else if([invitation.rsvp_status isEqualToString:@"INTERESTED"])
        rsvp_status=@"Interested";
    else if([invitation.rsvp_status isEqualToString:@"DECLINED"])
        rsvp_status=@"Unavailable";
    
    NSString *mate=@"";
    if([invitation.mates intValue]==1)
        mate=[mate stringByAppendingFormat:@" with %u mate.",[invitation.mates intValue]];
    else if([invitation.mates intValue]>1)
        mate=[mate stringByAppendingFormat:@" with %u mates.",[invitation.mates intValue]];
    else
        rsvp_status=[rsvp_status stringByAppendingString:@"."];
    NSString *host=@"";
    if([invitation.host boolValue]==YES)
        host=@"Host. ";
    
    CTFontRef linefontref14= CTFontCreateWithName(CFSTR("HelveticaNeue-Bold"), 14.0, NULL);
    NSMutableAttributedString *Line1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@",host,rsvp_status,mate]];
    [Line1 addAttribute:(NSString*)kCTFontAttributeName value:(id)linefontref14 range:NSMakeRange(0,[Line1 length])];
    [Line1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0,[host length])];
    [Line1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0+[host length],[rsvp_status length])];
    if([mate length]>10){
        [Line1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor whiteColor].CGColor range:NSMakeRange(0+[host length]+[rsvp_status length],[mate length])];
        
        [Line1 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0+[host length]+[rsvp_status length]+6,[[invitation.mates stringValue] length])];
    }
    CFRelease(linefontref14);
    
    float linespaceing=1;
    float minheight=18;
    CTParagraphStyleSetting setting[2] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(setting, 2);
    [Line1 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0,[Line1 length])];

    CTFramesetterRef framesetter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)Line1);
    CFRange range;
    CGSize Line1coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [Line1 length]), nil, CGSizeMake(self.view.frame.size.width, 18), &range);
    CFRelease(style);
    CFRelease(framesetter);
    
    popover.Line1=Line1;
    [Line1 release];

    NSString *identity_name=invitation.identity.external_username;
    if([invitation.identity.provider isEqualToString:@"twitter"])
        identity_name=[@"@" stringByAppendingString:identity_name];
    if(identity_name==nil)
        identity_name=invitation.identity.external_id;
    
    CTFontRef linefontref11= CTFontCreateWithName(CFSTR("HelveticaNeue-Italic"), 11.0, NULL);

    NSMutableAttributedString *Line2 = [[NSMutableAttributedString alloc] initWithString:identity_name];
    [Line2 addAttribute:(NSString*)kCTFontAttributeName value:(id)linefontref11 range:NSMakeRange(0,[identity_name length])];
    [Line2 addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_FA.CGColor range:NSMakeRange(0,[identity_name length])];
    linespaceing=1;
    minheight=13;
    CTParagraphStyleSetting line2setting[2] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
    };
    
    CTParagraphStyleRef line2style = CTParagraphStyleCreate(line2setting, 2);
    [Line2 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)line2style range:NSMakeRange(0,[Line2 length])];
    
    framesetter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)Line2);
    CGSize Line2coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [Line2 length]), nil, CGSizeMake(self.view.frame.size.width-20-19, 13), &range);
    CFRelease(line2style);
    CFRelease(framesetter);
    popover.Line2=Line2;
    [Line2 release];
    CFRelease(linefontref11);
    
    NSString *by_name=invitation.by_identity.name;
    if(by_name==nil)
        by_name=invitation.by_identity.external_username;
    if(by_name==nil)
        by_name=invitation.by_identity.external_id;

    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateformat setDateFormat:@"yyyy-MM-dd"];
    NSString *datestr=[dateformat stringFromDate:invitation.updated_at];
    [dateformat setDateFormat:@"HH:mm:ss"];
    NSString *timestr=[dateformat stringFromDate:invitation.updated_at];
    [dateformat release];
    
    NSString *timestring=@"";
    if(invitation.created_at!=nil)
        timestring=[Util EXRelativeFromDateStr:datestr TimeStr:timestr type:@"rsvp" localTime:NO];
    
    NSString *create_at_and_by=[NSString stringWithFormat:@"%@ by %@",timestring,by_name];
    CTFontRef linefontref11regular= CTFontCreateWithName(CFSTR("HelveticaNeue"), 11.0, NULL);

    NSMutableAttributedString *Line3 = [[NSMutableAttributedString alloc] initWithString:create_at_and_by];
    [Line3 addAttribute:(NSString*)kCTFontAttributeName value:(id)linefontref11regular range:NSMakeRange(0,[Line3 length])];
    [Line3 addAttribute:(NSString*)kCTForegroundColorAttributeName value:FONT_COLOR_FA range:NSMakeRange(0,[Line3 length])];
    CTTextAlignment alignment = kCTRightTextAlignment;
    CTLineBreakMode linebreakmode=kCTLineBreakByTruncatingTail;
    CTParagraphStyleSetting line3setting[4] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(linebreakmode), &linebreakmode},
    };
    
    CTParagraphStyleRef line3style = CTParagraphStyleCreate(line3setting, 4);
    [Line3 addAttribute:(id)kCTParagraphStyleAttributeName value:(id)line3style range:NSMakeRange(0,[Line3 length])];
    
    framesetter=CTFramesetterCreateWithAttributedString((CFAttributedStringRef)Line3);
    CGSize Line3coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [Line3 length]), nil, CGSizeMake(150, 13), &range);
    CFRelease(line3style);
    CFRelease(framesetter);
    CFRelease(linefontref11regular);
    popover.Line3=Line3;
    [Line3 release];

    float maxwidth=MAX(Line1coreTextSize.width+10, Line2coreTextSize.width+10+19+3);
    float line3width= MAX(150,Line3coreTextSize.width+30);
    
    maxwidth=MAX(maxwidth, line3width);
    maxwidth+=20;

    if(maxwidth>300)
        maxwidth=300;
    if(framex<0){
        framex=5;
    }else if(framex+maxwidth>containcardview.frame.size.width){
        framex=containcardview.frame.size.width-maxwidth-5;
    }
    float arrow_left=point.x-arrow_height-framex;

    popover.arrowleft=arrow_left;
    popover.invitation=invitation;
    [popover setFrame:CGRectMake(framex,framey,maxwidth,height)];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [popover.layer removeAnimationForKey:@"fadeout"];
    [UIView commitAnimations];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hiddenPopover) withObject:nil afterDelay:6];
    [popover setNeedsDisplay];
    
}
- (void) hiddenPopover{
    CABasicAnimation *fadeoutAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeoutAnimation.fillMode = kCAFillModeForwards;
    fadeoutAnimation.duration=0.5;
    fadeoutAnimation.removedOnCompletion =NO;
    fadeoutAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    fadeoutAnimation.toValue=[NSNumber numberWithFloat:0.0];
    [popover.layer addAnimation:fadeoutAnimation forKey:@"fadeout"];
}
- (IBAction) Gather:(id) sender{
    [self pullcontainviewDown];
    cross.by_identity=default_user.default_identity;
    cross.title=crosstitle.text;
    cross.cross_description=crossdescription.text;
    cross.time=datetime;
    Exfee *exfee=[Exfee object];
    
    for(Invitation *invitation in exfeeIdentities){
        [exfee addInvitationsObject:invitation];
    }
    cross.exfee = exfee;
    [Flurry logEvent:@"GATHER_SEND"];
    [APICrosses GatherCross:[cross retain] delegate:self];
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
    [ccbuttonText release];
    if(rsvpbutton)
        [rsvpbutton release];
    [containview release];
    [backgroundview release];
    [containcardview release];
    [crossdescbackimg release];
    [default_user release];
//    [conversationView release];
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
    if(cross)
        [[Cross currentContext] deleteObject:cross];
    [self pullcontainviewDown];
    [self dismissModalViewControllerAnimated:YES];
}


- (void) ShowPlaceView:(NSString*)status{
    PlaceViewController *placeViewController=[[PlaceViewController alloc]initWithNibName:@"PlaceViewController" bundle:nil];
    placeViewController.gatherview=self;
    if(cross.place!=nil){
        if(viewmode==YES){
            [placeViewController setPlace:cross.place isedit:YES];
        }
        else{
            [placeViewController setPlace:cross.place isedit:NO];
        }
    }else{
        placeViewController.isaddnew=YES;
    }
    if([status isEqualToString:@"detail"])
        placeViewController.showdetailview=YES;
    [self presentModalViewController:placeViewController animated:YES];
    [placeViewController release];
}
- (void) ShowTimeView{
    TimeViewController *timeViewController=[[TimeViewController alloc] initWithNibName:@"TimeViewController" bundle:nil];
    timeViewController.gatherview=self;
    [timeViewController setDateTime:datetime];
    [self presentModalViewController:timeViewController animated:YES];
    [timeViewController release];
}

- (void) ShowExfeeView{
    ExfeeInputViewController *exfeeinputViewController=[[ExfeeInputViewController alloc] initWithNibName:@"ExfeeInputViewController" bundle:nil];
    exfeeinputViewController.gatherview=self;
    [self presentModalViewController:exfeeinputViewController animated:YES];
//    [exfeeinputViewController release];
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
    [self setExfeeNum];
}
- (int) exfeeIdentitiesCount{
    int i=0;
    for(Invitation *invitation in exfeeIdentities)
    {
        if(![invitation.rsvp_status isEqualToString:@"REMOVED"])
            i++;
    }
    return i;
}
- (NSArray*) getReducedExfeeIdentities{
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:12];
    for(Invitation *invitation in exfeeIdentities){
        if(![invitation.rsvp_status isEqualToString:@"REMOVED"]){
            [arr addObject:invitation];
        }
    }
    return arr;
}
- (void) savePlace:(Place*)place{
    
//    if([place.external_id isEqualToString:cross.place.external_id]&&
//       [place.lat isEqualToString:cross.place.lat]&&
//       [place.lng isEqualToString:cross.place.lng]&&
//       [place.place_description isEqualToString:cross.place.place_description]&&
//       [place.provider isEqualToString:cross.place.provider]&&
//       [place.title isEqualToString:cross.place.title]){
//        return;
//    }
        cross.place=place;
        [self setPlace:place];
        [self saveCrossUpdate];
}

- (void) setPlace:(Place*)place{
    if(place!=nil)
    {
        if([place.lat isEqualToString:@""] && [place.lng isEqualToString:@""] && [place.title isEqualToString:@""] && [place.place_description isEqualToString:@""]){
            placetitle.text=@"Shomewhere";
            placedesc.text=@"";
            [self reArrangeViews];
            mapbox.image=[UIImage imageNamed:@"map_nil.png"];
            return;
        }
        cross.place=place;
        if(cross.place!=nil) {
            float delta=0.005;
            CLLocationCoordinate2D location;
            [map removeAnnotations: map.annotations];
            location.latitude = [place.lat doubleValue];
            location.longitude = [place.lng doubleValue];
            MKCoordinateRegion region;
            
            
            region.center = location;
            region.span.longitudeDelta = delta;
            region.span.latitudeDelta = delta;
            [map setRegion:region animated:NO];
            
            if([place.lat isEqualToString:@""] && [place.lng isEqualToString:@""])
                mapbox.image=[UIImage imageNamed:@"map_nil.png"];
            else
                mapbox.image=[UIImage imageNamed:@"map_framepin.png"];
//            [self updateMapImage];
            placetitle.text=place.title;
            placedesc.text=place.place_description;
            [self reArrangeViews];
        }
    }
}
- (void) saveDateTime:(CrossTime*)crosstime{
    [self setDateTime:crosstime];
    if(viewmode==YES){
        if(cross!=nil){
            cross.time=datetime;
            [self saveCrossUpdate];
        }
    }
}
- (void) setDateTime:(CrossTime*)crosstime{
    if(crosstime==nil){
        timetitle.text=@"Sometime";
        timedesc.text=@"";
    }else{
        timetitle.text=[Util getTimeTitle:crosstime localTime:NO];
        timedesc.text=[Util getTimeDesc:crosstime];
    }
    datetime=crosstime;
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
    conversationView=[[ConversationViewController alloc]initWithNibName:@"ConversationViewController" bundle:nil] ;
    conversationView.exfee_id=[cross.exfee.exfee_id intValue];
    conversationView.cross_title=cross.title;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSSet *invitations=cross.exfee.invitations;
    if(invitations !=nil&&[invitations count]>0)
    {
        for(Invitation* invitation in invitations)
            if([invitation.identity.connected_user_id intValue]==app.userid)
                conversationView.identity=invitation.identity;
    }
    cross.conversation_count=0;
//    NSError *saveError;
//    [[Cross currentContext] save:&saveError];
    NSArray *viewControllers = self.navigationController.viewControllers;
    CrossesViewController *crossViewController = [viewControllers objectAtIndex:0];
    [crossViewController refreshTableViewWithCrossId:[cross.cross_id intValue]];
    
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:
     UIViewAnimationTransitionFlipFromRight
                           forView:self.navigationController.view cache:NO];
    [self.navigationController pushViewController:conversationView animated:NO];
    [UIView commitAnimations];
}
- (void) ShowMyRsvpToolBar{
    if(myrsvptoolbar==nil){
        CGRect screenframe=[[UIScreen mainScreen] bounds];
        CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
        screenframe.size.height-=statusframe.size.height;

        myrsvptoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, screenframe.size.height-44-50) buttonsize:CGSizeMake(20, 20) delegate:self];

        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"I'm in" image:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] inFrame:CGRectMake(0, 0, 107, 50)];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];
        
        EXButton *interested=[[EXButton alloc] initWithName:@"interested" title:@"Interested" image:[UIImage imageNamed:@"rsvp_interested_toolbar.png"] inFrame:CGRectMake(107, 0, 107, 50)];
        [interested addTarget:self action:@selector(rsvpinterested) forControlEvents:UIControlEventTouchUpInside];
        
        EXButton *decline=[[EXButton alloc] initWithName:@"decline" title:@"Decline" image:[UIImage imageNamed:@"rsvp_unavailable_toolbar.png"] inFrame:CGRectMake(214, 0, 107, 50)];
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
        CGRect screenframe=[[UIScreen mainScreen] bounds];
        CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
        screenframe.size.height-=statusframe.size.height;

        rsvptoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, screenframe.size.height-44-50) buttonsize:CGSizeMake(20, 20) delegate:self];

        EXButton *submate=[[EXButton alloc] initWithName:@"submate" title:@"-1 mate" image:[UIImage imageNamed:@"rsvp_mates_minus_toolbar.png"] inFrame:CGRectMake(0, 0, 44+14, 50)];
        [submate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [submate addTarget:self action:@selector(rsvpsubmate) forControlEvents:UIControlEventTouchUpInside];
        [submate setTitle:@"" forState:UIControlStateNormal];
        submate.setInset=YES;
        [submate setImageEdgeInsets:UIEdgeInsetsMake(6, 0, 14, 0)];
        
        EXButton *addmate=[[EXButton alloc] initWithName:@"addmate" title:@"+1 mate" image:[UIImage imageNamed:@"rsvp_mates_plus_toolbar.png"] inFrame:CGRectMake(58, 0, 44+14, 50)];
        [addmate setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [addmate addTarget:self action:@selector(rsvpaddmate) forControlEvents:UIControlEventTouchUpInside];
        [addmate setTitle:@"" forState:UIControlStateNormal];
        [addmate setImageEdgeInsets:UIEdgeInsetsMake(6, 0, 14, 0)];
        addmate.setInset=YES;
        
        UILabel *hint=[[UILabel alloc] initWithFrame:CGRectMake(38, 36, 44, 14)];
        hint.text=@"Mates";
        [hint setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
//        CGSize hinttextrect=[hint.text sizeWithFont:hint.font];
//        CGRect hintframe=[hint frame];
//        hintframe.size.height=hinttextrect.height;
        
//        hinttextrect.height
        
        [hint setBackgroundColor:[UIColor clearColor]];
        hint.textAlignment=UITextAlignmentCenter;
        [hint setTextColor:FONT_COLOR_250];
        [rsvptoolbar addSubview:hint];
        [hint release];

        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"Accept" image:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] inFrame:CGRectMake(116, 0, 68, 50)];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];

        EXButton *ignore=[[EXButton alloc] initWithName:@"ignore" title:@"Pending" image:[UIImage imageNamed:@"rsvp_pending_toolbar.png"] inFrame:CGRectMake(184, 0, 68, 50)];
        [ignore addTarget:self action:@selector(rsvpinterested) forControlEvents:UIControlEventTouchUpInside];

        EXButton *decline=[[EXButton alloc] initWithName:@"decline" title:@"Unavailable" image:[UIImage imageNamed:@"rsvp_unavailable_toolbar.png"] inFrame:CGRectMake(252, 0, 68, 50)];
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
    if(rsvpbutton){
        [rsvpbutton removeFromSuperview];
        [rsvpbutton release];
    }
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
    screenframe.size.height-=statusframe.size.height;

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
        
        rsvpbutton=[[EXButton alloc] initWithName:@"accept" title:@"" image:[UIImage imageNamed:buttonimgname] inFrame:CGRectMake(self.view.frame.size.width/2-30, screenframe.size.height-44-33, 60, 44)];
//        CGRect rect=[rsvpbutton frame];
//        float y=self.view.frame.size.height-44-rect.size.height;
        [rsvpbutton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bg.png"]]];
        [rsvpbutton addTarget:self action:@selector(ShowMyRsvpToolBar) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:rsvpbutton];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
//        rect.origin.y=y;
//        [rsvpbutton setFrame:rect];
        [UIView commitAnimations];

        [myrsvptoolbar setHidden:YES];
    }
    else{
//        CGRect rect=[myrsvptoolbar frame];
//        [myrsvptoolbar setHidden:NO];
        [self ShowMyRsvpToolBar];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.3];

//        [myrsvptoolbar setHidden:NO];
    }
}
- (void) ShowGatherToolBar{
    if(rsvpbutton)
        [rsvpbutton setHidden:YES];
    if(rsvptoolbar)
        [rsvptoolbar setHidden:YES];
    if(gathertoolbar==nil){
//        CGRect screenframe=[[UIScreen mainScreen] bounds];
//        CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
//        screenframe.size.height-=statusframe.size.height;
        gathertoolbar=[[EXIconToolBar alloc] initWithPoint:CGPointMake(0, self.view.frame.size.height-50) buttonsize:CGSizeMake(20, 20) delegate:self];
        
        EXButton *accept=[[EXButton alloc] initWithName:@"accept" title:@"Accept" image:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] inFrame:CGRectMake(35, 0, 44, 50)];
        [accept addTarget:self action:@selector(rsvpaccept) forControlEvents:UIControlEventTouchUpInside];
        
        EXButton *submate=[[EXButton alloc] initWithName:@"submate" title:@"-1 mate" image:[UIImage imageNamed:@"rsvp_mates_minus_toolbar.png"] inFrame:CGRectMake(35+36+45, 0, 44, 50)];
        [submate addTarget:self action:@selector(rsvpsubmate) forControlEvents:UIControlEventTouchUpInside];
        [submate setTitle:@"" forState:UIControlStateNormal];
        EXButton *addmate=[[EXButton alloc] initWithName:@"addmate" title:@"+1 mate" image:[UIImage imageNamed:@"rsvp_mates_plus_toolbar.png"] inFrame:CGRectMake(35+36+45+44, 0, 44, 50)];
        [addmate addTarget:self action:@selector(rsvpaddmate) forControlEvents:UIControlEventTouchUpInside];
        [addmate setTitle:@"" forState:UIControlStateNormal];
        
        EXButton *remove=[[EXButton alloc] initWithName:@"remove" title:@"Remove" image:[UIImage imageNamed:@"remove_toolbar.png"] inFrame:CGRectMake(35+36+45+44+44+45, 0, 44, 50)];
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
        [gathertoolbar replaceButtonImage:[UIImage imageNamed:@"rsvp_pending_toolbar.png"] title:@"Pending" target:self action:@selector(rsvpunaccept) forname:@"accept"];
    else
        [gathertoolbar replaceButtonImage:[UIImage imageNamed:@"rsvp_accept_toolbar.png"] title:@"Accept" target:self action:@selector(rsvpaccept) forname:@"accept"];
    [gathertoolbar setHidden:NO];
    NSLog(@"view height %f y %f",self.view.frame.size.height,self.view.frame.origin.y);
    NSLog(@"toolbar y %f",gathertoolbar.frame.origin.y);

//    CGRect screenframe=[[UIScreen mainScreen] bounds];
//    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
//    screenframe.size.height-=statusframe.size.height;
//
//    CGRect gatherframe=[gathertoolbar frame];
//    gatherframe.origin.y=screenframe.size.height-50-50;
//    [gathertoolbar setFrame:gatherframe];
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
    int all=0;
    int accept=0;
    NSArray *exfee=exfeeIdentities;
    if(exfee==nil || [exfee count] == 0)
        exfee=[cross.exfee.invitations allObjects];
    for(Invitation *invitation in exfee) {
        all+=[invitation.mates intValue]+1;
        if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
            accept+=[invitation.mates intValue]+1;
    }
    NSString *total=[[NSNumber numberWithInt:all] stringValue]; //[cross.exfee.total stringValue];
    NSString *accepted=[[NSNumber numberWithInt:accept] stringValue]; //[cross.exfee.accepted stringValue];
    NSMutableAttributedString * exfeestr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@",accepted,total]];
    [exfeestr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange(0,accepted.length)];
    CTFontRef exfeefontref21= CTFontCreateWithName(CFSTR("HelveticaNeue"), 21.0, NULL);
    CTFontRef exfeefontref13= CTFontCreateWithName(CFSTR("HelveticaNeue"), 13.0, NULL);
    
    [exfeestr addAttribute:(NSString*)kCTFontAttributeName value:(id)exfeefontref21 range:NSMakeRange(0,accepted.length)];
    [exfeestr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blackColor].CGColor range:NSMakeRange(accepted.length,exfeestr.length-accepted.length)];
    [exfeestr addAttribute:(NSString*)kCTFontAttributeName value:(id)exfeefontref13 range:NSMakeRange(accepted.length,exfeestr.length-accepted.length)];
    CFRelease(exfeefontref13);
    CFRelease(exfeefontref21);

    CTTextAlignment alignment = kCTRightTextAlignment;
    CTParagraphStyleSetting linesetting[1] = {
//        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
//        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment}
    };
    
    CTParagraphStyleRef linestyle = CTParagraphStyleCreate(linesetting, 1);
    [exfeestr addAttribute:(id)kCTParagraphStyleAttributeName value:(id)linestyle range:NSMakeRange(0,[exfeestr length])];
    exfeenum.attributedText=exfeestr;
    CFRelease(linestyle);
    if([exfeeIdentities count]<3 && exfeeShowview.editmode==YES)
        [exfeenum setFrame:CGRectMake(containcardview.frame.size.width-15-124, 50+25, 124, 27)];
    if([exfeeIdentities count]<5 && exfeeShowview.editmode==NO)
        [exfeenum setFrame:CGRectMake(containcardview.frame.size.width-15-124, 50+25, 124, 27)];
    else
        [exfeenum setFrame:CGRectMake(containcardview.frame.size.width-15-124, 50, 124, 27)];
    
    [exfeestr release];
    [exfeenum setNeedsDisplay];
}
- (void) saveExfeeUpdate{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving";
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    cross.by_identity=default_user.default_identity;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSError *error;
    NSString *json = [[RKObjectSerializer serializerWithObject:cross.exfee mapping:[[APICrosses getExfeeMapping]  inverseMapping]] serializedObjectForMIMEType:RKMIMETypeJSON error:&error];

    RKParams* rsvpParams = [RKParams params];
    [rsvpParams setValue:json forParam:@"exfee"];
    [rsvpParams setValue:cross.exfee.exfee_id forParam:@"id"];
    [rsvpParams setValue:[self getMyInvitation].identity.identity_id forParam:@"by_identity_id"];
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/edit?token=%@",[cross.exfee.exfee_id intValue],app.accesstoken];
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
                            RKObjectMapper* mapper;
                            mapper = [RKObjectMapper mapperWithObject:body mappingProvider:[RKObjectManager sharedManager].mappingProvider];
                            RKObjectMappingResult* result = [mapper performMapping];
                            id obj=[result asObject];
                            if([obj isKindOfClass:[Exfee class]]){
                                cross.exfee=(Exfee*)obj;
                                [[Cross currentContext] save:nil];
                                [self reloadExfeeIdentities];
                            }
                        }else
                            [Util showErrorWithMetaDict:[body objectForKey:@"meta"] delegate:self];
                }
            }else {
                //Check Response Body to get Data!
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        };
        request.onDidFailLoadWithError=^(NSError *error){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *errormsg=@"Could not save this cross.";
            if(![errormsg isEqualToString:@""]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
                alert.tag=202; // 201 = Save Exfee
                [alert show];
                [alert release];
            }
        };
        request.delegate=self;
    }];
}

- (void)saveCrossUpdate{
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving";
    hud.mode=MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView=bigspin;
    [bigspin release];
    
    cross.by_identity=default_user.default_identity;
    
    NSError *error;
    NSString *json = [[RKObjectSerializer serializerWithObject:cross mapping:[[APICrosses getCrossMapping]  inverseMapping]] serializedObjectForMIMEType:RKMIMETypeJSON error:&error];
    if(!error){
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        RKClient *client = [RKClient sharedClient];
        [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
        NSString *endpoint = [NSString stringWithFormat:@"/crosses/%u/edit?token=%@",[cross.cross_id intValue],app.accesstoken];
        [client post:endpoint usingBlock:^(RKRequest *request){
            request.method=RKRequestMethodPOST;
            
            request.params=[RKRequestSerialization serializationWithData:[json dataUsingEncoding:NSUTF8StringEncoding] MIMEType:RKMIMETypeJSON];
            request.onDidLoadResponse=^(RKResponse *response){
                if (response.statusCode == 200) {
                    NSDictionary *body=[response.body objectFromJSONData];
                    NSDictionary *meta=[body objectForKey:@"meta"];
                    if([[meta objectForKey:@"code"] isKindOfClass:[NSNumber class]])
                    {
                        if([(NSNumber*)[meta objectForKey:@"code"] intValue]==200){
                            NSDictionary *responsedict=[body objectForKey:@"response"];
                            NSDictionary *crossdict=[responsedict objectForKey:@"cross" ];
                            NSNumber *cross_id=[crossdict objectForKey:@"id"];
                            if([cross_id intValue]==[self.cross.cross_id intValue])
                            {
                                [app CrossUpdateDidFinish:[cross.cross_id intValue]];
                            }
                        }else{
                            [Util showErrorWithMetaDict:meta delegate:self];
                        }
                    }
                }else {
                    NSString *errormsg=@"Could not save this cross.";
                    if(![errormsg isEqualToString:@""]){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
                        alert.tag=201; // 201 = Save Cross
                        [alert show];
                        [alert release];
                    }
                }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            };
            request.onDidFailLoadWithError=^(NSError *error){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSString *errormsg=@"";
                if(error.code==2)
                    errormsg=@"A connection failure has occurred.";
                else
                    errormsg=@"Could not connect to the server.";
                if(![errormsg isEqualToString:@""]){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
                    alert.tag=201; // 201 = Save Cross
                    [alert show];
                    [alert release];
                }
                
//                [Util showConnectError:error delegate:self];
            };
            request.delegate=self;
        }];
    }
}

- (void) didlongpress:(UILongPressGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    if(viewmode==YES)
    {
        if (CGRectContainsPoint([exfeeShowview frame], location))
        {
            [self setExfeeViewMode:YES];
        }
        if (CGRectContainsPoint([crosstitle_view frame], location))
        {
            [crosstitle_view setHidden:YES];
            [crosstitle setHidden:NO];
            [title_input_img setHidden:NO];
            [crosstitle becomeFirstResponder];
        }

        if (CGRectContainsPoint([crossdescription frame], location))
        {
            [crossdescription setEditable:YES];
            [crossdescription becomeFirstResponder];
        }
    }
}
- (void) setExfeeViewMode:(BOOL)edit{
    if(edit==YES)
    {
        exfeeShowview.editmode=YES;
        [exfeeShowview ShowAddButton];
        [exfeeShowview reloadData];
        [rsvptoolbar setHidden:YES];
        [rsvpbutton setHidden:YES];
        [myrsvptoolbar setHidden:YES];
        BOOL isSelect=NO;
        for(NSNumber *number in exfeeSelected){
            if([number boolValue]==YES)
                isSelect=YES;
        }
        if(isSelect==YES){
            [self ShowGatherToolBar];
        }
    }else{
        exfeeShowview.editmode=NO;
        [exfeeShowview HiddenAddButton];
        [exfeeShowview reloadData];
        [rsvptoolbar setHidden:YES];
        [rsvpbutton setHidden:YES];
        [myrsvptoolbar setHidden:YES];
        [gathertoolbar setHidden:YES];
        BOOL isSelect=NO;
        for(NSNumber *number in exfeeSelected){
            if([number boolValue]==YES)
                isSelect=YES;
        }
        if(isSelect==YES){
            [self ShowRsvpToolBar];
        }
        else
            [self ShowRsvpButton];
    }
    if(edit==NO){
        int all=0;
        int accept=0;

        Exfee *exfee=[Exfee object];
        exfee.exfee_id=cross.exfee.exfee_id;
        for(Invitation *invitation in exfeeIdentities){
            all+=[invitation.mates intValue]+1;
            if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
                accept+=[invitation.mates intValue]+1;

            [exfee addInvitationsObject:invitation];
        }
        exfee.total=[NSNumber numberWithInt:all];
        exfee.accepted=[NSNumber numberWithInt:accept];
        cross.exfee = exfee;
        [self saveExfeeUpdate];
    }
    [self setExfeeNum];
}

- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    if (CGRectContainsPoint([placetitle frame], location) || CGRectContainsPoint([placedesc frame], location))
    {
        [crosstitle resignFirstResponder];
        [map becomeFirstResponder];
        
        [self ShowPlaceView:@"detail"];
    }

    if (CGRectContainsPoint([timetitle frame], location) || CGRectContainsPoint([timedesc frame], location))
    {
        [self ShowTimeView];
    }

    if(exfeeShowview.editmode==YES){
        if (!CGRectContainsPoint([exfeeShowview frame], location)){
            [self setExfeeViewMode:NO];
        }
    }
    if(viewmode==YES){
        if(crosstitle.hidden==NO)
        {
            if (!CGRectContainsPoint([crosstitle frame], location)){
                cross.title = crosstitle.text;
                crosstitle_view.text=crosstitle.text;
                [crosstitle setHidden:YES];
                [crosstitle_view setHidden:NO];
                [title_input_img setHidden:YES];
                [self saveCrossUpdate];
            }
            
        }
        if(crossdescription.editable==YES){
            if (!CGRectContainsPoint([crossdescription frame], location)){
                [self saveCrossDesc];
            }
        }
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
- (void) saveCrossDesc{
    [crossdescription setEditable:NO];
    for (UIGestureRecognizer *recognizer in crossdescription.gestureRecognizers)
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
            recognizer.enabled = NO;
        }
    
    [self reArrangeViews];
    cross.cross_description=crossdescription.text;
    [self saveCrossUpdate];
}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//
//    UITouch * touch = [touches anyObject];
//    if(touch.phase == UITouchPhaseBegan) {
//        if (CGRectContainsPoint([placetitle frame], [touch locationInView:self.view]) || CGRectContainsPoint([placedesc frame], [touch locationInView:self.view]))
//        {
//            [crosstitle resignFirstResponder];
//            [map becomeFirstResponder];
//            [self ShowPlaceView];
//        }
//        if (CGRectContainsPoint([timetitle frame], [touch locationInView:self.view]) || CGRectContainsPoint([timedesc frame], [touch locationInView:self.view]))
//        {
//            [crosstitle resignFirstResponder];
//            [timetitle becomeFirstResponder];
//            [self ShowTimeView];
//        }
//    }
//}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    float KEYBOARD_LANDSCAPE=216;
    notUserScroll=YES;
    if(viewmode==YES && textView.tag==108){
        CGRect frame=[crossdescription frame];
        float offset=frame.size.height-144;
        frame.size.height=144;
        [crossdescription setFrame:frame];
        CGSize containsize=[containview contentSize];
        containsize.height=containsize.height-offset;
        CGRect containcardframe=[containcardview frame];
        containcardframe.size.height=containcardframe.size.height-offset;

        [containview setContentSize:containsize];
        [containcardview setFrame:containcardframe];
    }
        if(textView.tag==108)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelay:0];
            [UIView setAnimationDuration:0.25];
            float y=crossdescription.frame.origin.y-15;
            [containview setContentOffset:CGPointMake(0, y)];
            [UIView commitAnimations];
        }
        notUserScroll=NO;
    return YES;
}

- (Cross*) reloadCrossFromStorage{
    NSFetchRequest* request = [Cross fetchRequest];
      NSPredicate *predicate = [NSPredicate
                                predicateWithFormat:@"cross_id = %u", [self.cross.cross_id intValue]];
      [request setPredicate:predicate];
    NSArray *crosses = [[Cross objectsWithFetchRequest:request] retain];
    if ([crosses count]>0)
        return [crosses objectAtIndex:0];
    
    return nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag==101){
        [textField resignFirstResponder];            
    }
    return YES;
}


#pragma mark UIAlertView methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //tag 101: save cross
    //tag 102: save exfee
    if(buttonIndex==0)//cancel
    {
        if(alertView.tag==201){
            [[Cross currentContext] rollback];
            [self setDateTime:cross.time];
            [self setPlace:cross.place];
            crosstitle.text=cross.title;
            crossdescription.text=cross.cross_description;
        }else if(alertView.tag==202){
            [[Exfee currentContext] rollback];
            [[Cross currentContext] rollback];
            [self reloadExfeeIdentities];
        }
    }else if(buttonIndex==1) //retry
    {
        if(alertView.tag==201){
            [self saveCrossUpdate];
        }else if(alertView.tag==202){
            [self saveExfeeUpdate];
        }
    }
//    if(buttonIndex==1 && alertView.tag==500){
//        
//    }
}


#pragma mark UIScrollView methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.tag==108)
        return;
    for (UIView *view in [containview subviews])
    {
        [view resignFirstResponder];
    }
    if(notUserScroll==NO && crossdescription.editable==YES && viewmode==YES && scrollView.tag!=108)
        [self saveCrossDesc];
    
    if(notUserScroll==NO){
        [crossdescription resignFirstResponder];
        [crosstitle resignFirstResponder];
        [containview becomeFirstResponder];
    }
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
    if(cross){
        if(cross.place!=nil)
            [[Place currentContext] deleteObject:cross.place];
        [[Exfee currentContext] deleteObject:cross.exfee];
        [[Cross currentContext] deleteObject:cross];
    }
    
    NSString *errormsg=[error.userInfo objectForKey:@"NSLocalizedDescription"];
    if(error.code==2)
        errormsg=@"A connection failure has occurred.";
    else
        errormsg=@"Could not connect to the server.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark EXImagesCollectionView Datasource methods

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return [self exfeeIdentitiesCount];
}
- (EXImagesItem *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index{
    EXImagesItem *item=[[[EXImagesItem alloc] init] autorelease];
    NSArray *arr=[self getReducedExfeeIdentities];
    Invitation *invitation =[arr objectAtIndex:index];
    Identity *identity=invitation.identity;
    UIImage *img=[[ImgCache sharedManager] checkImgFrom:identity.avatar_filename];
    if(img!=nil)
        item.avatar=img;
    else{
        item.avatar=[UIImage imageNamed:@"portrait_default.png"];
        if(identity.avatar_filename!=nil) {
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                        item.avatar=avatar;
                        [item setNeedsDisplay];
                    }
                });
            });
            dispatch_release(imgQueue);
        }
    }
    
    item.isHost=[invitation.host boolValue];
    item.mates=[invitation.mates intValue];
    item.rsvp_status=invitation.rsvp_status;
    NSString *name=identity.name;
    if(name==nil)
        name=identity.external_username;
    if(name==nil)
        name=identity.external_id;
    item.name=name;
    [arr release];
    return item;
}
- (NSArray *) selectedOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView{
    return exfeeSelected;
    
}
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView shouldResizeHeightTo:(float)height{
        
    if(viewmode==YES && exfeeShowview.editmode==NO)
    {
        if(height==120 && [exfeeIdentities count]==6)
            return;
    }
    [exfeeShowview setFrame:CGRectMake(exfeeShowview.frame.origin.x, exfeeShowview.frame.origin.y, exfeeShowview.frame.size.width, height)];
    [exfeeShowview calculateColumn];
//    if(viewmode==NO || exfeeShowview.editmode==YES){
        [self reArrangeViews];
//    }
    
//    [exfeeIdentities count]

    
}

#pragma mark EXImagesCollectionView delegate methods
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect {
    if(index==[exfeeIdentities count])
    {
        if(viewmode==YES && exfeeShowview.editmode==NO)
            return;
        [self ShowGatherToolBar];
        [self ShowExfeeView];
    }
    else if(index <[exfeeIdentities count]){
        [crosstitle resignFirstResponder];
        [crosstitle endEditing:YES];
        BOOL select_status=[[exfeeSelected objectAtIndex:index] boolValue];
        for( int i=0;i<[exfeeSelected count];i++){
            [exfeeSelected replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
        [exfeeSelected replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!select_status]];
        [exfeeShowview reloadData];
        BOOL isSelect=NO;
        for(NSNumber *number in exfeeSelected){
            if([number boolValue]==YES)
                isSelect=YES;
        }
        if(isSelect){
            CGRect f=imageCollectionView.frame;
            float x=f.origin.x+rect.origin.x+rect.size.width/2;
            float y=f.origin.y+rect.origin.y;
            Invitation *invitation=[exfeeIdentities objectAtIndex:index];
            [self ShowExfeePopOver:invitation pointTo:CGPointMake(x,y) arrowx:rect.origin.x+rect.size.width/2+f.origin.x];
            if(viewmode==YES && exfeeShowview.editmode==NO){
                [self ShowRsvpToolBar];
            }
            else
                [self ShowGatherToolBar];
        }
        else {
            if(viewmode==YES&& exfeeShowview.editmode==NO)
                [self ShowRsvpButton];
            else //if(exfeeShowview.editmode==YES)
                [gathertoolbar setHidden:YES];
            
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
                                    [self refreshExfeePopOver];
                                    [exfeeShowview reloadData];
                                    [self setExfeeNum];
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
                    NSString *errormsg=[error.userInfo objectForKey:@"NSLocalizedDescription"];
                    if(error.code==2)
                        errormsg=@"A connection failure has occurred.";
                    else
                        errormsg=@"Could not connect to the server.";
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    
                    if(selected==NO)
                        [self ShowMyRsvpToolBar];
                    else
                        [self ShowRsvpToolBar];
                    
                };
                request.delegate=self;
            }];
        }
        else{
            [self refreshExfeePopOver];
            [exfeeShowview reloadData];
            [self setExfeeNum];
            [self ShowGatherToolBar];
        }
    [postarray release];
    }
//    [exfeeShowview reloadData];
//    [self ShowGatherToolBar];
}
- (void) setMates:(int)mates{
    NSError* error = nil;
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSNumber *by_identity_id=[NSNumber numberWithInt:0];
    for (Invitation* invitation in cross.exfee.invitations )
    {
        if([invitation.identity.connected_user_id intValue] == app.userid)
            by_identity_id=invitation.identity.identity_id;
    }
    if(by_identity_id>0)
    {
//        BOOL selected=NO;
        for(int i=0;i< [exfeeSelected count];i++) {
            if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
//                selected=YES;
                if(i<[exfeeIdentities count]) {
                    for(Invitation *invitation in exfeeIdentities)
                    {
                        Invitation *selectedinvitation=(Invitation*)[exfeeIdentities objectAtIndex:i];
                        
                        if([invitation.invitation_id intValue]==[selectedinvitation.invitation_id intValue]){
                            if([invitation.mates intValue]>=9 && mates>0)
                                continue;
                            else if([invitation.mates intValue]<=0 && mates<0)
                                continue;
                            
                                if(mates!=0){
                                    int mates_result=[invitation.mates intValue]+mates;
                                    if(mates_result<0)
                                        mates_result=0;
                                    invitation.mates= [NSNumber numberWithInt:mates_result];
                                }
                                else
                                    invitation.mates=0;
                        }
                    }
                }
            }
        }
        if(viewmode==YES && exfeeShowview.editmode==NO)
        {
            RKParams* rsvpParams = [RKParams params];
            NSDictionary *exfee_dict=[ObjectToDict ExfeeDict:cross.exfee];
            [rsvpParams setValue:[exfee_dict JSONString] forParam:@"exfee"];
            [rsvpParams setValue:[self getMyInvitation].identity.identity_id forParam:@"by_identity_id"];
            RKClient *client = [RKClient sharedClient];
            [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
            NSString *endpoint = [NSString stringWithFormat:@"/exfee/%u/edit?token=%@",[cross.exfee.exfee_id intValue],app.accesstoken];
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
                                    [self refreshExfeePopOver];
                                    [exfeeShowview reloadData];
                                    [self setExfeeNum];
                                }
                        }
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
                request.delegate=self;
            }];
        }
        else{
            [self refreshExfeePopOver];
            [exfeeShowview reloadData];
            [self setExfeeNum];
        }
    }else{
        [self refreshExfeePopOver];
        [exfeeShowview reloadData];
        [self setExfeeNum];

    }

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
    [self setMates:1];
}
- (void) rsvpsubmate{
    [self setMates:-1];
}
- (void) rsvpremove{
//    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for(int i=0;i< [exfeeSelected count];i++) {
        if([[exfeeSelected objectAtIndex:i] boolValue]==YES) {
            if(i<[exfeeIdentities count]) {
                ((Invitation*)[exfeeIdentities objectAtIndex:i]).rsvp_status=@"REMOVED";
//                [mutableIndexSet addIndex:i];
            }
        }
    }
    
//    [exfeeIdentities removeObjectsAtIndexes:mutableIndexSet];
//    [exfeeSelected removeObjectsAtIndexes:mutableIndexSet];

//    [mutableIndexSet release];
    [exfeeShowview calculateColumn];
    [self refreshExfeePopOver];

    [exfeeShowview reloadData];
    
}

- (void) setRandomBackground{
    RKClient *client = [RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
    NSString *endpoint = [NSString stringWithFormat:@"/Backgrounds/getAvailableBackgrounds"];
    [client post:endpoint usingBlock:^(RKRequest *request){
        request.method=RKRequestMethodPOST;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                if([body isKindOfClass:[NSDictionary class]]) {
                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                    if(code)
                        if([code intValue]==200) {
                            NSDictionary* response=[body objectForKey:@"response"];
                            if([response isKindOfClass:[NSDictionary class]]) {
                                NSArray *backgrounds=[response objectForKey:@"backgrounds"];
                                int randNum = rand() % ([backgrounds count]);
                                NSString *imgname=[backgrounds objectAtIndex:randNum];
                                NSString *imgurl=[Util getBackgroundLink:imgname];
                                NSDictionary *widget=[NSDictionary dictionaryWithObjectsAndKeys:imgname,@"image",@"Background",@"type", nil];
                                if(cross.widget==nil)
                                    cross.widget=[[NSMutableArray alloc] initWithCapacity:1];
                                [cross.widget addObject:widget];
                                UIImage *backimg=[[ImgCache sharedManager] getImgFromCache:imgurl];
                                UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, containview.frame.size.width, 180)];
                                imageview.image=nil;

                                if(backimg==nil || [backimg isEqual:[NSNull null]]){
                                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                                    dispatch_async(imgQueue, ^{
                                        UIImage *backimg=[[ImgCache sharedManager] getImgFrom:imgurl];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if(backimg!=nil && ![backimg isEqual:[NSNull null]])
                                                imageview.image=backimg;
                                        });
                                    });
                                    dispatch_release(imgQueue);
                                }else
                                    imageview.image=backimg;
                                UIImageView *imagemaskview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, containview.frame.size.width, 180)];
                                imagemaskview.image=[UIImage imageNamed:@"cross_bgmask.png"];
                                [backgroundview addSubview:imageview];
                                [backgroundview addSubview:imagemaskview];
                                [imagemaskview release];
                                [imageview release];
                                

                            }
                        }
                }
            }else {
                //Check Response Body to get Data!
            }
        };
    }];
    
}


@end
