//
//  CrossDetailViewController.m
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CrossDetailViewController.h"
#import "Exfee.h"
#import "Cross.h"
#import "APIConversation.h"

@interface CrossDetailViewController ()

@end

@implementation CrossDetailViewController
@synthesize cross;

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
    
//    Exfee *exfee=cross.exfee;
//    NSLog(@"%@",exfee.exfee_id);
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];

    cross_tiltle.text=cross.title;
    exfee_id.text=[cross.exfee.exfee_id stringValue];
    
    
    [APIConversation LoadConversationWithExfeeId:app.userid updatedtime:@"" delegate:self];
    //LoadConversationWithExfeeId:(int)userid updatedtime:(NSString*)updatedtime delegate:(id)delegate{
    
    // Do any additional setup after loading the view from its nib.
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

#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
        NSLog(@"success:%@",objects);
//    if([objects count]>0)
//    {
//        Cross *cross=[objects lastObject];
//        NSLog(@"%@",cross.updated_at);
//        [[NSUserDefaults standardUserDefaults] setObject:cross.updated_at forKey:@"exfee_updated_at"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [self loadObjectsFromDataStore];
//    }
    
    //    Cross *cross=[objects objectAtIndex:0];
    //    NSLog(@"load:%@",cross);
    //    UsersLogin *result = [objects objectAtIndex:0];
    
    //    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}



@end
