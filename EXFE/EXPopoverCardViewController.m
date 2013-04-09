//
//  EXPopoverCardViewController.m
//  EXFE
//
//  Created by 0day on 13-4-4.
//
//

#import "EXPopoverCardViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "Card.h"
#import "AppDelegate.h"
#import "Util.h"
#import "EXPopoverCardCell.h"
#import "EXArrowView.h"
#import "Identity+EXFE.h"

#define kHeaderViewHeight   (28.0f)
#define kLineHeight         (18.0f)
#define kViewWidth          (200.0f)


@interface EXPopoverCardViewController ()
@end

@implementation EXPopoverCardViewController {
    struct {
        BOOL isPresnted;
    }_flags;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc {
    [_card release];
    [super dealloc];
}

#pragma mark - Public
- (id)initWithCard:(Card *)card {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.card = card;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.view.backgroundColor = [UIColor clearColor];
        
        _flags.isPresnted = NO;
    }
    
    return self;
}

+ (CGSize)cardSizeWithCard:(Card *)card {
    CGSize result = (CGSize){0, 0};
    if (card) {
        result = (CGSize){kViewWidth, kHeaderViewHeight + [card.identities count] * kLineHeight + 20.0f};
    }
    
    return result;
}

#pragma mark - Getter && Setter
- (void)setCard:(Card *)card {
    if (_card) {
        [_card release];
        _card = nil;
    }
    if (card) {
        _card = [card copy];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_card.identities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopoverCardCell";
    EXPopoverCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[EXPopoverCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    CardIdentitiy *identity = _card.identities[indexPath.row];
    cell.userNameLabel.text = identity.externalUsername;
    
    Provider provider = [Identity getProviderCode:identity.provider];
    if (provider == kProviderEmail) {
        cell.providerLabel.text = @"";
    } else {
        cell.providerLabel.text = identity.provider;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kLineHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {kViewWidth, kHeaderViewHeight}}];
    label.text = @"Real artists ship. ";
    label.textAlignment = UITextAlignmentRight;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    
    return [label autorelease];
}

@end
