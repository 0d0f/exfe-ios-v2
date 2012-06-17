//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import "CrossDetailViewController.h"
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
    [super viewDidLoad];    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSLog(@"doc path:%@",documentsDirectory);
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self loadObjectsFromDataStore];
    BOOL login=[app Checklogin];
    if(login==YES)
    {
        [self refreshCrosses:@"crossview"];
        [self initUI];
    }
}
- (void)initUI{
    
    UIImage *settingbtnimg = [UIImage imageNamed:@"navbar_setting.png"];   
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:settingbtnimg forState:UIControlStateNormal];
    settingButton.frame = CGRectMake(0, 0, settingbtnimg.size.width, settingbtnimg.size.height);
    [settingButton addTarget:self action:@selector(ShowProfileView) forControlEvents:UIControlEventTouchUpInside];
    profileButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingButton] autorelease];

    UIImage *gatherbtnimg = [UIImage imageNamed:@"navbar_setting.png"];
    UIButton *gatherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [gatherButton setImage:gatherbtnimg forState:UIControlStateNormal];
    gatherButton.frame = CGRectMake(0, 0, gatherbtnimg.size.width, gatherbtnimg.size.height);
    [gatherButton addTarget:self action:@selector(ShowGatherView) forControlEvents:UIControlEventTouchUpInside];
    gatherButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:gatherButton] autorelease];
    
    [self.navigationController navigationBar].topItem.leftBarButtonItem=profileButtonItem;
    [self.navigationController navigationBar].topItem.rightBarButtonItem=gatherButtonItem;

    [self.navigationController.view setNeedsDisplay];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    //[crossapi release];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
	[_crosses release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"appear");
    
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
//        2012-04-24 07:06:13 +0000
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
//    request.includesPendingChanges=YES;
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	_crosses = [[Cross objectsWithFetchRequest:request] retain];

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
#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"success:%@",objects);
    NSLog(@"%@",objectLoader.userData);
    if([objects count]>0)
    {
        NSDate *date_updated_at=[[NSUserDefaults standardUserDefaults] objectForKey:@"exfee_updated_at"];
//        if(date_updated_at==nil)
//        {
//            NSDate *now = [NSDate date];
//            for( Cross *cross in objects)
//            {
//                cross.read_at=now;
//                NSError *saveError;
//                [[Cross currentContext] save:&saveError];
//            }
//
//            NSLog(@"the first loading");
//        }

        
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
	return [_crosses count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"cross Cell";
    CrossCell *cell =[self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
        cell = [[[CrossCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
	}
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
                NSDate *updated_at = [formatter dateFromString:updated_at_str];
                if([updated_at compare: cross.read_at] == NSOrderedDescending) // if start is later in time than end
                {
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
    cell.place=cross.place.title;
    NSDictionary *humanable_date=[Util crossTimeToString:cross.time];
    cell.time=[humanable_date objectForKey:@"date"];
    if(cross.by_identity.avatar_filename!=nil) {
        dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
        dispatch_async(imgQueue, ^{
            UIImage *avatar = [[ImgCache sharedManager] getImgFrom:cross.by_identity.avatar_filename];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(avatar!=nil && ![avatar isEqual:[NSNull null]]) {
                    cell.avatar=avatar;
                }
            });
        });
        dispatch_release(imgQueue);        
    }
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cross *cross=[_crosses objectAtIndex:indexPath.row]; 
    NSLog(@"cross.read_at: %@",cross.read_at);
//    if(cross.read_at==nil) {
//        cross.read_at=[NSDate date];
//        NSError *saveError;
//        [[Cross currentContext] save:&saveError];
//    }
//find the biggest time in the update object
    if(cross.updated!=nil)
    {
        id updated=cross.updated;
        if([updated isKindOfClass:[NSDictionary class]]){
            NSEnumerator *enumerator=[(NSDictionary*)updated keyEnumerator];
            NSString *key=nil;
            
            while (key = [enumerator nextObject]){
                NSDictionary *obj=[(NSDictionary*) updated objectForKey:key];
                NSString *updated_at_str=[obj objectForKey:@"updated_at"];
                NSLog(@"%@ , %@ %@",key,obj,cross.read_at);
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                NSDate *updated_at = [formatter dateFromString:updated_at_str];
                [formatter release];
                NSLog(@"laterdate:%@",[cross.read_at laterDate:updated_at]);
                cross.read_at=[cross.read_at laterDate:updated_at];
            }
            NSError *saveError;
            [[Cross currentContext] save:&saveError];
            [self.tableView reloadRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                             withRowAnimation: UITableViewRowAnimationNone];
        }

    }
    CrossDetailViewController *detailViewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
    detailViewController.cross=cross;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
