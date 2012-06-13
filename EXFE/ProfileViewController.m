//
//  ProfileViewController.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "APIProfile.h"
#import "ImgCache.h"
#import "Identity.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    if(identitiesData != nil)
        [identitiesData release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self loadObjectsFromDataStore];
    [APIProfile LoadUsrWithUserId:app.userid delegate:self];


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadObjectsFromDataStore {
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSFetchRequest* request = [User fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"user_id = %u", app.userid];    
    [request setPredicate:predicate];
	NSArray *users = [[User objectsWithFetchRequest:request] retain];
    
    if(users!=nil && [users count] >0)
    {
        [user release];
        user=[users objectAtIndex:0];
        username.text=user.name;
        if(identitiesData!=nil)
        {
//            for (NSMutableArray *section in identitiesData)
//                [section release];
            [identitiesData release];
        }
            
        NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
        identitiesData=[[NSMutableArray alloc] initWithCapacity:2];
        
        NSString* imgName = user.avatar_filename; 
        NSString *imgurl = [ImgCache getImgUrl:imgName];
        
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];

        [useravatar setImage:image];
        for (Identity *identity in user.identities)
        {
            NSLog(@"%@",identity.provider);
            if([identity.provider isEqualToString:@"iOSAPN"])
            {
                [devices_section addObject:identity];
            }
            else {
                [identities_section addObject:identity];
            }
        }
//        NSLog(@"%@",identities_section);
//        NSLog(@"%@",devices_section);
        [identitiesData addObject:identities_section];
        [identitiesData addObject:devices_section];
        [devices_section release];
        [identities_section release];
    }
//    NSLog(@"%@",identitiesData);
    [tabview reloadData];
//    [inputToolbar setInputEnabled:YES];
//    [inputToolbar hidekeyboard];
    
}


#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
//    NSLog(@"success:%@",objects);
//    if([objects count]>0)
//    {
        
//        User *user=[objects objectAtIndex:0];
//        NSLog(@"%@",user.default_identity);
//        NSSet *identities=user.identities;
//        NSLog(@"%@",identities);
//        Cross *cross=[objects lastObject];
//        [[NSUserDefaults standardUserDefaults] setObject:cross.updated_at forKey:@"exfee_updated_at"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self loadObjectsFromDataStore];
//    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [identitiesData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[identitiesData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString* reuseIdentifier = @"Profile Cell";
//    ProfileCellView *cell=(ProfileCellView*)
    ProfileCellView *cell=(ProfileCellView*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if(nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"ProfileCellView" owner:self options:nil];
        cell = tblCell;
    }
    
//    
////    Identity *identity=[[user.identities allObjects] objectAtIndex:indexPath.row];
//    cell.name=@"identity.name";
    [cell setLabelName:@"identity.name"];
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 30.0;
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == [identitiesData count]-1)
        return 40.0;
    return 1.0;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}


@end
