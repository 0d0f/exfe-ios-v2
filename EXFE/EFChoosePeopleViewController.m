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
#import "ImgCache.h"
#import "Util.h"
#import "EFSearchBar.h"
#import "LocalContact+EXFE.h"
#import "RoughIdentity.h"
#import "Exfee+EXFE.h"
#import "User+EXFE.h"
#import "EFAPIServer.h"
#import "EFSearchIdentityCell.h"

#pragma mark - Category (Extension)
@interface EFChoosePeopleViewController ()
@property (nonatomic, retain) NSMutableArray *exfeePeople;
@property (nonatomic, retain) NSMutableArray *contactPeople;
@property (nonatomic, retain) NSMutableArray *searchResultExfeePeople;
@property (nonatomic, retain) NSMutableArray *searchResultContactPeople;

@property (nonatomic, copy) NSString *searchKey;

@property (nonatomic, retain) NSMutableDictionary *selectedDict;
@property (nonatomic, retain) NSMutableDictionary *selectedRoughIdentityDict;

@property (nonatomic, retain) NSIndexPath *insertIndexPath;

- (void)dismiss;

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
        _exfeePeople = [[NSMutableArray alloc] init];
        _contactPeople = [[NSMutableArray alloc] init];
        _selectedDict = [[NSMutableDictionary alloc] init];
        _selectedRoughIdentityDict = [[NSMutableDictionary alloc] init];
        _needSubmit = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
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
    [_selectedRoughIdentityDict release];
    [_selectedDict release];
    [_exfeePeople release];
    [_contactPeople release];
    [_searchResultExfeePeople release];
    [_searchResultContactPeople release];
    [_searchTextField release];
    [_searchBackgrounImageView release];
    [_tableView release];
    [_navigationBar release];
    [_addButton release];
    [_searchBar release];
    [_backButton release];
    [_selectionCountLabel release];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Adding...";
    hud.mode = MBProgressHUDModeCustomView;
    EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
    [bigspin startAnimating];
    hud.customView = bigspin;
    [bigspin release];
    
    NSMutableSet *invitations = [[NSMutableSet alloc] init];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
    NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:context];
    
    for (Identity *identity in self.exfeePeople) {
        RoughIdentity *roughIdentity = [identity roughIdentityValue];
        if ([self isRoughtIdentitySelected:roughIdentity]) {
            Invitation *invitation = [[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:context];
            
            invitation.rsvp_status = @"NORESPONSE";
            invitation.identity = identity;
            Invitation *myinvitation = [self.exfee getMyInvitation];
            if (myinvitation != nil) {
                invitation.updated_by = myinvitation.identity;
            } else {
                invitation.updated_by = [[[User getDefaultUser].identities allObjects] objectAtIndex:0];
            }
            
            [invitations addObject:invitation];
            [invitation release];
        }
    }
    
    __block NSUInteger count = 0;
    for (LocalContact *contact in self.contactPeople) {
        NSArray *roughIdentities = [contact roughIdentities];
        NSMutableArray *selectedRoughIndentityDicts = [[NSMutableArray alloc] initWithCapacity:[roughIdentities count]];
        for (RoughIdentity *roughIndentity in roughIdentities) {
            if ([self isRoughtIdentitySelected:roughIndentity]) {
                [selectedRoughIndentityDicts addObject:[roughIndentity dictionaryValue]];
            }
        }
        
        if ([selectedRoughIndentityDicts count]) {
            ++count;
            [[EFAPIServer sharedInstance] getIdentitiesWithParams:selectedRoughIndentityDicts
                                                          success:^(NSArray *identities){
                                                              BOOL hasAddedNoresponse = NO;
                                                              RKObjectManager *objectManager = [RKObjectManager sharedManager];
                                                              NSManagedObjectContext *context = objectManager.managedObjectStore.mainQueueManagedObjectContext;
                                                              
                                                              for (Identity *identity in identities) {
                                                                  NSEntityDescription *invitationEntity = [NSEntityDescription entityForName:@"Invitation" inManagedObjectContext:context];
                                                                  Invitation *invitation = [[Invitation alloc] initWithEntity:invitationEntity insertIntoManagedObjectContext:context];
                                                                  
                                                                  if (!hasAddedNoresponse) {
                                                                      invitation.rsvp_status = @"NORESPONSE";
                                                                  } else {
                                                                      hasAddedNoresponse = YES;
                                                                      invitation.rsvp_status = @"NOTIFICATION";
                                                                  }
                                                                  
                                                                  invitation.identity = identity;
                                                                  Invitation *myinvitation = [self.exfee getMyInvitation];
                                                                  if (myinvitation != nil) {
                                                                      invitation.updated_by = myinvitation.identity;
                                                                  } else {
                                                                      invitation.updated_by = [[[User getDefaultUser].identities allObjects] objectAtIndex:0];
                                                                  }
                                                                  
                                                                  [invitations addObject:invitation];
                                                                  [invitation release];
                                                              }
                                                              --count;
                                                          }
                                                          failure:^(NSError *error){
                                                              --count;
                                                              NSLog(@"Oh! Shit! %@", error);
                                                          }];
        }
    }
    
    while (count) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate distantFuture]];
    }
    
    [self.exfee addInvitations:[[invitations copy] autorelease]];
    [invitations release];
    
    if (self.needSubmit) {
        [self submitExfeBeforeDismiss];
    } else {
        [self dismiss];
    }
}

- (void)submitExfeBeforeDismiss {
    Exfee *exfee = [Exfee disconnectedEntity];
    [exfee addToContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    exfee.exfee_id = [self.exfee.exfee_id copy];
    
    Identity *myidentity = [self.exfee getMyInvitation].identity;
    
    [[EFAPIServer sharedInstance] editExfee:exfee
                                 byIdentity:myidentity
                                    success:^(Exfee *editedExfee){
                                        self.exfee = editedExfee;
                                        [self dismiss];
                                    }
                                    failure:^(NSError *error){
                                        NSLog(@"Oh! NO! %@", error);
                                    }];
}

#pragma mark - EFPersonIdentityCellDelegate

- (void )personIdentityCell:(EFPersonIdentityCell *)cell didSelectRoughIdentity:(RoughIdentity *)roughIdentity {
    [self selectRoughIdentity:roughIdentity];
    
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        tableView = self.searchDisplayController.searchResultsTableView;
        indexPath = [tableView indexPathForCell:cell];
    }
    
    NSIndexPath *indexPathParam = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView &&
        self.searchBar.text.length &&
        indexPath.section == 0) {
        indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 2 inSection:indexPath.section];
    } else {
        indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }
    [self selectOrDeselectTableView:tableView
                           selected:YES
                        atIndexPath:indexPathParam];
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void )personIdentityCell:(EFPersonIdentityCell *)cell didDeselectRoughIdentity:(RoughIdentity *)roughIdentity {
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
                            atIndexPath:indexPathParam];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
        [tableView deleteRowsAtIndexPaths:@[toRemoveIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    } else {
        self.insertIndexPath = indexPath;
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - EFChoosePeopleViewCellDataSource

- (BOOL)shouldChoosePeopleViewCellSelected:(EFChoosePeopleViewCell *)cell {
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if (!indexPath) {
        tableView = self.searchDisplayController.searchResultsTableView;
        indexPath = [tableView indexPathForCell:cell];
    }
    
    if (indexPath) {
        return [self isObjectSelectedInTableView:tableView atIndexPath:indexPath];
    } else {
        return NO;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *exfeePredicate = [NSPredicate predicateWithFormat:@"external_id CONTAINS[cd] %@ OR external_username CONTAINS[cd] %@ OR name CONTAINS[cd] %@ OR provider CONTAINS[cd] %@", searchText, searchText, searchText, searchText];
    NSPredicate *contactPredicate = [NSPredicate predicateWithFormat:@"indexfield CONTAINS[cd] %@", searchText];
    
    if (!_searchKey || _searchKey.length == 0) {
        self.searchKey = searchText;
        
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
    CGRect screanBounds = [UIScreen mainScreen].bounds;
    UIView *titleView = [[[UIView alloc] initWithFrame:(CGRect){{0, -1}, {CGRectGetWidth(screanBounds), 20}}] autorelease];
    titleView.backgroundColor = [UIColor clearColor];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_title.png"]];
    backgroundImageView.frame = titleView.bounds;
    [titleView addSubview:backgroundImageView];
    [backgroundImageView release];
    
    NSString *title = nil;
    if (tableView == self.tableView) {
        if (section == 0 && [self.exfeePeople count]) {
            // exfees
            title = @"Exfees";
        } else {
            // contact
            title = @"Contacts";
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (([self.searchResultExfeePeople count] || self.searchBar.text.length) && section == 0) {
            title = @"Exfees";
        } else {
            title = @"Contacts";
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
    return 19.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.insertIndexPath && [self.insertIndexPath compare:indexPath] == NSOrderedSame) {
        NSIndexPath *indexPathParam = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView &&
            self.searchBar.text.length) {
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
        if ([self.exfeePeople count]) {
            sections++;
        }
        if ([self.contactPeople count]) {
            sections++;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([self.searchResultExfeePeople count] || self.searchBar.text.length) {
            sections++;
        }
        if ([self.searchResultContactPeople count]) {
            sections++;
        }
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
        if (section == 0 && [self.exfeePeople count]) {
            // exfe
            rows = [self.exfeePeople count];
        } else {
            // local
            rows = [self.contactPeople count];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == 0 && [self.searchResultExfeePeople count]) {
            // exfe
            rows = [self.searchResultExfeePeople count];
            if (self.searchBar.text.length) {
                ++rows;
            }
        } else if (section == 0 && self.searchBar.text.length) {
            // search
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
    NSIndexPath *indexPathParam = indexPath;;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)aCell forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    NSIndexPath *indexPathParam = indexPath;
    
    if (self.insertIndexPath) {
        NSComparisonResult result = [indexPath compare:self.insertIndexPath];
        if (result != NSOrderedSame) {
            NSIndexPath *toDeleteIndexPath = [NSIndexPath indexPathForRow:self.insertIndexPath.row inSection:self.insertIndexPath.section];
            self.insertIndexPath = nil;
            [tableView deleteRowsAtIndexPaths:@[toDeleteIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            
            if (result == NSOrderedDescending) {
                indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
        }
    } else {
        if (self.searchBar.text.length && indexPath.section == 0) {
            if (indexPath.row) {
                indexPathParam = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
            }
        }
        
        BOOL isSelected =  [self isObjectSelectedInTableView:tableView atIndexPath:indexPathParam];
        [self selectOrDeselectTableView:tableView selected:!isSelected atIndexPath:indexPathParam];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (![self isObjectSelectedInTableView:tableView atIndexPath:indexPathParam]) {
        [tableView deselectRowAtIndexPath:indexPathParam animated:NO];
    }
}

#pragma mark - Category (Extension)
- (void)loadexfeePeople {
    dispatch_queue_t fetch_queue = dispatch_queue_create("queue.fecth", NULL);
    dispatch_async(fetch_queue, ^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Identity"];
        
        NSSortDescriptor* descriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider != %@ AND provider != %@ AND connected_user_id !=0", @"iOSAPN", @"android"];
        
        [request setPredicate:predicate];
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        NSArray *recentexfeePeople = [objectManager.managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:nil];
        NSMutableArray *filteredExfeePeople = [[NSMutableArray alloc] initWithCapacity:[recentexfeePeople count]];
        
        for (Identity *identity in recentexfeePeople) {
            if ([identity hasAnyNotificationIdentity]) {
                [filteredExfeePeople addObject:identity];
            }
        }
        
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
    hud.labelText = @"Loading";
    
    __block BOOL isProgressHubVisible = YES;
    
    UILogPush(@"Start Loading Contact.");
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
    }
    
    if (selected) {
        if (![_selectedDict valueForKey:key]) {
            // invoked by selecting cell
            for (RoughIdentity *roughIndentity in roughtIdentities) {
                [self selectRoughIdentity:roughIndentity];
            }
        }
        
        [_selectedDict setValue:@"YES" forKey:key];
    } else {
        for (RoughIdentity *roughIndentity in roughtIdentities) {
            [self deselectRoughIdentity:roughIndentity];
        }
        
        [_selectedDict removeObjectForKey:key];
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
    }
    
    return !![_selectedDict valueForKey:key];
}

- (id)objectForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    id object = nil;
    if (tableView == self.tableView) {
        if(([self.exfeePeople count] && indexPath.section == 1) ||
           (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            object = person;
        } else {
            Identity *identity = [self.exfeePeople objectAtIndex:indexPath.row];
            object = identity;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (([self.searchResultExfeePeople count] && indexPath.section == 1) ||
            (![self.searchResultExfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.searchResultContactPeople[indexPath.row];
            object = person;
        } else {
            Identity *identity = [self.searchResultExfeePeople objectAtIndex:indexPath.row];
            object = identity;
        }
    }
    
    return object;
}

- (void)selectOrDeselectTableView:(UITableView *)tableView selected:(BOOL)isSelected atIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForTableView:tableView atIndexPath:indexPath];
    [self refreshSelectedDictWithObject:object selected:isSelected];
}

- (void)reloadAddButtonState {
    NSUInteger count = [_selectedDict count];
    self.addButton.enabled = !!count;
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:^{
                                                          if (_completionHandler) {
                                                              _completionHandler();
                                                          }
                                                      }];
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
        if(([self.exfeePeople count] && indexPath.section == 1) ||
           (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            [cell customWithLocalContact:person];
        } else {
            Identity *identity = self.exfeePeople[indexPath.row];
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
                [searchCell customWithIdentityString:keyWord
                                   candidateProvider:candidateProvider
                                       matchProvider:matchedProvider];
                
                return searchCell;
            } else {
                Identity *identity = self.searchResultExfeePeople[indexPath.row - 1];
                [cell customWithIdentity:identity];
            }
        } else {
            if(([self.searchResultExfeePeople count] && indexPath.section == 1) ||
               (![self.searchResultExfeePeople count] && indexPath.section == 0)) {
                LocalContact *person = self.searchResultContactPeople[indexPath.row];
                [cell customWithLocalContact:person];
            } else {
                Identity *identity = self.searchResultExfeePeople[indexPath.row];
                [cell customWithIdentity:identity];
            }
        }
    }
    
    return cell;
}

- (void)choosePeopleTableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)aCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    EFChoosePeopleViewCell *cell = (EFChoosePeopleViewCell *)aCell;
    NSString *key = nil;
    if (tableView == self.tableView) {
        if (([self.exfeePeople count] && indexPath.section == 1) ||
            (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            key = person.indexfield;
        } else {
            Identity *identity = [self.exfeePeople objectAtIndex:indexPath.row];
            key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 0 && self.searchBar.text.length) {
            if (indexPath.row == 0) {
#warning TODO : !!!
                key = nil;
            } else  {
                Identity *identity = [self.searchResultExfeePeople objectAtIndex:indexPath.row - 1];
                key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
            }
        } else {
            if(([self.searchResultExfeePeople count] && indexPath.section == 1) ||
               (![self.searchResultExfeePeople count] && indexPath.section == 0)) {
                LocalContact *person = self.searchResultContactPeople[indexPath.row];
                key = person.indexfield;
            } else {
                Identity *identity = [self.searchResultExfeePeople objectAtIndex:indexPath.row];
                key = [NSString stringWithFormat:@"%@%@", identity.provider, identity.external_username];
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
        if(([self.exfeePeople count] && indexPath.section == 1) ||
           (![self.exfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.contactPeople[indexPath.row];
            roughIndentities = [person roughIdentities];
        } else {
            Identity *identity = self.exfeePeople[indexPath.row];
            roughIndentities = @[[identity roughIdentityValue]];
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if(([self.searchResultExfeePeople count] && indexPath.section == 1) ||
           (![self.searchResultExfeePeople count] && indexPath.section == 0)) {
            LocalContact *person = self.searchResultContactPeople[indexPath.row];
            roughIndentities = [person roughIdentities];
        } else {
            Identity *identity = self.searchResultExfeePeople[indexPath.row];
            roughIndentities = @[[identity roughIdentityValue]];
        }
    }
    
    return roughIndentities;
}

- (void)selectRoughIdentity:(RoughIdentity *)identity {
    [_selectedRoughIdentityDict setValue:identity forKey:identity.key];
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
