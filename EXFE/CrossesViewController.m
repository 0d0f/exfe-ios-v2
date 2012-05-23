//
//  CrossesViewController.m
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossesViewController.h"
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
-(void) refreshCrosses{
    [APICrosses LoadCrossWithUserId:0 updatetime:@"" delegate:self];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"success:%@",objects);
    //    Cross *cross=[objects objectAtIndex:0];
    //    NSLog(@"load:%@",cross);
    //    UsersLogin *result = [objects objectAtIndex:0];
    
    //    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}
@end
