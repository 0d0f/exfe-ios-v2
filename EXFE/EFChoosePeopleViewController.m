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
#import "Identity.h"
#import "Invitation.h"
#import "Util.h"
#import "EFSearchBar.h"
#import "LocalContact+EXFE.h"
#import "RoughIdentity.h"
#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import "EFAPIServer.h"
#import "EFSearchIdentityCell.h"
#import "WCAlertView.h"

#pragma mark - Category (Extension)
@interface EFChoosePeopleViewController ()
@property (nonatomic, retain) NSMutableArray *searchAddPeople;
@property (nonatomic, retain) NSMutableArray *exfeePeople;
@property (nonatomic, retain) NSMutableArray *contactPeople;

@property (nonatomic, retain) NSMutableArray *searchResultAddPeople;
@property (nonatomic, retain) NSMutableArray *searchResultExfeePeople;
@property (nonatomic, retain) NSMutableArray *searchResultContactPeople;

@property (nonatomic, assign) BOOL hasExfeeNameSetCompletion;

@property (nonatomic, retain) RoughIdentity *searchResultRoughtIdentity;

@property (nonatomic, copy) NSString *searchKey;

@property (nonatomic, retain) NSMutableDictionary *selectedDict;
@property (nonatomic, retain) NSMutableDictionary *selectedRoughIdentityDict;
@property (nonatomic, retain) NSMutableDictionary *cachedRoughIdentityDict;

@property (nonatomic, retain) NSIndexPath *insertIndexPath;

- (void)loadexfeePeople;
- (void)loadcontactPeople;

- (void)selectOrDeselectTableView:(UITableView *)tableView selected:(BOOL)isSelected atIndexPath:(NSIndexPath *)indexPath;
- (void)refreshSelectedDictWithObject:(id)obj selected:(BOOL)selected;
- (BOOL)isObjectSelectedInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (id)objectForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadAddButtonState;

@end

#pragma mark - Category (ChoosePeopleViewCellDisplay)

@interface EFChoosePeopleViewController (ChoosePeopleViewCellDisplay)
- (EFChoosePeopleViewCell *)choosePeopleViewCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)choosePeopleTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)aCell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

#pragma mark - Category (PersonIdentityCellDisplay)

@interface EFChoosePeopleViewController (PersonIdentityCellDisplay)
- (NSArray *)roughIdentitiesForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)selectRoughIdentity:(RoughIdentity *)identity;
- (void)deselectRoughIdentity:(RoughIdentity *)identity;
- (BOOL)isRoughtIdentitySelected:(RoughIdentity *)identity;
@end

#pragma mark - Category (SelectionCountLabel)

@interface EFChoosePeopleViewController (SelectionCountLabel)
- (void)reloadSelectionCountLabelWithAnimated:(BOOL)animated;
@end

#pragma mark -
#pragma mark - EFChoosePeopleViewController Implementation

@implementation EFChoosePeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _cachedRoughIdentityDict = [[NSMutableDictionary alloc] init];
        _searchAddPeople = [[NSMutableArray alloc] init];
        _exfeePeople = [[NSMutableArray alloc] init];
        _contactPeople = [[NSMutableArray alloc] init];
        _selectedDict = [[NSMutableDictionary alloc] init];
        _selectedRoughIdentityDict = [[NSMutableDictionary alloc] init];
        self.hasExfeeNameSetCompletion = YES;
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
        self.wantsFullScreenLayout = YES;
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
    [[UISearchBar appearance] setPositionAdjustment:(UIOffset){-6, -1} forSearchBarIcon:UISearchBarIconSearch];
    self.searchBar.tintColor = [UIColor COLOR_RGB(0xF4, 0xF4, 0xF4)];
    self.searchBar.backgroundColor = [UIColor COLOR_RGB(0xF4, 0xF4, 0xF4)];
    
    // textfield
    for (UIView *view in self.searchBar.subviews){
        if ([view isKindOfClass: [UITextField class]]) {
            UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }
    
    // hide count label
    [self reloadSelectionCountLabelWithAnimated:NO];
    
    // add button state
    [self reloadAddButtonState];
    
    // load exfe people
    [self loadexfeePeople];
    
    // load local people
    [self loadcontactPeople];
}

- (void)dealloc {
    [_searchResultRoughtIdentity release];
    [_cachedRoughIdentityDict release];
    [_searchAddPeople release];
    [_selectedRoughIdentityDict release];
    [_selectedDict release];
    [_exfeePeople release];
    [_contactPeople release];
    [_searchResultAddPeople release];
    [_searchResultExfeePeople release];
    [_searchResultContactPeople release];
    [_tableView release];
    [_navigationBar release];
    [_addButton release];
    [_searchBar release];
    [_backButton release];
    [_selectionCountLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setNavigationBar:nil];
    [self setAddButton:nil];
    [self setSearchBar:nil];
    [self setBackButton:nil];
    [self setSelectionCountLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Action
- (IBAction)backButtonPressed:(id)sender {
    [[EXAddressBookService defaultService] cancel];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

- (IBAction)addButtonPressed:(id)sender {
    // handle search text
    NSString *searchKeyWord = self.searchBar.text;
    if (searchKeyWord.length && self.searchDisplayController.isActive) {
        [self tableView:self.searchDisplayController.searchResultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    // wait for setting name
    while (!self.hasExfeeNameSetCompletion) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    // ignore if no one selected
    if (![_selectedDict count]) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding...";
    hud.mode = MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView = bigspin;
    [bigspin release];
    
    NSMutableArray *selectedIdentities = [[NSMutableArray alloc] init];
    NSMutableDictionary *addIdentitiyDict = [[NSMutableDictionary alloc] init];
    
    for (Identity *identity in self.exfeePeople) {
        RoughIdentity *roughIdentity = [identity roughIdentityValue];
        if ([self isRoughtIdentitySelected:roughIdentity]) {
            [selectedIdentities addObject:@[identity]];
            [addIdentitiyDict setValue:@"YES" forKey:roughIdentity.key];
        }
    }
    
    for (RoughIdentity *roughIdentity in self.searchAddPeople) {
        if ([self isRoughtIdentitySelected:roughIdentity]) {
            if ([addIdentitiyDict valueForKey:roughIdentity.key]) {
                continue;
            }
            if (roughIdentity.status == kEFRoughIdentityGetIdentityStatusSuccess) {
                [selectedIdentities addObject:@[roughIdentity.identity]];
                [addIdentitiyDict setValue:@"YES" forKey:roughIdentity.key];
            } else if (roughIdentity.status == kEFRoughIdentityGetIdentityStatusLoading) {
                while ((kEFRoughIdentityGetIdentityStatusSuccess != roughIdentity.status) && (kEFRoughIdentityGetIdentityStatusFailure != roughIdentity.status)) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                             beforeDate:[NSDate distantFuture]];
                }
                if (kEFRoughIdentityGetIdentityStatusSuccess == roughIdentity.status) {
                    [selectedIdentities addObject:@[roughIdentity.identity]];
                    [addIdentitiyDict setValue:@"YES" forKey:roughIdentity.key];
                }
            }
        }
    }
    
    for (LocalContact *contact in self.contactPeople) {
        NSArray *roughtIdentities = [contact roughIdentities];
        NSMutableArray *contactRoughIdentities = [[NSMutableArray alloc] initWithCapacity:[roughtIdentities count]];
        for (RoughIdentity *roughIdentity in roughtIdentities) {
            if ([self isRoughtIdentitySelected:roughIdentity]) {
                if ([addIdentitiyDict valueForKey:roughIdentity.key]) {
                    continue;
                }
                RoughIdentity *cachedRoughtIdentity = [_cachedRoughIdentityDict valueForKey:roughIdentity.key];
                if (cachedRoughtIdentity.status == kEFRoughIdentityGetIdentityStatusSuccess) {
                    cachedRoughtIdentity.identity.name = contact.name;
                    [contactRoughIdentities addObject:cachedRoughtIdentity.identity];
                    [addIdentitiyDict setValue:@"YES" forKey:roughIdentity.key];
                } else if (cachedRoughtIdentity.status == kEFRoughIdentityGetIdentityStatusLoading) {
                    while ((kEFRoughIdentityGetIdentityStatusSuccess != cachedRoughtIdentity.status) && (kEFRoughIdentityGetIdentityStatusFailure != cachedRoughtIdentity.status)) {
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                                 beforeDate:[NSDate distantFuture]];
                    }
                    if (kEFRoughIdentityGetIdentityStatusSuccess == cachedRoughtIdentity.status) {
                        cachedRoughtIdentity.identity.name = contact.name;
                        [contactRoughIdentities addObject:cachedRoughtIdentity.identity];
                        [addIdentitiyDict setValue:@"YES" forKey:roughIdentity.key];
                    }
                }
            }
        }
        if ([contactRoughIdentities count]) {
            [selectedIdentities addObject:contactRoughIdentities];
        }
        [contactRoughIdentities release];
    }
    
    if (_addActionHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.addActionHandler(selectedIdentities);
        });
    }
    
    [addIdentitiyDict release];
    [selectedIdentities release];
}

#pragma mark - EFPersonIdentityCellDelegate

- (void )personIdentityCell:(EFPersonIdentityCell *)cell didSelectRoughIdentity:(RoughIdentity *)roughIdentity {
    if (!self.insertIndexPath)
        return;
    
    [self selectRoughIdentity:roughIdentity];
    
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        tableView = self.searchDisplayController.searchResultsTableView;
        indexPath = [tableView indexPathForCell:cell];
    }
    
    NSIndexPath *indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];;
    
    [self selectOrDeselectTableView:tableView
                           selected:YES
                        atIndexPath:indexPathParam];
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPathParam] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
}

- (void )personIdentityCell:(EFPersonIdentityCell *)cell didDeselectRoughIdentity:(RoughIdentity *)roughIdentity {
    if (!self.insertIndexPath)
        return;
    
    [self deselectRoughIdentity:roughIdentity];
    
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        tableView = self.searchDisplayController.searchResultsTableView;
        indexPath = [tableView indexPathForCell:cell];
    }
    indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
      
    NSIndexPath *indexPathParam = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView &&
        self.searchBar.text.length &&
        indexPath.section == 0) {
        indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    } else {
        indexPathParam = indexPath;
    }
    NSArray *roughtIdentities = [self roughIdentitiesForTableView:tableView indexPath:indexPathParam];
    
    BOOL shouldDeselect = YES;
    for (RoughIdentity *roughIndentity in roughtIdentities) {
        if ([self isRoughtIdentitySelected:roughIndentity]) {
            shouldDeselect = NO;
            break;
        }
    }
    
    if (shouldDeselect) {
        [self selectOrDeselectTableView:tableView
                               selected:NO
                            atIndexPath:indexPath];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

#pragma mark - EFPersonIdentityCellDataSource

- (BOOL)shouldPersonIdentityCell:(EFPersonIdentityCell *)cell selectRoughIdentity:(RoughIdentity *)roughtIdentity {
    return [self isRoughtIdentitySelected:roughtIdentity];
}

#pragma mark - EFChoosePeopleViewCellDelegate

- (void)choosePeopleViewCellButtonPressed:(EFChoosePeopleViewCell *)cell {
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        tableView = self.searchDisplayController.searchResultsTableView;
        indexPath = [tableView indexPathForCell:cell];
    }
    indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    
    if (self.insertIndexPath) {
        NSIndexPath *toRemoveIndexPath = [NSIndexPath indexPathForRow:self.insertIndexPath.row inSection:self.insertIndexPath.section];
        self.insertIndexPath = nil;
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[toRemoveIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    } else {
        CGPoint offset = tableView.contentOffset;
        CGRect viewFrame = tableView.frame;
        if (offset.y + CGRectGetHeight(viewFrame) == tableView.contentSize.height) {
            [tableView setContentOffset:(CGPoint){offset.x, offset.y + [self tableView:tableView heightForRowAtIndexPath:indexPath]} animated:NO];
        }
        
        self.insertIndexPath = indexPath;
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }
}

#pragma mark - EFChoosePeopleViewCellDataSource

- (BOOL)shouldChoosePeopleViewCellSelected:(EFChoosePeopleViewCell *)cell {
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        tableView = self.searchDisplayController.searchResultsTableView;
        indexPath = [tableView indexPathForCell:cell];
//        if (indexPath && self.searchBar.text.length && indexPath.section == 0) {
//            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
//        }
    }
    
    if (indexPath) {
        return [self isObjectSelectedInTableView:tableView atIndexPath:indexPath];
    } else {
        return NO;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    Provider provider = [Util matchedProvider:searchText];
    if (provider != kProviderUnknown) {
        NSDictionary *matchedDictionary = [Util parseIdentityString:searchText byProvider:provider];
        self.searchResultRoughtIdentity = [RoughIdentity identityWithDictionary:matchedDictionary];
        NSString *cachedSearchText = [[searchText copy] autorelease];
        AppDelegate * app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.model.apiServer getIdentitiesWithParams:@[matchedDictionary]
                                                      success:^(NSArray *identities){
                                                          self.searchResultRoughtIdentity.identity = identities[0];
                                                          
                                                          if (self.searchDisplayController.isActive && [cachedSearchText isEqualToString:searchText]) {
                                                              [self.searchDisplayController.searchResultsTableView beginUpdates];
                                                              [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                                              [self.searchDisplayController.searchResultsTableView endUpdates];
                                                          }
                                                      }
                                                      failure:^(NSError *error){
                                                          
                                                      }];
    } else {
        self.searchResultRoughtIdentity = nil;
    }
    
    NSPredicate *searchAddPredicate = [NSPredicate predicateWithFormat:@"externalID CONTAINS[cd] %@ OR externalUsername CONTAINS[cd] %@ OR provider CONTAINS[cd] %@", searchText, searchText, searchText];
    NSPredicate *exfeePredicate = [NSPredicate predicateWithFormat:@"external_id CONTAINS[cd] %@ OR external_username CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR provider CONTAINS[cd] %@", searchText, searchText, searchText, searchText];
    NSPredicate *contactPredicate = [NSPredicate predicateWithFormat:@"indexfield CONTAINS[cd] %@", searchText];
    
    if (!_searchKey || _searchKey.length == 0) {
        self.searchKey = searchText;
        
        self.searchResultAddPeople = [[[_searchAddPeople filteredArrayUsingPredicate:searchAddPredicate] mutableCopy] autorelease];
        self.searchResultExfeePeople = [[[_exfeePeople filteredArrayUsingPredicate:exfeePredicate] mutableCopy] autorelease];
        [self.searchDisplayController.searchResultsTableView reloadData];
        
        [[EXAddressBookService defaultService] filterPeopleWithExistPeople:self.contactPeople
                                                                   keyWord:searchText
                                                                 predicate:contactPredicate
                                                            successHandler:^(NSArray *people){
                                                                self.searchResultContactPeople = [NSMutableArray arrayWithArray:people];
                                                                [self.searchDisplayController.searchResultsTableView reloadData];
                                                            }
                                                            failureHandler:nil];
    } else {
        if ([searchText rangeOfString:_searchKey].location != NSNotFound && searchText.length != 0) {
            // searchText contain pre search text
            self.searchKey = searchText;
            
            self.searchResultAddPeople = [[[_searchAddPeople filteredArrayUsingPredicate:searchAddPredicate] mutableCopy] autorelease];
            self.searchResultExfeePeople = [[[_exfeePeople filteredArrayUsingPredicate:exfeePredicate] mutableCopy] autorelease];
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            if (self.searchResultContactPeople) {
                [[EXAddressBookService defaultService] filterPeopleWithExistPeople:self.searchResultContactPeople
                                                                           keyWord:searchText
                                                                         predicate:contactPredicate
                                                                    successHandler:^(NSArray *people){
                                                                        self.searchResultContactPeople = [NSMutableArray arrayWithArray:people];
                                                                        [self.searchDisplayController.searchResultsTableView reloadData];
                                                                    }
                                                                    failureHandler:nil];
            }
        } else {
            // new search text
            self.searchKey = searchText;
            
            self.searchResultAddPeople = [[[_searchAddPeople filteredArrayUsingPredicate:searchAddPredicate] mutableCopy] autorelease];
            self.searchResultExfeePeople = [[[_exfeePeople filteredArrayUsingPredicate:exfeePredicate] mutableCopy] autorelease];
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            [[EXAddressBookService defaultService] filterPeopleWithExistPeople:self.contactPeople
                                                                       keyWord:searchText
                                                                     predicate:contactPredicate
                                                                successHandler:^(NSArray *people){
                                                                    self.searchResultContactPeople = [NSMutableArray arrayWithArray:people];
                                                                    [self.searchDisplayController.searchResultsTableView reloadData];
                                                                }
                                                                failureHandler:nil];
        }
    }
}

#pragma mark - UISearchDisplayDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    controller.searchResultsTableView.allowsMultipleSelection = YES;
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self reloadSelectionCountLabelWithAnimated:YES];
    [self reloadAddButtonState];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self reloadSelectionCountLabelWithAnimated:YES];
    [self reloadAddButtonState];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView && section == [tableView numberOfSections] - 1) {
        UIView *headerView = [[[UIView alloc] initWithFrame:(CGRect){{0, 0}, {320, 0}}] autorelease];
        headerView.backgroundColor = [UIColor clearColor];
        return headerView;
    }
    
    CGRect screanBounds = [UIScreen mainScreen].bounds;
    UIView *titleView = [[[UIView alloc] initWithFrame:(CGRect){{0, -1}, {CGRectGetWidth(screanBounds), 20}}] autorelease];
    titleView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_title.png"]];
    backgroundImageView.frame = titleView.bounds;
    [titleView addSubview:backgroundImageView];
    [backgroundImageView release];
    
    NSString *title = nil;
    if (tableView == self.tableView) {
        if (section == 0 && ([self.exfeePeople count] || [self.searchAddPeople count])) {
            // exfees
            title = NSLocalizedString(@"Exfee", nil);
        } else {
            // contact
            title = NSLocalizedString(@"Contacts", nil);
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (([self.searchResultAddPeople count] || [self.searchResultExfeePeople count] || self.searchBar.text.length) && section == 0) {
            title = NSLocalizedString(@"Exfee", nil);
        } else {
            title = NSLocalizedString(@"Contacts", nil);
        }
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 0}, {300, 20}}];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    titleLabel.text = title;
    [titleView addSubview:titleLabel];
    [titleLabel release];
    
    return titleView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView && section == [tableView numberOfSections] - 1) {
        return 0.0f;
    }
    return 19.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == [tableView numberOfSections] - 1) {
        return 50.0f;
    } else if (self.insertIndexPath && [self.insertIndexPath compare:indexPath] == NSOrderedSame) {
        NSIndexPath *indexPathParam = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView &&
            self.searchBar.text.length &&
            0 == indexPath.section) {
            indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 2 inSection:indexPath.section];
        } else {
            indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        }
        return [EFPersonIdentityCell heightWithRoughIdentities:[self roughIdentitiesForTableView:tableView indexPath:indexPathParam]];
    } else {
        return 50.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger sections = 0;
    if (tableView == self.tableView) {
        if ([self.exfeePeople count] || [self.searchAddPeople count]) {
            sections++;
        }
        if ([self.contactPeople count]) {
            sections++;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchResultAddPeople count] || [self.searchResultExfeePeople count] || self.searchBar.text.length) {
            sections++;
        }
        if ([self.searchResultContactPeople count]) {
            sections++;
        }
        // show all contact
        sections++;
    }

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = 0;
    NSInteger insertCellSection = NSNotFound;
    if (self.insertIndexPath) {
        insertCellSection = self.insertIndexPath.section;
    }
    
    if (tableView == self.tableView) {
        if (section == 0 && ([self.exfeePeople count] || [self.searchAddPeople count])) {
            // exfe
            rows = [self.exfeePeople count] + [self.searchAddPeople count];
        } else {
            // local
            rows = [self.contactPeople count];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == 0) {
            // add people
            if ([self.searchResultAddPeople count]) {
                rows += [self.searchResultAddPeople count];
            }
            
            // exfe
            if ([self.searchResultExfeePeople count]) {
                rows += [self.searchResultExfeePeople count];
            }
            
            if (self.searchBar.text.length) {
                ++rows;
            }
        } else if (section == [tableView numberOfSections] - 1) {
            // show all contacts
            rows = 1;
        } else {
            // local
            rows = [self.searchResultContactPeople count];
        }
    }
    
    rows = (insertCellSection == section) ? rows + 1 : rows;
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == [tableView numberOfSections] - 1) {
        static NSString *ShowAllIdentity = @"ShowAllIdentity";
        EFChoosePeopleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ShowAllIdentity];
        if (!cell) {
            cell = [[[EFChoosePeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ShowAllIdentity] autorelease];
            UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){{0, 0}, {320, 50}}];
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
            label.textColor = [UIColor COLOR_ALUMINUM];
            label.text = NSLocalizedString(@"Show all contacts", nil);
            [cell.contentView addSubview:label];
            [label release];
        }
        
        return cell;
    }
    
    NSIndexPath *indexPathParam = indexPath;
    if (self.insertIndexPath) {
        NSComparisonResult comparisionResult = [indexPath compare:self.insertIndexPath];
        if (comparisionResult == NSOrderedSame) {
            static NSString *Identifier = @"EFPersonIdentityCell";
            EFPersonIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (!cell) {
                cell = [[[EFPersonIdentityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] autorelease];
                cell.delegate = self;
                cell.dataSource = self;
            }
            if (self.searchBar.text.length &&
                tableView == self.searchDisplayController.searchResultsTableView &&
                indexPath.section == 0) {
                indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 2 inSection:indexPath.section];
            } else {
                indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
            cell.roughIdentities = [self roughIdentitiesForTableView:tableView indexPath:indexPathParam];
            
            return cell;
        } else {
            if (indexPath.section == self.insertIndexPath.section && NSOrderedDescending == comparisionResult) {
                indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
        }
    }
    EFChoosePeopleViewCell *cell = [self choosePeopleViewCellWithTableView:tableView indexPath:indexPathParam];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.insertIndexPath) {
        UITableView *tableView = (UITableView *)scrollView;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.insertIndexPath.row inSection:self.insertIndexPath.section];
        self.insertIndexPath = nil;
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)aCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == [tableView numberOfSections] - 1) {
        return;
    }
    
    NSIndexPath *indexPathParam = indexPath;
    BOOL needRefreshCell = YES;
    
    if (self.insertIndexPath) {
        NSComparisonResult comparisionResult = [indexPath compare:self.insertIndexPath];
        if (NSOrderedDescending == comparisionResult && indexPath.section == self.insertIndexPath.section) {
            indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        } else  if (NSOrderedSame == comparisionResult) {
            needRefreshCell = NO;
        }
    }
    
    if (needRefreshCell) {
        [self choosePeopleTableView:tableView willDisplayCell:aCell forRowAtIndexPath:indexPathParam];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == [tableView numberOfSections] - 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.searchDisplayController setActive:NO animated:YES];
        
        return;
    }
    
    NSIndexPath *indexPathParam = indexPath;
    
    if (self.insertIndexPath) {
        NSIndexPath *dataIndexPath = [NSIndexPath indexPathForRow:self.insertIndexPath.row - 1 inSection:self.insertIndexPath.section];
        NSComparisonResult dataResult = [dataIndexPath compare:indexPath];
        if (dataResult == NSOrderedSame) {
            if (tableView == self.searchDisplayController.searchResultsTableView && indexPath.section == 0) {
                BOOL isSelected =  [self isObjectSelectedInTableView:tableView atIndexPath:dataIndexPath];
                [self selectOrDeselectTableView:tableView selected:!isSelected atIndexPath:dataIndexPath];
                [tableView beginUpdates];
                [tableView reloadRowsAtIndexPaths:@[dataIndexPath, self.insertIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            } else {
                BOOL isSelected =  [self isObjectSelectedInTableView:tableView atIndexPath:dataIndexPath];
                [self selectOrDeselectTableView:tableView selected:!isSelected atIndexPath:dataIndexPath];
                [tableView beginUpdates];
                [tableView reloadRowsAtIndexPaths:@[dataIndexPath, self.insertIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
            }
        } else {
            NSComparisonResult result = [indexPath compare:self.insertIndexPath];
            if (result != NSOrderedSame) {
                NSIndexPath *toDeleteIndexPath = [NSIndexPath indexPathForRow:self.insertIndexPath.row inSection:self.insertIndexPath.section];
                self.insertIndexPath = nil;
                
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:@[toDeleteIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
                
                if (result == NSOrderedDescending && indexPath.section == toDeleteIndexPath.section) {
                    indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                }
            }
        }
    } else {
        if (self.searchBar.text.length && indexPath.section == 0) {
            if (0 == indexPath.row) {
                NSString *keyWord = self.searchBar.text;
                Provider matchedProvider = [Util matchedProvider:keyWord];
                
                if (self.searchResultRoughtIdentity) {
                    BOOL hasContained = NO;
                    for (RoughIdentity *roughIdentity in self.searchAddPeople) {
                        if ([roughIdentity isEqualToRoughIdentity:self.searchResultRoughtIdentity]) {
                            hasContained = YES;
                            break;
                        }
                    }
                    if (!hasContained) {
                        for (Identity *identity in self.exfeePeople) {
                            if ([identity.roughIdentityValue isEqualToRoughIdentity:self.searchResultRoughtIdentity]) {
                                hasContained = YES;
                                break;
                            }
                        }
                    }
                    
                    if (!hasContained) {
                        for (LocalContact *localContact in self.contactPeople) {
                            for (RoughIdentity *roughIdentity in localContact.roughIdentities) {
                                if ([roughIdentity isEqualToRoughIdentity:self.searchResultRoughtIdentity]) {
                                    hasContained = YES;
                                    break;
                                }
                            }
                            if (hasContained) {
                                break;
                            }
                        }
                    }
                    
                    if (!hasContained && ((!self.searchResultRoughtIdentity.identity && kProviderPhone == matchedProvider) ||
                        (self.searchResultRoughtIdentity.identity && kProviderPhone == matchedProvider && [self.searchResultRoughtIdentity.identity.identity_id intValue] == 0))) {
                        self.hasExfeeNameSetCompletion = NO;
                        
                        NSString *message = nil;
                        if ([self.searchBar.text hasPrefix:@"+"]) {
                            message = self.searchBar.text;
                        } else {
                            NSString *countryCode = [Util getTelephoneCountryCode];
                            message = [NSString stringWithFormat:@"+%@ %@", countryCode, self.searchBar.text];
                        }
                        
                        [WCAlertView showAlertWithTitle:NSLocalizedString(@"Set invitee name", nil)
                                                message:message
                                     customizationBlock:^(WCAlertView *alertView) {
                                         alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                                         UITextField *textField = [alertView textFieldAtIndex:0];
                                         textField.placeholder = NSLocalizedString(@"Enter contact name", nil);
                                         textField.textAlignment = UITextAlignmentCenter;
                                     }
                                        completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                            if (buttonIndex == alertView.cancelButtonIndex) {
                                                UITextField *field = [alertView textFieldAtIndex:0];
                                                NSString *inputName = [NSString stringWithString:field.text];
                                                
                                                self.searchResultRoughtIdentity.externalUsername = inputName;
                                                if (self.searchResultRoughtIdentity.identity) {
                                                    self.searchResultRoughtIdentity.identity.name = inputName;
                                                }
                                                [_searchAddPeople addObject:self.searchResultRoughtIdentity];
                                                
                                                [self refreshSelectedDictWithObject:self.searchResultRoughtIdentity selected:YES];
                                                [self.searchDisplayController setActive:NO animated:YES];
                                            }
                                            
                                            self.hasExfeeNameSetCompletion = YES;
                                        }
                                      cancelButtonTitle:NSLocalizedString(@"Done", nil)
                                      otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
                        
                        [tableView beginUpdates];
                        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [tableView endUpdates];
                    } else {
                        BOOL hasContained = NO;
                        for (RoughIdentity *roughIdentity in self.searchAddPeople) {
                            if ([roughIdentity isEqualToRoughIdentity:self.searchResultRoughtIdentity]) {
                                [self refreshSelectedDictWithObject:roughIdentity selected:YES];
                                hasContained = YES;
                                break;
                            }
                        }
                        if (!hasContained) {
                            for (Identity *identity in self.exfeePeople) {
                                if ([identity.roughIdentityValue isEqualToRoughIdentity:self.searchResultRoughtIdentity]) {
                                    [self selectRoughIdentity:identity.roughIdentityValue];
                                    [self refreshSelectedDictWithObject:identity selected:YES];
                                    hasContained = YES;
                                    break;
                                }
                            }
                        }
                        
                        if (!hasContained) {
                            for (LocalContact *localContact in self.contactPeople) {
                                for (RoughIdentity *roughIdentity in localContact.roughIdentities) {
                                    if ([roughIdentity isEqualToRoughIdentity:self.searchResultRoughtIdentity]) {
                                        [self selectRoughIdentity:roughIdentity];
                                        [self refreshSelectedDictWithObject:localContact selected:YES];
                                        hasContained = YES;
                                        break;
                                    }
                                }
                                if (hasContained) {
                                    break;
                                }
                            }
                        }
                        
                        if (!hasContained) {
                            [_searchAddPeople addObject:self.searchResultRoughtIdentity];
                            [self refreshSelectedDictWithObject:self.searchResultRoughtIdentity selected:YES];
                        }
                        
                        [self.searchDisplayController setActive:NO animated:YES];
                    }
                }
                
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                
                return;
            } else {
                indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
        }
        
        BOOL isSelected =  [self isObjectSelectedInTableView:tableView atIndexPath:indexPath];
        [self selectOrDeselectTableView:tableView selected:!isSelected atIndexPath:indexPath];
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
    
    if (![self isObjectSelectedInTableView:tableView atIndexPath:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPathParam animated:NO];
    }
}

#pragma mark - Category (Extension)
- (void)loadexfeePeople {
    __block NSArray *recentexfeePeople = nil;
    void (^block)(void) = ^{
        User *me = [User getDefaultUser];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
        
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider != %@ AND provider != %@ AND connected_user_id !=0", @"iOSAPN", @"android"];
        
        request.predicate = predicate;
        request.sortDescriptors = @[descriptor];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSArray *exfees = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:exfees.count];
        
        for (Identity *identity in exfees) {
            BOOL isMe = NO;
            for (Identity *meIdentity in me.identities) {
                if ([identity isEqualToIdentity:meIdentity]) {
                    isMe = YES;
                    break;
                }
            }
            if (!isMe) {
                [result addObject:identity];
            }
        }
        
        recentexfeePeople = [result autorelease];
    };
    if (dispatch_get_current_queue() != dispatch_get_main_queue()) {
        dispatch_sync(dispatch_get_main_queue(), block);
    } else {
        block();
    }
    
    dispatch_queue_t fetch_queue = dispatch_queue_create("queue.fecth", NULL);
    dispatch_async(fetch_queue, ^{
        NSMutableArray *filteredExfeePeople = [[NSMutableArray alloc] initWithCapacity:[recentexfeePeople count]];
        for (Identity *identity in recentexfeePeople) {
            if ([identity hasAnyNotificationIdentity]) {
                [filteredExfeePeople addObject:identity];
            }
        }
        
        [filteredExfeePeople sortUsingComparator:(NSComparator)^(id obj1, id obj2){
            Identity *identity1 = (Identity *)obj1;
            Identity *identity2 = (Identity *)obj2;
            
            return [identity1.name compare:identity2.name];
        }];
        
        [self.exfeePeople removeAllObjects];
        [self.exfeePeople addObjectsFromArray:filteredExfeePeople];
        [filteredExfeePeople release];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    dispatch_release(fetch_queue);
}

- (void)loadcontactPeople {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView = bigspin;
    [bigspin release];
    hud.labelText = NSLocalizedString(@"Loading", nil);
    
    __block BOOL isProgressHubVisible = YES;
    
    UILogPush(@"Start Loading Contact.");
    [[EXAddressBookService defaultService] reset];
    [[EXAddressBookService defaultService] checkAddressBookAuthorizationStatusWithCompletionHandler:^(BOOL granted){
        if (granted) {
            [[EXAddressBookService defaultService] fetchPeopleWithPageSize:40
                                                    pageLoadSuccessHandler:^(NSArray *people){
                                                        NSMutableArray *filteredContactPeople = [[NSMutableArray alloc] initWithCapacity:[people count]];
                                                        for (LocalContact *localContact in people) {
                                                            if ([localContact hasAnyNotificationIdentity]) {
                                                                [filteredContactPeople addObject:localContact];
                                                            }
                                                        }
                                                        
                                                        [_contactPeople addObjectsFromArray:filteredContactPeople];
                                                        [filteredContactPeople release];
                                                        
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
        } else {
            // TODO: Add alert
        }
    }];
}

- (void)refreshSelectedDictWithObject:(id)obj selected:(BOOL)selected {
    NSString *key = nil;
    NSArray *roughtIdentities = nil;
    if ([obj isKindOfClass:[Identity class]]) {
        Identity *identity = (Identity *)obj;
        roughtIdentities = @[[identity roughIdentityValue]];
        key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
    } else if ([obj isKindOfClass:[LocalContact class]]) {
        LocalContact *contact = (LocalContact *)obj;
        roughtIdentities = [contact roughIdentities];
        key = contact.indexfield;
    } else if ([obj isKindOfClass:[RoughIdentity class]]) {
        RoughIdentity *roughtIdentity = (RoughIdentity *)obj;
        roughtIdentities = @[roughtIdentity];
        key = roughtIdentity.key;
    }
    
    if (selected) {
        if (![_selectedDict valueForKey:key]) {
            BOOL alreadySelected = NO;
            for (RoughIdentity *roughIndentity in roughtIdentities) {
                if ([self isRoughtIdentitySelected:roughIndentity]) {
                    alreadySelected = YES;
                    break;
                }
            }
            if (!alreadySelected) {
                for (RoughIdentity *roughIndentity in roughtIdentities) {
                    if ([Identity getProviderCode:roughIndentity.provider] != kProviderTwitter) {
                        [self selectRoughIdentity:roughIndentity];
                    }
                }
            }
        }
        
        if (key) {
            [_selectedDict setValue:@"YES" forKey:key];
        }
    } else {
        for (RoughIdentity *roughIndentity in roughtIdentities) {
            [self deselectRoughIdentity:roughIndentity];
        }
        
        if (key) {
            [_selectedDict removeObjectForKey:key];
        }
    }
    
    [self reloadSelectionCountLabelWithAnimated:YES];
    [self reloadAddButtonState];
}

- (BOOL)isObjectSelectedInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    NSString *key = nil;
    id object = [self objectForTableView:tableView atIndexPath:indexPath];
    
    if ([object isKindOfClass:[Identity class]]) {
        Identity *identity = (Identity *)object;
        key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
    } else if ([object isKindOfClass:[LocalContact class]]) {
        LocalContact *contact = (LocalContact *)object;
        key = contact.indexfield;
    } else if ([object isKindOfClass:[RoughIdentity class]]) {
        RoughIdentity *roughtIdentity = (RoughIdentity *)object;
        key = roughtIdentity.key;
    }
    
    return !![_selectedDict valueForKey:key];
}

- (id)objectForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    id object = nil;
    if (tableView == self.tableView) {
        if ([self.searchAddPeople count] && indexPath.section == 0 && indexPath.row < [self.searchAddPeople count]) {
            RoughIdentity *roughtIdentity = self.searchAddPeople[indexPath.row];
            object = roughtIdentity;
        } else if(([self.exfeePeople count] && indexPath.section == 1) ||
           (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            object = person;
        } else if ([self.exfeePeople count] && indexPath.section == 0) {
            NSInteger index = indexPath.row - [self.searchAddPeople count];
            index = index >= [self.exfeePeople count] ? [self.exfeePeople count] - 1 : index;
            Identity *identity = self.exfeePeople[index];
            object = identity;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchResultContactPeople count] && indexPath.section == 1) {
            LocalContact *person = self.searchResultContactPeople[indexPath.row];
            object = person;
        } else if (indexPath.section == 0) {
            if (indexPath.row < [self.searchResultAddPeople count]) {
                NSInteger index = indexPath.row - (self.searchBar.text.length ? 1 : 0) - ((self.insertIndexPath && (indexPath.section == self.insertIndexPath.section && indexPath.row > self.insertIndexPath.row)) ? 1 : 0);
                index = index >= [self.searchResultAddPeople count] ? [self.searchResultAddPeople count] - 1 : index;
                index = index < 0 ? 0 : index;
                
                RoughIdentity *identity = self.searchResultAddPeople[index];
                object = identity;
            } else if ([self.searchResultExfeePeople count]) {
                NSInteger index = indexPath.row - (self.searchBar.text.length ? 1 : 0) - ((self.insertIndexPath && (indexPath.section == self.insertIndexPath.section && indexPath.row > self.insertIndexPath.row)) ? 1 : 0);
                index = index >= [self.searchResultExfeePeople count] ? [self.searchResultExfeePeople count] - 1 : index;
                index = index < 0 ? 0 : index;
                
                Identity *identity = self.searchResultExfeePeople[index];
                object = identity;
            }
        }
    }
    
    return object;
}

- (void)selectOrDeselectTableView:(UITableView *)tableView selected:(BOOL)isSelected atIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForTableView:tableView atIndexPath:indexPath];
    [self refreshSelectedDictWithObject:object selected:isSelected];
}

- (void)reloadAddButtonState {
    // do nothing now
    return;
    
    NSUInteger count = [_selectedDict count];
    self.addButton.enabled = !!count;
}

#pragma mark - Category (ChoosePeopleViewCellDisplay)

- (EFChoosePeopleViewCell *)choosePeopleViewCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    EFChoosePeopleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[EFChoosePeopleViewCell reuseIdentifier]];
    if (!cell) {
        cell = [[[EFChoosePeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EFChoosePeopleViewCell reuseIdentifier]] autorelease];
        cell.delegate = self;
        cell.dataSource = self;
    }
    
    if (tableView == self.tableView) {
        if ([self.searchAddPeople count] && indexPath.section == 0 && indexPath.row < [self.searchAddPeople count]) {
            RoughIdentity *roughtIdentity = [self.searchAddPeople objectAtIndex:indexPath.row];
            RoughIdentity *cachedRoughIdentity = [self.cachedRoughIdentityDict valueForKey:roughtIdentity.key];
            if (cachedRoughIdentity.status == kEFRoughIdentityGetIdentityStatusSuccess && cachedRoughIdentity.identity) {
                [cell customWithIdentity:cachedRoughIdentity.identity];
            } else {
                [cell customWithRoughtIdentity:roughtIdentity];
            }
        } else if(([self.exfeePeople count] && indexPath.section == 1) ||
           (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            [cell customWithLocalContact:person];
        } else {
            Identity *identity = self.exfeePeople[indexPath.row - [self.searchAddPeople count]];
            [cell customWithIdentity:identity];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 0 && self.searchBar.text.length) {
            if (indexPath.row == 0) {
                EFSearchIdentityCell *searchCell = [tableView dequeueReusableCellWithIdentifier:[EFSearchIdentityCell reuseIdentifier]];
                if (!searchCell) {
                    searchCell = [[[EFSearchIdentityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EFSearchIdentityCell reuseIdentifier]] autorelease];
                }
                NSString *keyWord = self.searchBar.text;
                Provider candidateProvider = [Util candidateProvider:keyWord];
                Provider matchedProvider = [Util matchedProvider:keyWord];
                
                if (self.searchResultRoughtIdentity.identity) {
                    [searchCell customWithIdentityString:keyWord
                                       candidateProvider:candidateProvider
                                           matchProvider:matchedProvider
                                                identity:self.searchResultRoughtIdentity.identity];
                } else {
                    [searchCell customWithIdentityString:keyWord
                                       candidateProvider:candidateProvider
                                           matchProvider:matchedProvider
                                                identity:self.searchResultRoughtIdentity.identity];
                }
                
                return searchCell;
            } else if (indexPath.row <= [self.searchResultAddPeople count]) {
                RoughIdentity *roughIdentity = self.searchResultAddPeople[indexPath.row - 1];
                [cell customWithRoughtIdentity:roughIdentity];
            } else {
                NSInteger index = indexPath.row - 1 >= [self.searchResultExfeePeople count] ? [self.searchResultExfeePeople count] - 1 : indexPath.row - 1;
                Identity *identity = self.searchResultExfeePeople[index];
                [cell customWithIdentity:identity];
            }
        } else {
            if ([self.searchResultContactPeople count] && indexPath.section == 1) {
                LocalContact *person = self.searchResultContactPeople[indexPath.row];
                [cell customWithLocalContact:person];
            } else if (indexPath.section == 0) {
                if (indexPath.row < [self.searchResultAddPeople count]) {
                    RoughIdentity *roughIdentity = self.searchResultAddPeople[indexPath.row];
                    [cell customWithRoughtIdentity:roughIdentity];
                } else {
                    Identity *identity = self.searchResultExfeePeople[indexPath.row];
                    [cell customWithIdentity:identity];
                }
            }
        }
    }
    
    return cell;
}

- (void)choosePeopleTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)aCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    EFChoosePeopleViewCell *cell = (EFChoosePeopleViewCell *)aCell;
    NSString *key = nil;
    if (tableView == self.tableView) {
        if ([self.searchAddPeople count] && indexPath.section == 0 && indexPath.row < [self.searchAddPeople count]) {
            RoughIdentity *roughtIdentity = [self.searchAddPeople objectAtIndex:indexPath.row];
            key = roughtIdentity.key;
        } else if (([self.exfeePeople count] && indexPath.section == 1) ||
            (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            key = person.indexfield;
        } else {
            Identity *identity = self.exfeePeople[indexPath.row - [self.searchAddPeople count]];
            key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 0 && self.searchBar.text.length) {
            if (indexPath.row == 0) {
                key = nil;
            } else if (indexPath.row <= [self.searchResultAddPeople count]) {
                RoughIdentity *roughIdentity = self.searchResultAddPeople[indexPath.row - 1];
                key = roughIdentity.key;
            } else  {
                NSInteger index = indexPath.row - 1 >= [self.searchResultExfeePeople count] ? [self.searchResultExfeePeople count] - 1 : indexPath.row - 1;
                Identity *identity = self.searchResultExfeePeople[index];
                key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
            }
        } else {
            if ([self.searchResultContactPeople count] && indexPath.section == 1) {
                LocalContact *person = self.searchResultContactPeople[indexPath.row];
                key = person.indexfield;
            } else if (indexPath.section == 0) {
                if (indexPath.row < [self.searchResultAddPeople count]) {
                    RoughIdentity *roughIdentity = self.searchResultAddPeople[indexPath.row];
                    key = roughIdentity.key;
                } else {
                    Identity *identity = [self.searchResultExfeePeople objectAtIndex:indexPath.row];
                    key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
                }
            }
        }
    }
    
    if (key && [_selectedDict valueForKey:key]) {
        [cell setSelected:YES animated:NO];
    } else {
        [cell setSelected:NO animated:NO];
    }
}

#pragma mark - Category (PersonIdentityCellDisplay)

- (NSArray *)roughIdentitiesForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSArray *roughIndentities = nil;
    if (tableView == self.tableView) {
        if ([self.searchAddPeople count] && indexPath.section == 0 && indexPath.row < [self.searchAddPeople count]) {
            NSInteger index = indexPath.row < [self.searchAddPeople count] ? indexPath.row : [self.searchAddPeople count] - 1;
            RoughIdentity *roughtIdentity = self.searchAddPeople[index];
            roughIndentities = @[roughtIdentity];
        } else if(([self.exfeePeople count] && indexPath.section == 1) ||
           (![self.exfeePeople count] && indexPath.section == 0)) {
            NSInteger index = indexPath.row < [self.contactPeople count] ? indexPath.row : [self.contactPeople count] - 1;
            LocalContact *person = self.contactPeople[index];
            roughIndentities = [person roughIdentities];
        } else {
            NSInteger index = indexPath.row - [self.searchAddPeople count] < [self.exfeePeople count] ? indexPath.row - [self.searchAddPeople count] : [self.exfeePeople count] - 1;
            Identity *identity = self.exfeePeople[index];
            roughIndentities = @[[identity roughIdentityValue]];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchResultContactPeople count] && indexPath.section == 1) {
            NSInteger index = indexPath.row < [self.searchResultContactPeople count] ? indexPath.row : [self.searchResultContactPeople count] - 1;
            LocalContact *person = self.searchResultContactPeople[index];
            roughIndentities = [person roughIdentities];
        } else if (indexPath.section == 0) {
            if (indexPath.row < [self.searchResultAddPeople count]) {
                NSInteger index = indexPath.row < [self.searchResultAddPeople count] ? indexPath.row : [self.searchResultAddPeople count] - 1;
                RoughIdentity *roughIdentity = self.searchResultAddPeople[index];
                roughIndentities = @[roughIdentity];
            } else {
                NSInteger index = indexPath.row < [self.searchResultExfeePeople count] ? indexPath.row : [self.searchResultExfeePeople count] - 1;
                Identity *identity = self.searchResultExfeePeople[index];
                roughIndentities = @[[identity roughIdentityValue]];
            }
        }
    }
    
    return roughIndentities;
}

- (void)selectRoughIdentity:(RoughIdentity *)roughIdentity {
    if (![_cachedRoughIdentityDict valueForKey:roughIdentity.key]) {
        [_cachedRoughIdentityDict setValue:roughIdentity forKey:roughIdentity.key];
        if (roughIdentity.status == kEFRoughIdentityGetIdentityStatusReady) {
            [roughIdentity getIdentityWithSuccess:^(Identity *identity){
                if (self.searchDisplayController.isActive) {
                    [self.searchDisplayController.searchResultsTableView reloadData];
                } else {
                    [self.tableView reloadData];
                }
            }
                                     failure:nil];
        }
    }
    [_selectedRoughIdentityDict setValue:roughIdentity forKey:roughIdentity.key];
}

- (void)deselectRoughIdentity:(RoughIdentity *)identity {
    [_selectedRoughIdentityDict removeObjectForKey:identity.key];
}

- (BOOL)isRoughtIdentitySelected:(RoughIdentity *)identity {
    return !![_selectedRoughIdentityDict valueForKey:identity.key];
}

#pragma mark - Category (SelectionCountLabel)

- (void)reloadSelectionCountLabelWithAnimated:(BOOL)animated {
    NSUInteger count = [_selectedDict count];
    if (!count) {
        self.selectionCountLabel.hidden = YES;
        self.selectionCountLabel.text = @"0";
    } else {
        if (self.searchDisplayController.isActive) {
            self.selectionCountLabel.hidden = YES;
        } else {
            self.selectionCountLabel.hidden = NO;
        }
        
        if (animated && count != [self.selectionCountLabel.text intValue]) {
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.233f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [animation setType:@"cube"];
            [animation setSubtype:((count > [self.selectionCountLabel.text integerValue]) || self.selectionCountLabel.text.length == 0) ? kCATransitionFromTop : kCATransitionFromBottom];
            [self.selectionCountLabel.layer addAnimation:animation forKey:@"cube"];
        }
        
        self.selectionCountLabel.text = [NSString stringWithFormat:@"%d", count];
    }
}

@end