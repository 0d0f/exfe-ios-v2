//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
#import "CrossDetailViewController.h"
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
    }
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
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	_crosses = [[Cross objectsWithFetchRequest:request] retain];

//    for (int i=0;i<[_crosses count];i++)
//    {
//        Cross *cross=[_crosses objectAtIndex:i];
//        NSLog(@"cross id:%u",[cross.cross_id intValue]);
//
//    }

    [_tableView reloadData];
}


#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    NSLog(@"success:%@",objects);
    if([objects count]>0)
    {
        Cross *cross=[objects lastObject];
        [[NSUserDefaults standardUserDefaults] setObject:cross.updated_at forKey:@"exfee_updated_at"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self loadObjectsFromDataStore];
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_crosses count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"cross Cell";
    CrossCell *cell =[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
        cell = [[[CrossCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
	}
    Cross *cross=[_crosses objectAtIndex:indexPath.row];
    if(cross.updated!=nil)
    {
        id updated=cross.updated;
        if([updated isKindOfClass:[NSDictionary class]])
            cell.updated=(NSDictionary*)updated;
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
    if(cross.updated!=nil) {
        cross.updated=nil;
        NSError *saveError;
        [[Cross currentContext] save:&saveError];
    }
    
    CrossDetailViewController *detailViewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
    detailViewController.cross=cross;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}


@end
