//
//  EFChoosePeopleViewController.m
//  EXFE
//
//  Created by 0day on 13-4-16.
//
//

#import "EFChoosePeopleViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <RestKit/RestKit.h>
#import "MBProgressHUD.h"
#import "EXSpinView.h"
#import "EXAddressBookService.h"
#import "EFChoosePeopleViewCell.h"
#import "Identity.h"
#import "Invitation.h"
#import "ImgCache.h"
#import "Util.h"
#import "EFSearchBar.h"

@interface EFChoosePeopleViewController ()
@property (nonatomic, retain) NSMutableArray *exfePeople;
@property (nonatomic, retain) NSMutableArray *localPeople;
@property (nonatomic, retain) NSMutableArray *searchResultPeople;
@property (nonatomic, copy) NSString *searchKey;

- (void)loadExfePeople;
- (void)loadLocalPeople;

@end

@implementation EFChoosePeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _exfePeople = [[NSMutableArray alloc] init];
        _localPeople = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // background image
    UIImage *searchBackgroundImage = [UIImage imageNamed:@"textfield.png"];
    if ([searchBackgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        searchBackgroundImage = [searchBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){15, 5, 15, 5}];
    } else {
        searchBackgroundImage = [searchBackgroundImage stretchableImageWithLeftCapWidth:4 topCapHeight:15];
    }
    self.searchBackgrounImageView.image = searchBackgroundImage;
    
    // navigation shadow
    CALayer *layer = self.navigationBar.layer;
    layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    layer.shadowOpacity = 0.75f;
    layer.shadowRadius = 1.0f;
    layer.shadowOffset = (CGSize){0, 1};
    
    // add button
    UIImage *addButtonImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
    if ([addButtonImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        addButtonImage = [addButtonImage resizableImageWithCapInsets:(UIEdgeInsets){15, 10, 15, 10}];
    } else {
        addButtonImage = [addButtonImage stretchableImageWithLeftCapWidth:10 topCapHeight:15];
    }
    [self.addButton setBackgroundImage:addButtonImage forState:UIControlStateNormal];
    
    // search bar
    [[UISearchBar appearance] setSearchFieldBackgroundImage:searchBackgroundImage forState:UIControlStateNormal];
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"exfee_22ga.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    self.searchBar.tintColor = [UIColor COLOR_RGB(0xF4, 0xF4, 0xF4)];
    self.searchBar.backgroundColor = [UIColor COLOR_RGB(0xF4, 0xF4, 0xF4)];
    
    // search bar cancel button
    id cancelButtonAppearence = [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil];
    [cancelButtonAppearence setBackgroundImage:addButtonImage forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
    
    // load exfe people
    [self loadExfePeople];
    
    // load local people
    [self loadLocalPeople];
}

- (void)dealloc {
    [_exfePeople release];
    [_localPeople release];
    [_searchTextField release];
    [_searchBackgrounImageView release];
    [_tableView release];
    [_navigationBar release];
    [_addButton release];
    [_searchBar release];
    [_backButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [self setSearchBackgrounImageView:nil];
    [self setTableView:nil];
    [self setNavigationBar:nil];
    [self setAddButton:nil];
    [self setSearchBar:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

#pragma mark - Action
- (IBAction)backButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)addButtonPressed:(id)sender {
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"indexfield CONTAINS[cd] %@", searchText];
    if (!_searchKey || _searchKey.length == 0) {
        self.searchKey = searchText;
        [[EXAddressBookService defaultService] filterPeopleWithExistPeople:self.localPeople
                                                                   keyWord:searchText
                                                                 predicate:predicate
                                                            successHandler:^(NSArray *people){
                                                                self.searchResultPeople = [NSMutableArray arrayWithArray:people];
                                                                [self.searchDisplayController.searchResultsTableView reloadData];
                                                            }
                                                            failureHandler:nil];
    } else {
        if ([searchText rangeOfString:_searchKey].location != NSNotFound && searchText.length != 0) {
            // searchText contain pre search text
            self.searchKey = searchText;
            if (self.searchResultPeople) {
                [[EXAddressBookService defaultService] filterPeopleWithExistPeople:self.searchResultPeople
                                                                           keyWord:searchText
                                                                         predicate:predicate
                                                                    successHandler:^(NSArray *people){
                                                                        self.searchResultPeople = [NSMutableArray arrayWithArray:people];
                                                                        [self.searchDisplayController.searchResultsTableView reloadData];
                                                                    }
                                                                    failureHandler:nil];
            }
        } else {
            // new search text
            self.searchKey = searchText;
            [[EXAddressBookService defaultService] filterPeopleWithExistPeople:self.localPeople
                                                                       keyWord:searchText
                                                                     predicate:predicate
                                                                successHandler:^(NSArray *people){
                                                                    self.searchResultPeople = [NSMutableArray arrayWithArray:people];
                                                                    [self.searchDisplayController.searchResultsTableView reloadData];
                                                                }
                                                                failureHandler:nil];
        }
    }
}

#pragma mark - UISearchDisplayDelegate

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect screanBounds = [UIScreen mainScreen].bounds;
    UIView *titleView = [[[UIView alloc] initWithFrame:(CGRect){{0, 0}, {CGRectGetWidth(screanBounds), 20}}] autorelease];
    titleView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"titleview.png"]];
    backgroundImageView.frame = titleView.bounds;
    [titleView addSubview:backgroundImageView];
    [backgroundImageView release];
    
    NSString *title = nil;
    if (section == 0 && [self.exfePeople count]) {
        // exfe
        title = @"EXFE";
    } else {
        // local
        title = @"Local Contact";
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{5, 0}, {300, 20}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    titleLabel.text = title;
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 19.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger sections = 0;
    if (tableView == self.tableView) {
        if ([self.exfePeople count]) {
            sections++;
        }
        if ([self.localPeople count]) {
            sections++;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        sections = 1;
    }
    
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = 0;
    if (tableView == self.tableView) {
        if (section == 0 && [self.exfePeople count]) {
            // exfe
            rows = [self.exfePeople count];
        } else {
            // local
            rows = [self.localPeople count];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        rows = [self.searchResultPeople count];
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell.ChoosePeople";
    EFChoosePeopleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[EFChoosePeopleViewCell alloc] init] autorelease];
    }
    
    if (tableView == self.tableView) {
        if(([self.exfePeople count] && indexPath.section == 1) ||
           (![self.exfePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.localPeople[indexPath.row];
            [cell customWithLocalContact:person];
        } else {
            Identity *identity = [self.exfePeople objectAtIndex:indexPath.row];
            [cell customWithIdentity:identity];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        LocalContact *person = self.searchResultPeople[indexPath.row];
        [cell customWithLocalContact:person];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Extension
- (void)loadExfePeople {
    UILogPush(@"Start fetch exfe people");
    
    dispatch_queue_t fetch_queue = dispatch_queue_create("queue.fecth", NULL);
    dispatch_async(fetch_queue, ^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
        
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider != %@ AND provider != %@ AND connected_user_id !=0",@"iOSAPN",@"android"];
        
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSArray *recentExfePeople = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
        [self.exfePeople removeAllObjects];
        [self.exfePeople addObjectsFromArray:recentExfePeople];
        
        UILogPush(@"End fetch exfe people");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    dispatch_release(fetch_queue);
}

- (void)loadLocalPeople {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView = bigspin;
    [bigspin release];
    hud.labelText = @"Loading";
    
    __block BOOL isProgressHubVisible = YES;
    
    UILogPush(@"Start Loading Contact.");
    [[EXAddressBookService defaultService] fetchPeopleWithPageSize:40
                                            pageLoadSuccessHandler:^(NSArray *people){
                                                [_localPeople addObjectsFromArray:people];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    UILogPush(@"Load a Page");
                                                    [self.tableView reloadData];
                                                    
                                                    if (isProgressHubVisible) {
                                                        isProgressHubVisible = NO;
                                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                    }
                                                });
                                            }
                                                 completionHandler:^{
                                                     UILogPush(@"End Loading Contact.");
                                                     dispatch_queue_t fetcth_queue = dispatch_queue_create("queue.fetch", NULL);
                                                     dispatch_async(fetcth_queue, ^{
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [self.tableView reloadData];
                                                         });
                                                     });
                                                 }
                                                    failureHandler:nil];
}

@end
