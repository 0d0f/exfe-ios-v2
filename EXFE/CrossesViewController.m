//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import "ProfileViewController.h"
#import "APICrosses.h"
#import "Cross.h"
#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import "Identity+EXFE.h"
#import "Rsvp.h"
#import "CrossCard.h"
#import "ImgCache.h"
#import "Util.h"
#import "CrossTime+Helper.h"
#import "EFTime+Helper.h"
#import "Place+Helper.h"

#import "CrossGroupViewController.h"


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
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL login=[app Checklogin];
    if(login==YES) {
        [self loadObjectsFromDataStore];
        [self initUI];
        [self refreshCrosses:@"crossupdateview"];
//        NSString *newuser=[[NSUserDefaults standardUserDefaults] objectForKey:@"NEWUSER"];
//        if(newuser !=nil && [newuser isEqualToString:@"YES"])
//            [self showWelcome];
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
    
    label_profile = [[UILabel alloc] initWithFrame:CGRectMake(15, 70, 130, 31)];
    label_profile.backgroundColor = [UIColor clearColor];
    label_profile.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    label_profile.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label_profile.text = @"Manage identities to \nreveal who your are.";
    label_profile.numberOfLines = 2;
    [label_profile sizeToFit];
    //label_profile.hidden = YES;
    [self.view addSubview:label_profile];
    
    label_gather = [[UILabel alloc] initWithFrame:CGRectMake(220, 70, 130, 31)];
    label_gather.backgroundColor = [UIColor clearColor];
    label_gather.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    label_gather.textAlignment = NSTextAlignmentRight;
    label_gather.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label_gather.text = @"Hang out with\n friends.";
    label_gather.numberOfLines = 2;
    [label_gather sizeToFit];
    //label_gather.hidden = YES;
    label_gather.frame = CGRectOffset(label_gather.frame, 305 - CGRectGetMaxX(label_gather.frame), 0);
    [self.view addSubview:label_gather];
    
    welcome_exfe = [[EXAttributedLabel alloc] initWithFrame:CGRectMake(32, 250, 260, 35)];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"Welcome to EXFE"];
    CTFontRef fontref=CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), 30.0, NULL);
    [attrStr addAttribute:(NSString*)kCTFontAttributeName value:(id)fontref range:NSMakeRange(0, [attrStr length])];
    [attrStr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_BLACK].CGColor range:NSMakeRange(0,11)];
    [attrStr addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor COLOR_BLUE_EXFE].CGColor range:NSMakeRange(11,4)];
    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting paragraphsetting[3] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
    };
    CTParagraphStyleRef paragraphstyle = CTParagraphStyleCreate(paragraphsetting, 3);
    [attrStr addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphstyle range:NSMakeRange(0,[attrStr length])];
    CFRelease(paragraphstyle);
    CFRelease(fontref);
    welcome_exfe.attributedText = attrStr;
    [attrStr release];
    welcome_exfe.backgroundColor = [UIColor clearColor];
    //welcome_exfe.hidden = YES;
    welcome_exfe.frame = CGRectOffset(welcome_exfe.frame, 160 - CGRectGetMidX(welcome_exfe.frame), 0);
    [self.view addSubview:welcome_exfe];
    
    welcome_more = [[UILabel alloc] initWithFrame:CGRectMake(32, 285, 300, 23)];
    welcome_more.backgroundColor = [UIColor clearColor];
    welcome_more.textColor = [UIColor COLOR_WA(0x6B, 0xFF)];
    welcome_more.textAlignment = NSTextAlignmentRight;
    welcome_more.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    welcome_more.text = @"A utility for gathering with friends.";
    [welcome_more sizeToFit];
    //welcome_more.hidden = YES;
    welcome_more.frame = CGRectOffset(welcome_more.frame, 160 - CGRectGetMidX(welcome_more.frame), 0);
    [self.view addSubview:welcome_more];
    
    [self refreshWelcome];
    
}

- (void)initUI{

    [self refreshPortrait];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController.view setNeedsDisplay];
    
    
    
}

- (void) refreshPortrait{
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
  [request setPredicate:predicate];
  
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];

    if(users!=nil && [users count] >0){
        User *user=[users objectAtIndex:0];
        
        if(user){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar_img=[[ImgCache sharedManager] getImgFrom:user.avatar_filename];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar_img!=nil && ![avatar_img isEqual:[NSNull null]]){
//                        settingButton.image=avatar_img;
//                        [settingButton setNeedsDisplay];
                    }
                });
            });
            dispatch_release(imgQueue);
        }
    }
//    [users release];
}
// deprecated
- (void) showWelcome{
    WelcomeView *welcome=[[WelcomeView alloc] initWithFrame:CGRectMake(4, tableView.frame.origin.y+4, self.view.frame.size.width-4-4, self.view.frame.size.height-44-4-4)];
    [welcome setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5f]];
    welcome.parent=self;

    [self.view addSubview:welcome];
    [self.view bringSubviewToFront:welcome];
    self.tableView.bounces=NO;
    [welcome release];
    
}
// deprecated
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
//    [settingButton release];
//    [gatherax release];
    [customStatusBar release];
    [label_profile release];
    [label_gather release];
    [welcome_exfe release];
    [welcome_more release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    BOOL login=[app Checklogin];
    if(login==YES)
    {
      //RESTKIT 0.20
//        [self refreshPortrait];
//        [self refreshCrosses:@"crossupdateview"];
    }
    else {
        [app ShowLanding];
    }
}

- (void)ShowProfileView{
    RKObjectManager *manager=[RKObjectManager sharedManager];
    [manager.HTTPClient.operationQueue cancelAllOperations];
    ProfileViewController *profileViewController=[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    profileViewController.user = [User getDefaultUser];
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
//        hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.labelText = @"Loading";
//        hud.mode=MBProgressHUDModeCustomView;
//        EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
//        [bigspin startAnimating];
//        hud.customView=bigspin;
//        [bigspin release];
    }
  
    //  source:[NSDictionary dictionaryWithObjectsAndKeys:source,@"name",[NSNumber numberWithInt:cross_id],@"cross_id", nil]
    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

        int notification=0;
        if([[mappingResult array] count]>0)
        {
        //        NSString *source=[objectLoader.userData objectForKey:@"name" ];
//          NSString *exfee_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
          NSDate *last_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
//          BOOL needsave=NO;
          BOOL isError=NO;
          Meta *meta=(Meta*)[[mappingResult dictionary] objectForKey:@"meta"];
          if(meta!=nil){
            if([meta.code intValue]!=200){
              [Util showError:meta delegate:self];
              isError=YES;
            }
          }
          if(isError==NO){
            NSArray *crosses=(NSArray*)[[mappingResult dictionary] objectForKey:@"response.crosses"];
            for (Cross *cross in crosses){
              id updated=cross.updated;
              NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
              [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
              [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
              NSDate *cross_updated_at = [formatter dateFromString:cross.updated_at];
              [formatter release];

              if([updated isKindOfClass:[NSDictionary class]]){
                  NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
                  NSString *key=nil;
                  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                  [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                  [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
              
                  while (key = [enumerator nextObject]){
                      NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                      NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                      if([updated_at_str isKindOfClass:[NSString class]]) {
                          NSDate *updated_at =[NSDate date];
                          if([updated_at_str length]>19){
                              updated_at_str=[updated_at_str substringToIndex:19];
                              updated_at = [formatter dateFromString:updated_at_str];
                            
                              if(last_updated_at==nil)
                                last_updated_at=updated_at;
                              else{
                                last_updated_at=[updated_at laterDate:last_updated_at];
                              }

                            
                          }

                          if([updated_at compare: cross_updated_at] == NSOrderedDescending || [updated_at compare: cross_updated_at] == NSOrderedSame) {
                              if([[obj objectForKey:@"identity_id"] isKindOfClass:[NSNumber class]]) {
                                  NSNumber *identity_id=[obj objectForKey:@"identity_id"];
                                  if([self isIdentityBelongsMe:[identity_id intValue]]==NO)
                                      notification++;
                              }
                          }
                      }
                  }
                  [formatter release];
              }
              NSLog(@"%i %@",[cross.cross_id intValue], cross.updated_at);
              if(cross.updated_at!=nil){
//                  if([source isEqualToString:@"crossview"]){
//                      if(exfee_updated_at==nil){
//                          cross.read_at=[NSDate date];
//                          needsave=YES;
//                      }
//                  }
                  if(last_updated_at==nil)
                      last_updated_at=cross_updated_at;
                  else{
                      last_updated_at=[cross_updated_at laterDate:last_updated_at];
                  }
              }
            }

            [[NSUserDefaults standardUserDefaults] setObject:last_updated_at forKey:@"exfee_updated_at"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if(![source isEqualToString:@"crossview"] && notification>0){
              [customStatusBar showWithStatusMessage:[NSString stringWithFormat:@"%i updates...",notification]];
              [customStatusBar performSelector:@selector(hide) withObject:nil afterDelay:2];
            }
            if ([source isEqualToString:@"gatherview"]) {
                AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                [app.navigationController dismissModalViewControllerAnimated:YES];
            }
            else if([source isEqualToString:@"pushtocross"]) {
                Cross *cross=[self crossWithId:cross_id];
                
                CrossGroupViewController *viewController=[[CrossGroupViewController alloc]initWithNibName:@"CrossGroupViewController" bundle:nil];
                viewController.cross = cross;
                viewController.widgetId = kWidgetCross;
                viewController.headerStyle = kHeaderStyleFull;
                [self.navigationController pushViewController:viewController animated:NO];
                [viewController release];
            }
            else if([source isEqualToString:@"pushtoconversation"]) {
//                NSNumber *cross_id=[objectLoader.userData objectForKey:@"cross_id"];
//                Cross *cross=[self crossWithId:[cross_id intValue]];
//                CrossGroupViewController *viewController=[[CrossGroupViewController alloc]initWithNibName:@"CrossGroupViewController" bundle:nil];
//                viewController.cross = cross;
//                viewController.widgetId = kWidgetConversation;
//                viewController.headerStyle = kHeaderStyleHalf;
//                [self.navigationController pushViewController:viewController animated:NO];
//                [viewController release];

            }
            else if([source isEqualToString:@"crossupdateview"] || [source isEqualToString:@"crossview"] || [source isEqualToString:@"crossview_init"]) {
            ////                NSString *refresh_cross_id=[objectLoader.userData objectForKey:@"cross_id" ];
            //
              [self loadObjectsFromDataStore];
            ////                [self.tableView reloadData];
            }
          }
        //        }
        //        if(isError==NO)
        //        {
        //            if(needsave==YES)
        //                [[Cross currentContext] save:nil];
        //
        }
        [self loadObjectsFromDataStore];
        [self.tableView reloadData];

        //
        [self stopLoading];
        if(hud)
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        
      } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSString *errormsg;
        if(error.code==2)
            errormsg=@"A connection failure has occurred.";
        else
            errormsg=@"Could not connect to the server.";
        if(alertShowflag==NO){
            alertShowflag=YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [self stopLoading];
        if(hud)
            [MBProgressHUD hideHUDForView:self.view animated:YES];
      }];
//    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at delegate:self source:[NSDictionary dictionaryWithObjectsAndKeys:source,@"name",[NSNumber numberWithInt:cross_id],@"cross_id", nil]];
  
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadObjectsFromDataStore {
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cross"];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
  RKObjectManager *objectManager = [RKObjectManager sharedManager];
  [_crosses release];
  _crosses = [[objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil] retain];
  
  [self refreshWelcome];
  [self.tableView reloadData];
    
}
- (void)refresh
{
    [self refreshCrosses:@"crossupdateview"];
}

- (NSInteger)getCrossCount{
    if (_crosses) {
        return _crosses.count;
    }
    return 0;
}

- (void)refreshWelcome{
    NSInteger count = [self getCrossCount];
    
    if (label_profile.hidden != (count > 0)) {
        label_profile.hidden = count > 0;
    }
    if (label_gather.hidden != (count > 0)) {
        label_gather.hidden = count > 0;
    }
    if (welcome_exfe.hidden != (count > 2)) {
        welcome_exfe.hidden = count > 2;
    }
    if (welcome_more.hidden != (count > 2)) {
        welcome_more.hidden = count > 2;
    }
}

- (void)emptyView{

    [_crosses release];
    _crosses = nil;
    [self refreshWelcome];
    [self.tableView reloadData];
}
- (BOOL) isIdentityBelongsMe:(int)identity_id{
    NSArray *identities=[[NSUserDefaults standardUserDefaults] objectForKey:@"default_user_identities"];
    for (NSNumber *_identity_id in identities)
        if([_identity_id intValue]==identity_id)
            return YES;
    
    return NO;
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
        return [self getCrossCount];
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
        [request setPredicate:predicate];
      
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
      
        NSArray *users = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
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
//                        NSLog(@"fetch profile img");
                        UIImage *avatar = [[ImgCache sharedManager] getImgFrom:imgName];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
//                                NSLog(@"fetched profile img");
                                headerView.avatar = avatar;
                                [headerView setNeedsDisplay];
                            }
                        });
                    });
                    dispatch_release(imgQueue);
                }else{
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
        cell.cross_id=cross.cross_id;
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
                cell.time = [NSString stringWithFormat:@"%@", time];
            }
            //[time release];
        }else{
            cell.time = @"";
        }
        
        NSString *avatarimgurl=nil;
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        for(Invitation *invitation in cross.exfee.invitations) {
            NSInteger connected_uid = [invitation.identity.connected_user_id intValue];
            if (connected_uid == app.userid) {
                if(invitation && invitation.invited_by &&
                   invitation.invited_by.avatar_filename ) {
                    avatarimgurl=invitation.invited_by.avatar_filename;
                    break;
                }
            }else if (connected_uid < 0){
                // Unverified identity: connected_uid + identity_git id == 0
                // Concern: performace issue?
//                NSFetchRequest* request = [User fetchRequest];
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_id = %u", app.userid];
//                [request setPredicate:predicate];
//                NSArray *users = [[User objectsWithFetchRequest:request] retain];
//                if(users != nil && [users count] > 0)
//                {
//                    User *_user = [users objectAtIndex:0];
//                    for(Identity *identity in _user.identities){
//                        if([identity.identity_id intValue] + connected_uid == 0){
//                            if(invitation && invitation.invited_by &&
//                               invitation.invited_by.avatar_filename ) {
//                                avatarimgurl = invitation.invited_by.avatar_filename;
//                            }
//                            break;
//                        }
//                    }
//                }
//                [users release];
            }
        }
        if(avatarimgurl==nil)
          cell.avatar = nil;
        else{
          UIImage *avatarImg=[[ImgCache sharedManager] getImgFromCache:avatarimgurl];
          if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
              UIImage *avatar = [[ImgCache sharedManager] getImgFrom:avatarimgurl];
              dispatch_async(dispatch_get_main_queue(), ^{
                if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                  cell.avatar=avatar;
                }
              });
            });
            dispatch_release(imgQueue);
          }else{
            cell.avatar = avatarImg;
          }
        }
      NSString *backimgurl=nil;
        NSArray *widgets = cross.widget;
        for(NSDictionary *widget in widgets) {
            if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
                backimgurl=[Util getBackgroundLink:[widget objectForKey:@"image"]];
            }
        }
      CGSize targetSize = CGSizeMake((320 - CARD_VERTICAL_MARGIN * 2) * [UIScreen mainScreen].scale, 44 * [UIScreen mainScreen].scale);
      if(backimgurl==nil || backimgurl.length<=5){
        cell.bannerimg=nil;
      }else{
        NSString *extname=[backimgurl substringFromIndex:[backimgurl length]-3];
        if([extname isEqualToString:@"bg/"]){
          cell.bannerimg=nil;
        }else{
          UIImage *backimg=[[ImgCache sharedManager] getImgFromCache:backimgurl withSize:targetSize];
          if(backimg != nil && ![backimg isEqual:[NSNull null]]){
            cell.bannerimg=backimg;
          }
          else
          {
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
              UIImage *image=[[ImgCache sharedManager] getImgFrom:backimgurl withSize:targetSize];
              cell.bannerimg=nil;
              dispatch_async(dispatch_get_main_queue(), ^{
                cell.bannerimg = image;
              });
            });
            dispatch_release(imgQueue);
          }
        }
      }

        cell.delegate = self;
      
        return cell;
    }else{
        return nil;
    }
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return 64;
    }else {
        return 90;
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
//                [[Cross currentContext] save:&saveError];
                [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                                      withRowAnimation: UITableViewRowAnimationNone];
            }
            
        }
        CrossGroupViewController *viewController=[[CrossGroupViewController alloc]initWithNibName:@"CrossGroupViewController" bundle:nil];
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

//- (void)gotoCrossDetail{
//    CrossDetailViewController *viewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
//    [self.navigationController pushViewController:viewController animated:YES];
//    [viewController release];
//}

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
        CrossGroupViewController *viewController=[[CrossGroupViewController alloc]initWithNibName:@"CrossGroupViewController" bundle:nil];
        viewController.cross = cross;
        viewController.widgetId = kWidgetConversation;
        viewController.headerStyle = kHeaderStyleHalf;
        [self.navigationController pushViewController:viewController animated:NO];
        [viewController release];
    }
}

@end
