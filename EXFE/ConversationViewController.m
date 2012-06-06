//
//  ConversationViewController.m
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationViewController.h"
#import "Post.h"
#import "APIConversation.h"

@interface ConversationViewController ()

@end

@implementation ConversationViewController
@synthesize exfee_id;

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
    [self refreshConversation];
    //[self loadObjectsFromDataStore];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    //	[_tableView release];
	[_posts release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void) refreshConversation{
    if(_posts==nil)
        [self loadObjectsFromDataStore];
    
    Post *post=[_posts lastObject];
    NSString *updated_at=@"";
    if(post)
    {
        if(post.updated_at!=nil)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
            //        2012-04-24 07:06:13 +0000
            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            updated_at = [formatter stringFromDate:post.updated_at];
            [formatter release];
            NSLog(@"%@",updated_at);
        }

        
//        NSString *updated_at=;
    }
    // [_posts lastObject]
    
    [APIConversation LoadConversationWithExfeeId:exfee_id updatedtime:updated_at delegate:self];

//    [APICrosses LoadCrossWithUserId:app.userid updatedtime:updated_at delegate:self];
   
}

- (void)loadObjectsFromDataStore {
	[_posts release];

	NSFetchRequest* request = [Post fetchRequest];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"(postable_type = %@) AND (postable_id = %u)",
                              @"exfee", exfee_id];    
    [request setPredicate:predicate];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"updated_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
    
	_posts = [[Post objectsWithFetchRequest:request] retain];
    [_tableView reloadData];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"Conversation Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.numberOfLines = 0;

	}
    Post *post=[_posts objectAtIndex:indexPath.row];
    NSLog(@"%@",post);
	cell.textLabel.text = post.content;
	return cell;
}
    
#pragma Mark - RKRequestDelegate
- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    NSLog(@"success:%@",objects);
    if([objects count]>0)
    {
//        Post *post=[objects lastObject];
//        [[NSUserDefaults standardUserDefaults] setObject:post.updated_at forKey:@"conversation_updated_at"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        [self loadObjectsFromDataStore];
    }
}

@end
