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
#import "CrossesViewController.h"
#import "AppDelegate.h"

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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [tabview addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];
    
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self loadObjectsFromDataStore];
    [APIProfile LoadUsrWithUserId:app.userid delegate:self];

}
- (void)touchesBegan:(UITapGestureRecognizer*)sender{
    CGPoint location = [sender locationInView:sender.view];
    CGRect useravatarRect=[useravatar frame];
    
    if(CGRectContainsPoint(useravatarRect, location))
    {
        FullScreenViewController *viewcontroller=[[FullScreenViewController alloc] initWithNibName:@"FullScreenViewController" bundle:nil];
        viewcontroller.wantsFullScreenLayout=YES;
        viewcontroller.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        viewcontroller.image=useravatar.image;
        [self presentModalViewController:viewcontroller animated:YES];
    }
    else{
        CGPoint location2= [sender locationInView:footerView];
        
        CGRect signoutbuttonRect=[buttonsignout frame];
        if(CGRectContainsPoint(signoutbuttonRect, location2))
        {
            [self Logout];
        }
    }
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
            [identitiesData release];
        }
            
        NSMutableArray* identities_section=[[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray* devices_section=[[NSMutableArray alloc] initWithCapacity:5];
        identitiesData=[[NSMutableArray alloc] initWithCapacity:2];
        
        NSString* imgName = user.avatar_filename; 
        NSString *imgurl = [ImgCache getImgUrl:imgName];
        
        UIImage *image = [[ImgCache sharedManager] getImgFrom:imgurl];
        if(image!=nil && ![image isEqual:[NSNull null]])
            [useravatar setImage:image];
        for (Identity *identity in user.identities)
        {
            if([identity.provider isEqualToString:@"iOSAPN"]|| [identity.provider isEqualToString:@"Android"])
            {
                [devices_section addObject:identity];
            }
            else {
                [identities_section addObject:identity];
            }
        }
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
   
        [self loadObjectsFromDataStore];
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
    ProfileCellView *cell=(ProfileCellView*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if(nil == cell) {
        [[NSBundle mainBundle] loadNibNamed:@"ProfileCellView" owner:self options:nil];
        cell = tblCell;
    }
    Identity *identity=[[identitiesData objectAtIndex:[indexPath section]]  objectAtIndex:indexPath.row];
//    Identity *identity=[[user.identities allObjects] objectAtIndex:indexPath.row];
//    if(![identity.name isEqualToString:@""])
//        [cell setLabelName:identity.name];
//    else
//        [cell setLabelName:identity.external_username];
//
//    if([identity.provider isEqualToString:@"email"])
//        [cell setLabelIdentity:identity.external_id];
//    else{
//        [cell setLabelIdentity:[NSString stringWithFormat:@"%@@%@",identity.external_username,identity.provider]];
//    }
//
//    [cell setLabelStatus:1];
    if([indexPath section]==0)
    {
        if(identity.avatar_filename==nil || [identity.avatar_filename isEqualToString:@""] )
        {
            UIImage *img = [UIImage imageNamed:@"default_avatar.png"];
            if((NSNull*)img!=[NSNull null])
                [cell setAvartar:img];
        }
        else
        {
            NSString* imgName = identity.avatar_filename;
            NSString *imgurl = [ImgCache getImgUrl:imgName];
            UIImage *img = [[ImgCache sharedManager] getImgFrom:imgurl];
            if((NSNull*)img!=[NSNull null])
                [cell setAvartar:img];
        }
        if(![identity.name isEqualToString:@""])
            [cell setLabelName:identity.name];
        else
            [cell setLabelName:identity.external_id];
        if([identity.provider isEqualToString:@"email"])
            [cell setLabelIdentity:identity.external_id];
        else{
            [cell setLabelIdentity:[NSString stringWithFormat:@"%@@%@",identity.external_username,identity.provider]];
        }
        if(identity.provider!=nil && ![identity.provider isEqualToString:@""]){
            
            NSString *iconname=[NSString stringWithFormat:@"identity_%@_18_grey.png",identity.provider];
            UIImage *icon=[UIImage imageNamed:iconname];
            [cell setProvider:icon];
        }

        
        return cell;
    }
    else
    {
        NSString *iconname=@"";
        if([identity.provider isEqualToString:@"iOSAPN"])
            iconname=@"device_iphone.png";
        else if([identity.provider isEqualToString:@"android"])
            iconname=@"device_android.png";
           
        if(![iconname isEqualToString:@""])
        {
            UIImage *img = [UIImage imageNamed:iconname];
            [cell setAvartar:img];
        }
        [cell setLabelStatus:1];
        [cell setLabelName:identity.external_username];
        
        
        if([identity.external_id isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"devicetoken"]])
        {
            [cell IsThisDevice:@""];
        }
        return cell;
    }    
	return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        if(headerView==nil){
            headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 111)];
            useravatar=[[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 64, 64)];
            useravatar.image=[UIImage imageNamed:@"portrait_default.png"];
            useravatar.layer.cornerRadius=2;
            useravatar.clipsToBounds = YES;
            [headerView addSubview:useravatar];
            
            username=[[UILabel alloc] initWithFrame:CGRectMake(100, 16, 160, 52)];
            username.backgroundColor=[UIColor clearColor];
            username.textColor=[UIColor whiteColor];
            username.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
            username.shadowColor=[UIColor blackColor];
            username.shadowOffset=CGSizeMake(0, -1);
            [headerView addSubview:username];
            
        }
        return headerView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 111.0;
    return 15.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == [identitiesData count]-1)
        return 60;
    return 1.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section==0)
        return nil;
    if (section==1)
    if(footerView == nil) {
        footerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        UIImage *btn_red_dark = [UIImage imageNamed:@"btn_red_dark_44.png"];
        UIImageView *backimg=[[UIImageView alloc] initWithFrame:CGRectMake(200, 10, 100, 44)];
        backimg.image=btn_red_dark;
        backimg.contentMode=UIViewContentModeScaleToFill;
        backimg.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
        [footerView addSubview:backimg];
        [backimg release];

        buttonsignout = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonsignout setTitle:@"Sign Out" forState:UIControlStateNormal];
        [buttonsignout.titleLabel setFont:[UIFont boldSystemFontOfSize:18]]; 
        [buttonsignout setTitleColor:FONT_COLOR_FA forState:UIControlStateNormal];
        
        [buttonsignout setFrame:CGRectMake(200, 10, 100, 44)];
        [buttonsignout setBackgroundColor:[UIColor clearColor]];
        [buttonsignout addTarget:self action:@selector(Logout) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:buttonsignout];
    }
    
    //return the view for the footer
    return footerView;
}

- (void) Logout
{
    NSLog(@"logout");
    AppDelegate* app=(AppDelegate*)[[UIApplication sharedApplication] delegate];  
    [app SignoutDidFinish];
}


@end
