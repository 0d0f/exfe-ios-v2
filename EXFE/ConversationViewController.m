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
    [self loadObjectsFromDataStore];
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

- (void)loadObjectsFromDataStore {
	[_posts release];

	NSFetchRequest* request = [Post fetchRequest];
	NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
	_posts = [[Post objectsWithFetchRequest:request] retain];
    //[_tableView reloadData];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_posts count];
//    return 2;
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
	NSString* reuseIdentifier = @"Conversation Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.numberOfLines = 0;

	}
    cell.textLabel.text = @"post";
//    Post *post=[_posts objectAtIndex:indexPath.row];
//	cell.textLabel.text = post.content;
	return cell;
}
    
@end
