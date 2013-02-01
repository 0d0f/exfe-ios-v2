//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import "ProfileViewController.h"
#import "CrossDetailViewController.h"
#import "APICrosses.h"
#import "Cross.h"
#import "Exfee.h"
#import "Identity.h"
#import "Rsvp.h"
#import "CrossCard.h"
#import "ImgCache.h"
#import "Util.h"
#import "CrossTime+Helper.h"
#import "EFTime+Helper.h"
#import "Place+Helper.h"


@interface CrossesViewController ()

@end

@implementation CrossesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initUI];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    [self.view setFrame:appFrame];
    self.view.backgroundColor = [UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];

    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;

    customStatusBar = [[CustomStatusBar alloc] initWithFrame:CGRectZero];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 6)]
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    current_cellrow=-1;
    self.tableView.backgroundColor = [UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];
    //UIView *topview = [[UIView alloc] initWithFrame:CGRectOffset(screenframe, 0, CGRectGetHeight(screenframe))];
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, -480, 320, 480)];
    topview.backgroundColor = [UIColor COLOR_RGB(0xEE, 0xEE, 0xEE)];
    [self.tableView addSubview:topview];
    [topview release];
    [super viewDidLoad];
    
    gatherax=[[NSMutableAttributedString alloc] initWithString:@"Gather a ·X·"];
    CTFontRef fontref=CTFontCreateWithName(CFSTR("HelveticaNeue"), 21.0, NULL);
    [gatherax addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref range:NSMakeRange(0,[gatherax length])];
    CFRelease(fontref);
    [gatherax addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:NSMakeRange([gatherax length]-3,3)];

    CTTextAlignment alignment = kCTCenterTextAlignment;
    float linespaceing=1;
    float minheight=26;
    
    CTParagraphStyleSetting gathersetting[3] = {
        {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &linespaceing},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minheight},
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef gatherstyle = CTParagraphStyleCreate(gathersetting, 3);
    [gatherax addAttribute:(id)kCTParagraphStyleAttributeName value:(id)gatherstyle range:NSMakeRange(0,[gatherax length])];
    CFRelease(gatherstyle);
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL login=[app Checklogin];
    if(login==YES) {
        [self loadObjectsFromDataStore];
        [self initUI];
        [self refreshCrosses:@"crossupdateview"];
        NSString *newuser=[[NSUserDefaults standardUserDefaults] objectForKey:@"NEWUSER"];
        if(newuser !=nil && [newuser isEqualToString:@"YES"])
            [self showWelcome];
    }
    default_background=[UIImage imageNamed:@"x_titlebg_default.jpg"];

    CGFloat scaleFactor = 1.0;
    CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);

    if (default_background.size.width > targetSize.width || default_background.size.height > targetSize.height){
        scaleFactor = MAX((targetSize.width / default_background.size.width), (targetSize.height / default_background.size.height));
    }
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect rect = CGRectMake((targetSize.width / 2 - default_background.size.width / 2 * scaleFactor),(0 - default_background.size.height * 198.0f / 495.0f * scaleFactor),default_background.size.width * scaleFactor,default_background.size.height * scaleFactor);
    [default_background drawInRect:rect];
    default_background = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)initUI{
    UIImage *gatherbtnimg = [UIImage imageNamed:@"gather_blue.png"];
    UIButton *gatherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gatherButton setImage:gatherbtnimg forState:UIControlStateNormal];
    gatherButton.frame = CGRectMake(0, 0, gatherbtnimg.size.width, gatherbtnimg.size.height);
    [gatherButton setBackgroundImage:[[UIImage imageNamed:@"btn_dark.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0,5)] forState:UIControlStateNormal];

    [gatherButton addTarget:self action:@selector(ShowGatherView) forControlEvents:UIControlEventTouchUpInside];
    gatherButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:gatherButton] autorelease];
    [self.navigationController navigationBar].topItem.rightBarButtonItem=gatherButtonItem;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImage *settingbtnimg = [UIImage imageNamed:@"portrait_default.png"];

    settingButton = [[EXInnerButton alloc] initWithFrame:CGRectMake(2, 6, 30, 30)];
    [settingButton addTarget:self action:@selector(ShowProfileView) forControlEvents:UIControlEventTouchUpInside];
    settingButton.image=settingbtnimg;
    settingButton.layer.cornerRadius=5.5f;
    settingButton.clipsToBounds = YES;

    [self refreshPortrait];
    
    UIView *containview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 44)];
    containview.backgroundColor=[UIColor clearColor];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_avatar_effect.png"]];
    shadowImageView.contentMode = UIViewContentModeScaleToFill;
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowImageView.frame = settingButton.bounds;
    [settingButton addSubview:shadowImageView];

    [containview addSubview:settingButton];
    profileButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:containview] autorelease];
    [self.navigationController navigationBar].topItem.leftBarButtonItem=profileButtonItem;
    
    [shadowImageView release];
    [containview release];
    
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font =[UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    label.shadowOffset= CGSizeMake(0, -1);
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.text = app.username;
    [self.navigationController navigationBar].topItem.titleView = label;
    
    UINavigationBar *navbar=[self.navigationController navigationBar];
    [navbar setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
//    if(navbar)
//    {
//        [navbar setBackgroundImage:[UIImage imageNamed:@"navbar_bg.png"]  forBarMetrics:UIBarMetricsDefault];
//    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.view setNeedsDisplay];
    
}

- (void) refreshPortrait{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0){
        User *user=[users objectAtIndex:0];
        
        if(user){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar_img=[[ImgCache sharedManager] getImgFrom:user.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar_img!=nil && ![avatar_img isEqual:[NSNull null]]){
                        settingButton.image=avatar_img;
                        [settingButton setNeedsDisplay];
                    }
                });
            });
            dispatch_release(imgQueue);
        }
    }
    [users release];
}
- (void) showWelcome{
    WelcomeView *welcome=[[WelcomeView alloc] initWithFrame:CGRectMake(4, tableView.frame.origin.y+4, self.view.frame.size.width-4-4, self.view.frame.size.height-44-4-4)];
    [welcome setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5f]];
    welcome.parent=self;

    [self.view addSubview:welcome];
    [self.view bringSubviewToFront:welcome];
    self.tableView.bounces=NO;
    [welcome release];
    
}
- (void) closeWelcome{
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[WelcomeView class]])
        {
            [view removeFromSuperview];
        }
    }
    self.tableView.bounces=YES;
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"NEWUSER"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (Cross*) crossWithId:(int)cross_id{
    for(Cross *c in _crosses)
    {
        if([c.cross_id intValue]==cross_id)
            return c;
    }
    return nil;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void)dealloc {
    if(_crosses){
        [_crosses release];
        _crosses=nil;
    }
//    if(cellDateTime){
//        [cellDateTime release];
//        cellDateTime=nil;
//    }
    [settingButton release];
    [gatherax release];
    [customStatusBar release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    BOOL login=[app Checklogin];
    if(login==YES)
    {
        [self refreshPortrait];
        [self refreshCrosses:@"crossupdateview"];
    }
    else {
        [app ShowLanding];
    }
}

- (void)ShowProfileView{
    ProfileViewController *profileViewController=[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profileViewController animated:YES];
    [profileViewController release];
    
}
- (void)ShowGatherView{
    NewGatherViewController *gatherViewController=[[NewGatherViewController alloc]initWithNibName:@"NewGatherViewController" bundle:nil];
    
    [self.navigationController presentModalViewController:gatherViewController animated:YES];
    [gatherViewController release];
}

- (void) refreshCrosses:(NSString*)source{
    [self refreshCrosses:(NSString*)source withCrossId:0];
}
- (void) refreshCrosses:(NSString*)source withCrossId:(int)cross_id{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *updated_at=@"";
    NSDate *date_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"]; 
    if(date_updated_at!=nil)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        updated_at = [formatter stringFromDate:date_updated_at];
        [formatter release];
    }
    if([source isEqualToString:@"crossview_init"]){
        hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        hud.mode=MBProgressHUDModeCustomView;
        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
        [bigspin startAnimating];
        hud.customView=bigspin;
        [bigspin release];
    }
        
    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at delegate:self source:[NSDictionary dictionaryWithObjectsAndKeys:source,@"name",[NSNumber numberWithInt:cross_id],@"cross_id", nil]];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadObjectsFromDataStore {
	NSFetchRequest* request = [Cross fetchRequest];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    [_crosses release];
    _crosses=[[Cross objectsWithFetchRequest:request] retain];
//    for(Cross *c in _crosses){
//        NSLog(@"%@",c.title);
//    }
    [self.tableView reloadData];
}
- (void)refresh
{
    [self refreshCrosses:@"crossupdateview"];
}
- (void)emptyView{

    [_crosses release];
    _crosses=nil;
    [self.tableView reloadData];
}
- (BOOL) isIdentityBelongsMe:(int)identity_id{
    NSArray *identities=[[NSUserDefaults standardUserDefaults] objectForKey:@"default_user_identities"];
    for (NSNumber *_identity_id in identities)
        if([_identity_id intValue]==identity_id)
            return YES;
    
    return NO;
}
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    int notification=0;
    if([objects count]>0)
    {
        NSString *source=[objectLoader.userData objectForKey:@"name" ];
        NSString *exfee_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];

        NSDate *last_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];

        BOOL needsave=NO;
        BOOL isError=NO;
        for(id object in objects)
        {
            
            if([object isKindOfClass:[Meta class]]){
                Meta *meta=object;
                if([meta.code intValue]!=200)
                {
                    [Util showError:meta delegate:self];
                    isError=YES;
                }
            }
            else if([object isKindOfClass:[Cross class]])
            {
                
                Cross *cross=(Cross*)object;
                id updated=cross.updated;
                if([updated isKindOfClass:[NSDictionary class]]){
                    NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
                    NSString *key=nil;
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                    
                    while (key = [enumerator nextObject]){
                        NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                        NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                        NSDate *updated_at =[NSDate date];
                        if([updated_at_str isKindOfClass:[NSString class]])
                        {
                            if([updated_at_str length]>19)
                                updated_at_str=[updated_at_str substringToIndex:19];
                            updated_at = [formatter dateFromString:updated_at_str];
                        if([updated_at compare: cross.updated_at] == NSOrderedDescending || [updated_at compare: cross.updated_at] == NSOrderedSame) {
                            if([[obj objectForKey:@"identity_id"] isKindOfClass:[NSNumber class]])
                            {
                                NSNumber *identity_id=[obj objectForKey:@"identity_id"];
                                if([self isIdentityBelongsMe:[identity_id intValue]]==NO)
                                    notification++;
                            }
                        }
                    }
                    }
                    [formatter release];
                }
                
                if(cross.updated_at!=nil)
                {
                    
                    if([source isEqualToString:@"crossview"]){
                        if(exfee_updated_at==nil){
                            cross.read_at=[NSDate date];
                            needsave=YES;
                        }
                    }
                    if(last_updated_at==nil)
                        last_updated_at=cross.updated_at;
                    else{
                        last_updated_at=[cross.updated_at laterDate:last_updated_at];
                    }
                }
            }
        }
        if(isError==NO)
        {
            if(needsave==YES)
                [[Cross currentContext] save:nil];
            [[NSUserDefaults standardUserDefaults] setObject:last_updated_at forKey:@"exfee_updated_at"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            if(![source isEqualToString:@"crossview"] && notification>0){
                
                [customStatusBar showWithStatusMessage:[NSString stringWithFormat:@"%i updates...",notification]];
                [customStatusBar performSelector:@selector(hide) withObject:nil afterDelay:2];
            }
            if ([[objectLoader.userData objectForKey:@"name"] isEqualToString:@"gatherview"]) {
                AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app.navigationController dismissModalViewControllerAnimated:YES];
            }
            else if([[objectLoader.userData objectForKey:@"name"] isEqualToString:@"pushtocross"]) {
//                NSNumber *cross_id=[objectLoader.userData objectForKey:@"cross_id"];
//                Cross *cross=[self crossWithId:[cross_id intValue]];
//                GatherViewController *gatherViewController=[[GatherViewController alloc] initWithNibName:@"GatherViewController" bundle:nil];
//                gatherViewController.cross=cross;
//                [gatherViewController setViewMode];
//                [self.navigationController pushViewController:gatherViewController animated:YES];
//                [gatherViewController release];
            }
            else if([[objectLoader.userData objectForKey:@"name" ] isEqualToString:@"pushtoconversation"]) {
//                NSNumber *cross_id=[objectLoader.userData objectForKey:@"cross_id"];
//                Cross *cross=[self crossWithId:[cross_id intValue]];
//                GatherViewController *gatherViewController=[[GatherViewController alloc] initWithNibName:@"GatherViewController" bundle:nil];
//                gatherViewController.cross=cross;
//                [gatherViewController setViewMode];
//                [self.navigationController pushViewController:gatherViewController animated:NO];
//                [gatherViewController toconversation];
//                [gatherViewController release];
            }
            else if([[objectLoader.userData objectForKey:@"name" ] isEqualToString:@"crossupdateview"] || [[objectLoader.userData objectForKey:@"name" ] isEqualToString:@"crossview"] || [[objectLoader.userData objectForKey:@"name" ] isEqualToString:@"crossview_init"]) {
//                NSString *refresh_cross_id=[objectLoader.userData objectForKey:@"cross_id" ];

                [self loadObjectsFromDataStore];
                [self.tableView reloadData];
            }
        }
    }

    [self stopLoading];
    if(hud)
        [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSString *errormsg=[error.userInfo objectForKey:@"NSLocalizedDescription"];
    if(error.code==2)
        errormsg=@"A connection failure has occurred.";
    else
        errormsg=@"Could not connect to the server.";
    if(alertShowflag==NO){
        alertShowflag=YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [self stopLoading];
    if(hud)
        [MBProgressHUD hideHUDForView:self.view animated:YES];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    if(buttonIndex==1 && alertView.tag==500){
        [Util signout];
        [app ShowLanding];
        
    }
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0){
        return 1;
    }else if (section == 1){
        if(_crosses == nil){
            return 0;
        }else{
            return [_crosses count];
        }
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSFetchRequest* request = [User fetchRequest];
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"user_id = %u", app.userid];
        [request setPredicate:predicate];
        NSArray *users = [[User objectsWithFetchRequest:request] retain];

        NSString* reuseIdentifier = @"Profile";
        ProfileCard *headerView =[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (nil == headerView) {
            headerView = [[ProfileCard alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Profile"];
        }
        
        if(users != nil && [users count] > 0){
            User *_user = [users objectAtIndex:0];
            NSString* imgName = _user.avatar_filename;
            headerView.avatar = nil;
            if(imgName && imgName.length > 0){
                UIImage *avatarImg=[[ImgCache sharedManager] getImgFromCache:imgName];
                if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
                    dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                    dispatch_async(imgQueue, ^{
                        NSLog(@"fetch profile img");
                        UIImage *avatar = [[ImgCache sharedManager] getImgFrom:imgName];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                                NSLog(@"fetched profile img");
                                headerView.avatar = avatar;
                                [headerView setNeedsDisplay];
                            }
                        });
                    });
                    dispatch_release(imgQueue);
                }else{
                    NSLog(@"Cache profile img");
                    headerView.avatar = avatarImg;
                }
            }
        }
        [headerView addGatherTarget:self action:@selector(ShowGatherView)];
        [headerView addProfileTarget:self action:@selector(ShowProfileView)];
        return headerView;
    }else if (indexPath.section == 1){
        if(_crosses==nil){
            return nil;
        }
        NSString* reuseIdentifier = @"Card Cell";
        CrossCard *cell =[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (nil == cell) {
            cell = [[[CrossCard alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
        }
        Cross *cross=[_crosses objectAtIndex:indexPath.row ];
        cell.hlTitle = NO;
        cell.hlPlace = NO;
        cell.hlTime = NO;
        cell.hlConversation = NO;
        if (cross.updated != nil){
            id updated = cross.updated;
            if([updated isKindOfClass:[NSDictionary class]]){
                NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
                NSString *key=nil;
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                
                while (key = [enumerator nextObject]){
                    NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                    NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                    NSDate *updated_at =[NSDate date];
                    if([updated_at_str isKindOfClass:[NSString class]]){
                        if([updated_at_str length]>19)
                            updated_at_str=[updated_at_str substringToIndex:19];
                        updated_at = [formatter dateFromString:updated_at_str];
                    }
                    if([updated_at compare: cross.read_at] == NSOrderedDescending || cross.read_at==nil) {
                        if([key isEqualToString:@"title"])
                            cell.hlTitle=YES;
                        else if([key isEqualToString:@"place"])
                            cell.hlPlace=YES;
                        else if([key isEqualToString:@"time"])
                            cell.hlTime=YES;
                        else if([key isEqualToString:@"conversation"])
                            cell.hlConversation=YES;
                    }
                }
                [formatter release];
            }
        }
        cell.title=cross.title;
        cell.conversationCount = [cross.conversation_count intValue];
        if(cross.place == nil){
            cell.place = @"";
        }else if (cross.place.title == nil || [cross.place.title isEqualToString:@""]){
            if ([cross.place hasGeo]) {
                cell.place = @"Somewhere"; // We did have location without title
            }else{
                cell.place = @"";
            }
        }else{
            cell.place = cross.place.title;
        }
        
        if (cross.time != nil){
            NSString *time = [cross.time getTimeTitle];
            //[time retain];
            if (time == nil || time.length == 0) {
                cell.time = @"";
            }else{
                NSString *tz = [cross.time.begin_at getTimeZoneString];
                if (tz != nil && tz.length > 0) {
                    cell.time = [NSString stringWithFormat:@"%@ %@", time, tz];
                }else{
                    cell.time = [NSString stringWithFormat:@"%@", time];;
                }
            }
            //[time release];
        }else{
            cell.time = @"";
        }
//
        cell.avatar = nil;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        for(Invitation *invitation in cross.exfee.invitations) {
            if ([invitation.identity.connected_user_id intValue]== app.userid) {
                if(invitation && invitation.invited_by &&
                   invitation.invited_by.avatar_filename ) {
                    UIImage *avatarImg=[[ImgCache sharedManager] getImgFromCache:invitation.invited_by.avatar_filename];
                    if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
                        dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                        dispatch_async(imgQueue, ^{
                            UIImage *avatar = [[ImgCache sharedManager] getImgFrom:invitation.invited_by.avatar_filename];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                                    cell.avatar=avatar;
                                }
                            });
                        });
                        dispatch_release(imgQueue);
                    }else{
                        cell.avatar = avatarImg;
                        [cell setNeedsDisplay];
                    }
                }else{
                    cell.avatar = nil;
                }
                break;
            }
        }
        
        NSArray *widgets = cross.widget;
        BOOL hasBackImage=NO;
        for(NSDictionary *widget in widgets) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                NSString *imgurl=[Util getBackgroundLink:[widget objectForKey:@"image"]];
                hasBackImage=YES;
                CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);
                UIImage *backimg=[[ImgCache sharedManager] getImgFromCache:imgurl withSize:targetSize];
                if(backimg == nil || [backimg isEqual:[NSNull null]]){
                    cell.bannerimg=nil;
//                    cell.bannerimg = default_background;
                }
                
//                if(backimg == nil || [backimg isEqual:[NSNull null]]){
                        dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
                        dispatch_async(imgQueue, ^{
                            UIImage *image=[[ImgCache sharedManager] getImgFrom:imgurl withSize:targetSize];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(image!=nil && ![image isEqual:[NSNull null]]){
                                    cell.bannerimg = image;
                                }else{
                                    cell.bannerimg=nil;
                                }
                            });
                        });
                        dispatch_release(imgQueue);
//                    }else{
//                        cell.bannerimg = backimg;
//                    }
                    break;
            }
        }
//        if(hasBackImage==NO){
//            cell.bannerimg = default_background;//[UIImage imageNamed:@"x_titlebg_default.jpg"];
//        }
        cell.delegate = self;
        cell.cross_id = cross.cross_id;
        
        return cell;
    }else{
        return nil;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 66;
    }else {
        return 90.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        Cross *cross=[_crosses objectAtIndex:indexPath.row];
        if(cross.updated!=nil)
        {
            id updated=cross.updated;
            if([updated isKindOfClass:[NSDictionary class]]){
                NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
                NSString *key=nil;
                
                while (key = [enumerator nextObject]){
                    NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                    NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                    if(updated_at_str!=nil && [updated_at_str length]>19)
                        updated_at_str=[updated_at_str substringToIndex:19];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                    NSDate *updated_at = [formatter dateFromString:updated_at_str];
                    [formatter release];
                    if(cross.read_at==nil)
                        cross.read_at=updated_at;
                    else
                        cross.read_at=[cross.read_at laterDate:updated_at];
                }
                NSError *saveError;
                [[Cross currentContext] save:&saveError];
                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                                      withRowAnimation: UITableViewRowAnimationNone];
            }
            
        }
//        GatherViewController *gatherViewController=[[GatherViewController alloc] initWithNibName:@"GatherViewController" bundle:nil];
//        gatherViewController.cross=cross;
//        [gatherViewController setViewMode];
//        [self.navigationController pushViewController:gatherViewController animated:YES];
//        [gatherViewController release];
        CrossDetailViewController *viewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
        viewController.cross = cross;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        current_cellrow = indexPath.row;
    }
}
- (void) refreshTableViewWithCrossId:(int)cross_id{
    for(int i=0;i<[_crosses count];i++)
    {
        
        Cross *c=[_crosses objectAtIndex:i];
        
        
        if([c.cross_id intValue]==cross_id)
            [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:i inSection:1]]
                                  withRowAnimation: UITableViewRowAnimationNone];
    }
}
- (void) refreshCell{
    
    if(current_cellrow>=0)
        [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:current_cellrow inSection:0]]
                          withRowAnimation: UITableViewRowAnimationNone];

    current_cellrow=-1;
}

- (void) alertsignout{
    [Util signout];
}

- (void)gotoCrossDetail{
    CrossDetailViewController *viewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma mark View Push methods
- (BOOL) PushToCross:(int)cross_id{
    Cross *cross = [self crossWithId:cross_id];
    if(cross != nil){
//        GatherViewController *gatherViewController=[[GatherViewController alloc] initWithNibName:@"GatherViewController" bundle:nil];
//        gatherViewController.cross=cross;
//        [gatherViewController setViewMode];
//        [self.navigationController pushViewController:gatherViewController animated:YES];
//        [gatherViewController release];
        return YES;
    }
    return NO;
}



- (BOOL) PushToConversation:(int)cross_id{
    Cross *cross=[self crossWithId:cross_id];
    if(cross!=nil){
//        GatherViewController *gatherViewController=[[GatherViewController alloc] initWithNibName:@"GatherViewController" bundle:nil];
//        
//        gatherViewController.cross=cross;
//        [gatherViewController setViewMode];
//        [self.navigationController pushViewController:gatherViewController animated:YES];
//        [gatherViewController toconversation];
//        [gatherViewController release];
        return YES;
    }
    return NO;
}


#pragma mark CrossCardDelegate
- (void) onClickConversation:(UIView*)card{
    CrossCard* c = (CrossCard*)card;
    int cross_id = [c.cross_id intValue];
    
    Cross *cross = [self crossWithId:cross_id];
    if(cross != nil){
        CrossDetailViewController *viewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
        viewController.cross = cross;
        [self.navigationController pushViewController:viewController animated:NO];
        [viewController toConversationAnimated:NO];
        [viewController release];
    }
}

@end
