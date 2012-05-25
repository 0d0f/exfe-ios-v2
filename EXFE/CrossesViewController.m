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
#import "Exfee.h"
#import "Identity.h"
#import "CrossTime.h"
#import "EFTime.h"

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
    NSLog(@"%@",_crosses);
    BOOL login=[app Checklogin];
    if(login==YES)
    {
        [self refreshCrosses];

    }
//    crossapi=[[APICrosses alloc]init];
//    [crossapi getCrossById];
//    APIUser *user=[[APIUser alloc]init];

//[user SigninWithIdentity:@"virushuo@gmail.com" password:@"tmdtmd"];

//    NSFetchRequest* request = [Cross fetchRequest];
//	NSSortDescriptor* id_descriptor = [NSSortDescriptor sortDescriptorWithKey:@"cross_id" ascending:NO];
//	[request setSortDescriptors:[NSArray arrayWithObject:id_descriptor]];
//    
//    NSError* error = nil;
//    id crossfetch=[Cross fetchRequest];
//    
//	NSArray* objects = [[NSManagedObjectContext contextForCurrentThread] executeFetchRequest:crossfetch error:&error];
//    if([objects count]>1)
//    {
//    
//    Cross* cross = [objects objectAtIndex:0];
//    Exfee* aexfee=cross.exfee;
//
//    NSSet *inv=(NSSet*)aexfee.invitations;
//    NSEnumerator *enumerator = [inv objectEnumerator];
//    id value;
//        
//    while ((value = [enumerator nextObject])) {
//        NSLog(@"%@",value);
//    }
//    
//    NSLog(@"cross id:%u",[cross.cross_id intValue]);
//    NSLog(@"by %@",cross.by_identity.name);
//    NSLog(@"host %@",cross.host_identity.name);
//    NSLog(@"cross begin_at date:%@",cross.time.begin_at.date);
//    NSLog(@"cross begin_at time:%@",cross.time.begin_at.time);
//
//    cross = [objects objectAtIndex:1];
//    
//    NSLog(@"cross id:%u",[cross.cross_id intValue]);
//    NSLog(@"by %@",cross.by_identity.name);
//    NSLog(@"host %@",cross.host_identity.name);
//
//    cross = [objects objectAtIndex:2];
//    
//    NSLog(@"cross id:%u",[cross.cross_id intValue]);
//    NSLog(@"by %@",cross.by_identity.name);
//    NSLog(@"host %@",cross.host_identity.name);
//    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //[crossapi release];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
//	[_tableView release];
	[_crosses release];
    [super dealloc];
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
        //Optionally for time zone converstions
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        updated_at = [formatter stringFromDate:date_updated_at];
        [formatter release];
    }

//    if(updated_at==nil){
//        updated_at=@"";
//    }
    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at delegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadObjectsFromDataStore {
	[_crosses release];
	NSFetchRequest* request = [Cross fetchRequest];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	_crosses = [[Cross objectsWithFetchRequest:request] retain];
    [_tableView reloadData];
}


#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    NSLog(@"success:%@",objects);
    if([objects count]>0)
    {
        Cross *cross=[objects lastObject];
        NSLog(@"%@",cross.updated_at);
        [[NSUserDefaults standardUserDefaults] setObject:cross.updated_at forKey:@"exfee_updated_at"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self loadObjectsFromDataStore];
    }
    
    //    Cross *cross=[objects objectAtIndex:0];
    //    NSLog(@"load:%@",cross);
    //    UsersLogin *result = [objects objectAtIndex:0];
    
    //    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_crosses count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	NSDate* lastUpdatedAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdatedAt"];
//	NSString* dateString = [NSDateFormatter localizedStringFromDate:lastUpdatedAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
//	if (nil == dateString) {
//		dateString = @"Never";
//	}
//	return [NSString stringWithFormat:@"Last Load: %@", dateString];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"Tweet Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.numberOfLines = 0;
//		cell.textLabel.backgroundColor = [UIColor clearColor];
//		cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"listbg.png"]];
	}
//    RKTStatus* status = [_statuses objectAtIndex:indexPath.row];
    Cross *cross=[_crosses objectAtIndex:indexPath.row];
	cell.textLabel.text = cross.title;
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Cross *cross=[_crosses objectAtIndex:indexPath.row]; 
    CrossDetailViewController *detailViewController=[[CrossDetailViewController alloc]initWithNibName:@"CrossDetailViewController" bundle:nil];
    detailViewController.cross=cross;
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    
}
@end
