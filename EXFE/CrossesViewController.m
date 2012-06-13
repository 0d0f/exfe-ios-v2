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
        [self refreshCrosses];
        [self initUI];
    }
}
- (void)initUI{
    UIImage *settingbtnimg = [UIImage imageNamed:@"navbar_setting.png"];   
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:settingbtnimg forState:UIControlStateNormal];
    settingButton.frame = CGRectMake(0, 0, settingbtnimg.size.width, settingbtnimg.size.height);
    [settingButton addTarget:self action:@selector(ShowProfileView) forControlEvents:UIControlEventTouchUpInside];
    barButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingButton] autorelease];
    
    [self.navigationController navigationBar].topItem.leftBarButtonItem=barButtonItem;      
////    CGRect tableview=self.view.frame;
//    [self.view setFrame:CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height/2)];
    
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
        [self refreshCrosses];
    }
}

- (void)ShowProfileView{
    ProfileViewController *profileViewController=[[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    [self.navigationController pushViewController:profileViewController animated:YES];
    
}

-(void) refreshCrosses{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

//    NSString *updated_at=[[NSUserDefaults standardUserDefaults] stringForKey:@"exfee_updated_at"]; 
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

    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at delegate:self];
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
    [self refreshCrosses];
}

#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    NSLog(@"success:%@",objects);
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
    if(cross.updated!=nil)
    {
        id updated=cross.updated;
        if([updated isKindOfClass:[NSDictionary class]]){
            cell.updated=(NSDictionary*)updated;
            if(cross.read_at!=nil)
                cell.read_at=cross.read_at;
            
        }
    }

    cell.title=cross.title;
    cell.place=cross.place.title;
//    cell.time=cross.time.begin_at.date;
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
    //[cell setNeedsDisplay];
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
    if(cross.read_at==nil) {
        cross.read_at=[NSDate date];
        NSError *saveError;
        [[Cross currentContext] save:&saveError];
    }
    
    CrossDetailViewController *detailViewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
    detailViewController.cross=cross;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
