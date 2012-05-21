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

    crossapi=[[APICrosses alloc]init];
    [crossapi getCrossById];

    NSFetchRequest* request = [Cross fetchRequest];
	NSSortDescriptor* id_descriptor = [NSSortDescriptor sortDescriptorWithKey:@"cross_id" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:id_descriptor]];
    
    NSError* error = nil;
    id crossfetch=[Cross fetchRequest];
    
	NSArray* objects = [[NSManagedObjectContext contextForCurrentThread] executeFetchRequest:crossfetch error:&error];
    if([objects count]>1)
    {
    
    Cross* cross = [objects objectAtIndex:0];
    Exfee* aexfee=cross.exfee;

    NSSet *inv=(NSSet*)aexfee.invitations;
    NSEnumerator *enumerator = [inv objectEnumerator];
    id value;
        
    while ((value = [enumerator nextObject])) {
        NSLog(@"%@",value);
    }
        
    NSLog(@"cross id:%u",[cross.cross_id intValue]);
    NSLog(@"by %@",cross.by_identity.name);
    NSLog(@"host %@",cross.host_identity.name);

    cross = [objects objectAtIndex:1];
    
    NSLog(@"cross id:%u",[cross.cross_id intValue]);
    NSLog(@"by %@",cross.by_identity.name);
    NSLog(@"host %@",cross.host_identity.name);

    cross = [objects objectAtIndex:2];
    
    NSLog(@"cross id:%u",[cross.cross_id intValue]);
    NSLog(@"by %@",cross.by_identity.name);
    NSLog(@"host %@",cross.host_identity.name);
    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [crossapi release];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
