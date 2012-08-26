//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import "ProfileViewController.h"
#import "GatherViewController.h"
#import "APICrosses.h"
#import "Cross.h"
#import "Place.h"
#import "Exfee.h"
#import "Identity.h"
#import "CrossTime.h"
#import "EFTime.h"
#import "CrossTime.h"
#import "Rsvp.h"
#import "CrossCell.h"
#import "ImgCache.h"
#import "Util.h"

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
    current_cellrow=-1;
    self.tableView.backgroundColor=[UIColor colorWithRed:0.27f green:0.33f blue:0.41f alpha:1.00f];
    UIView *topview = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - 480, 320, 480)];
    topview.backgroundColor=[UIColor colorWithRed:0.64f green:0.69f blue:0.77f alpha:1.00f];
    [self.tableView addSubview:topview];
    [topview release];
    [super viewDidLoad];

    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self loadObjectsFromDataStore];
    cellbackimglist=[[NSArray alloc] initWithObjects:[UIImage imageNamed:@"cell_0_card.png"],[UIImage imageNamed:@"cell_1_card.png"],[UIImage imageNamed:@"cell_2_card.png"],[UIImage imageNamed:@"cell_3_card.png"], [UIImage imageNamed:@"cell_4_card.png"], nil ];
//
    cellbackimgblanklist=[[NSArray alloc] initWithObjects:[UIImage imageNamed:@"cell_0_null.png"],[UIImage imageNamed:@"cell_1_null.png"],[UIImage imageNamed:@"cell_2_null.png"],[UIImage imageNamed:@"cell_3_null.png"], [UIImage imageNamed:@"cell_4_null.png"], nil];
    
    BOOL login=[app Checklogin];
    if(login==YES)
    {
        [self initUI];
        [self refreshCrosses:@"crossview"];
    }
}
- (void)initUI{
    UIImage *gatherbtnimg = [UIImage imageNamed:@"gather_button.png"];
    UIButton *gatherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gatherButton setImage:gatherbtnimg forState:UIControlStateNormal];
    gatherButton.frame = CGRectMake(0, 0, gatherbtnimg.size.width, gatherbtnimg.size.height);
    [gatherButton addTarget:self action:@selector(ShowGatherView) forControlEvents:UIControlEventTouchUpInside];
    gatherButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:gatherButton] autorelease];
    [self.navigationController navigationBar].topItem.rightBarButtonItem=gatherButtonItem;
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    UIImage *settingbtnimg = [UIImage imageNamed:@"navbar_setting.png"];
    if(users!=nil && [users count] >0){
        User *user=[users objectAtIndex:0];
        if(user){
            Identity *identity=user.default_identity;
            UIImage *image = [[ImgCache sharedManager] getImgFrom:[ImgCache getImgUrl:identity.avatar_filename]];
            settingbtnimg = image;
        }
    }
    UIView *containview=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 44)];
    containview.backgroundColor=[UIColor clearColor];
    EXInnerButton *settingButton = [[EXInnerButton alloc] initWithFrame:CGRectMake(2, 6, 30, 30)];
    settingButton.image=settingbtnimg;
    [settingButton addTarget:self action:@selector(ShowProfileView) forControlEvents:UIControlEventTouchUpInside];
    settingButton.layer.cornerRadius=5.5f;
    settingButton.clipsToBounds = YES;
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_avatar_effect.png"]];
    shadowImageView.contentMode = UIViewContentModeScaleToFill;
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    shadowImageView.frame = settingButton.bounds;
    [settingButton addSubview:shadowImageView];

    [containview addSubview:settingButton];
    profileButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:containview] autorelease];
    [self.navigationController navigationBar].topItem.leftBarButtonItem=profileButtonItem;
    
    [shadowImageView release];
    [settingButton release];
    [containview release];
    
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    label.backgroundColor = [UIColor clearColor];
    [FONT_COLOR_233 set];
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
    [self.navigationController.view setNeedsDisplay];
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
    if(cellDateTime){
        [cellDateTime release];
        cellDateTime=nil;
    }
    [cellbackimglist release];
    [cellbackimgblanklist release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    BOOL login=[app Checklogin];
    if(login==YES)
    {
        [self refreshCrosses:@"crossview"];
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
    GatherViewController *gatherViewController=[[GatherViewController alloc]initWithNibName:@"GatherViewController" bundle:nil];
    
    [self.navigationController presentModalViewController:gatherViewController animated:YES];
}

- (void) refreshCrosses:(NSString*)source{
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

    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at delegate:self source:source];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadObjectsFromDataStore {
	[_crosses release];
	NSFetchRequest* request = [Cross fetchRequest];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];

	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	_crosses = [[Cross objectsWithFetchRequest:request] retain];
        if(_crosses){
            if(cellDateTime){
                [cellDateTime release];
                cellDateTime=nil;
            }
            cellDateTime=[[NSMutableArray alloc] initWithCapacity:[_crosses count]];
            for(Cross *cross in _crosses)
            {
                NSDictionary *humanable_date=[Util crossTimeToString:cross.time];
                [cellDateTime addObject:humanable_date];
            }
    }
    
    [self.tableView reloadData];
}
- (void)refresh
{
    [self refreshCrosses:@"crossview"];
}
- (void)emptyView{
    
    NSArray *cells=self.tableView.visibleCells;
    for (CrossCell* cell in cells) {
        cell.removed=YES;
        cell.title =@"";
    }

    [_crosses release];
    _crosses=nil;
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    if([objects count]>0)
    {
//        NSDate *date_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
        
        Cross *cross=[objects lastObject];
        [[NSUserDefaults standardUserDefaults] setObject:cross.updated_at forKey:@"exfee_updated_at"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self loadObjectsFromDataStore];
    }
    if ([objectLoader.userData isEqualToString:@"gatherview"]) {
        AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [app.navigationController dismissModalViewControllerAnimated:YES];
    }
    [self stopLoading];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
    [self stopLoading];
}


#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if([_crosses count]==0)
        return 0;
    if([_crosses count]<4 && [_crosses count]>0)
        return 4;
	return [_crosses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"cross Cell";
    CrossCell *cell =[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
        cell = [[[CrossCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
	}
    
    if(indexPath.row>=[_crosses count])
    {
        cell.backgroundimg=[cellbackimgblanklist objectAtIndex:indexPath.row];
        cell.isbackground=YES;
        return cell;
    }
    else if(indexPath.row<=4)
        cell.backgroundimg=[cellbackimglist objectAtIndex:indexPath.row];
    else if(indexPath.row>4)
        cell.backgroundimg=[cellbackimglist objectAtIndex:4];
    Cross *cross=[_crosses objectAtIndex:indexPath.row];
    cell.removed=NO;
    cell.hlTitle=NO;
    cell.hlPlace=NO;
    cell.hlTime=NO;
    cell.hlExfee=NO;
    cell.hlConversation=NO;
    
    if(cross.updated!=nil)
    {
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
                //FIXME: in old redis, the updated_at_str is a number. 
                if([updated_at_str isKindOfClass:[NSString class]])
                    updated_at = [formatter dateFromString:updated_at_str];
                if([updated_at compare: cross.read_at] == NSOrderedDescending || cross.read_at==nil) {
                    if([key isEqualToString:@"title"])
                        cell.hlTitle=YES;
                    else if([key isEqualToString:@"place"])
                        cell.hlPlace=YES;
                    else if([key isEqualToString:@"time"])
                        cell.hlTime=YES;
                    else if([key isEqualToString:@"exfee"])
                        cell.hlExfee=YES;
                    else if([key isEqualToString:@"conversation"])
                        cell.hlConversation=YES;
                }
            }
            [formatter release];
        }
    }
    cell.title=cross.title;
    cell.conversationCount=[cross.conversation_count intValue];
    if(cross.place.title == nil || [cross.place.title isEqualToString:@""])
        cell.place=@"Somewhere";
    else
        cell.place=cross.place.title;
    cell.accepted=[cross.exfee.accepted intValue];
    cell.total=[cross.exfee.total intValue];
    if([cross.time.begin_at.date isEqualToString:@""])
    {
        cell.showDetailTime=NO;
        if([cross.time.origin isEqualToString:@""])
            cell.time=@"Sometime";
        else
            cell.time=cross.time.origin;
    }else{
//        NSDictionary *humanable_date=[Util crossTimeToString:cross.time];
        NSDictionary *humanable_date=[cellDateTime objectAtIndex:indexPath.row];
        cell.time=[humanable_date objectForKey:@"short"];
        cell.showDetailTime=YES;
        if([humanable_date objectForKey:@"day"]== nil || [humanable_date objectForKey:@"month"]==nil)
            cell.showDetailTime=NO;
        else{
        cell.time_day=[humanable_date objectForKey:@"day"];
        cell.time_month=[humanable_date objectForKey:@"month"];
        }
    }

//TODO:Add avatar
//    if(cross.by_identity.avatar_filename!=nil) {
//        dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
//        dispatch_async(imgQueue, ^{
//            UIImage *avatar = [[ImgCache sharedManager] getImgFrom:cross.by_identity.avatar_filename];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
//                    cell.avatar=avatar;
//                }
//            });
//        });
//        dispatch_release(imgQueue);        
//    }
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

    GatherViewController *gatherViewController=[[GatherViewController alloc] initWithNibName:@"GatherViewController" bundle:nil];
    gatherViewController.cross=cross;
    [gatherViewController setViewMode]; 
    
    [self.navigationController pushViewController:gatherViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    current_cellrow=indexPath.row;
}
- (void) refreshCell{
    
    if(current_cellrow>=0)
        [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow:current_cellrow inSection:0]]
                          withRowAnimation: UITableViewRowAnimationNone];

    current_cellrow=-1;
}

@end
