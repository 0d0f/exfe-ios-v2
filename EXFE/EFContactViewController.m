//
//  EFContactViewController.m
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import "EFContactViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "EFContactDataSource.h"
#import "EFSearchContactDataSouce.h"
#import "EFContactObject.h"
#import "RoughIdentity.h"
#import "EFSearchBar.h"
#import "Util.h"
#import "EFSearchIdentityCell.h"
#import "EFAPI.h"
#import "WCAlertView.h"
#import "MBProgressHUD.h"
#import "EXSpinView.h"

@interface EFContactTableViewSectionHeaderView : UIView
@property (nonatomic, retain) UILabel *titleLabel;
@end

@implementation EFContactTableViewSectionHeaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_title.png"]];
        backgroundImageView.frame = self.bounds;
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{10, 0}, {300, 20}}];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [titleLabel release];
    }
    
    return self;
}

- (void)dealloc {
    [_titleLabel release];
    [super dealloc];
}

@end

@interface EFContactViewController ()
@property (nonatomic, retain) EFContactDataSource *contactDataSource;
@property (nonatomic, retain) EFSearchContactDataSouce *searchContactDataSource;

@property (nonatomic, retain) NSIndexPath *identityIndexPath;

@property (nonatomic, retain) UIView *topTapView;
@property (nonatomic, retain) UIView *bottomTapView;

@property (nonatomic, assign) UITableView *activityTableView;

@property (nonatomic, retain) RoughIdentity *searchResultRoughIdentity;

@end

@interface EFContactViewController (Private)
- (NSIndexPath *)_contactDataIndexPathForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (EFContactObject *)_contactObjectForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

- (BOOL)_isIdentityCellInserted;
- (void)_insertIdentityCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (void)_deleteIdentityCellForTableView:(UITableView *)tableView;

- (UITableViewCell *)_contactDataCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)_identityCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

- (void)_selectSearchResultWithCompleteHandler:(void (^)(void))handler;
@end

@interface EFContactViewController (ContactTableViewDisplay)

// delegate methods
- (CGFloat)tableViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableViewHeaderInSection:(NSInteger)section;
- (void)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewDidDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

// dataSource methods
- (NSInteger)tableViewNumberOfSections;
- (NSInteger)tableViewNumberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface EFContactViewController (SearchTableViewDisplay)

// delegate methods
- (CGFloat)searchTableViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)searchTableViewHeaderInSection:(NSInteger)section;
- (void)searchTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)searchTableViewDidDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

// dataSource methods
- (NSInteger)searchTableViewNumberOfSections;
- (NSInteger)searchTableViewNumberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)searchTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)searchTableViewSearchingCell;
- (UITableViewCell *)searchTableViewshowAllCell;

@end

@implementation EFContactViewController

#pragma mark - Memory Management

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Contact DataSource
    EFContactDataSource *contactDataSource = [EFContactDataSource defaultDataSource];
    contactDataSource.dataDidChangeHandler = ^{
        [self.tableView reloadData];
    };
    contactDataSource.selectionDidChangeHandler = ^{
        [self reloadSelectionCountLabelWithAnimated:YES];
    };
    [contactDataSource loadData];
    
    self.contactDataSource = contactDataSource;
    
    // Search Contact DataSource
    EFSearchContactDataSouce *searchContactDataSource = [EFSearchContactDataSouce defaultDataSource];
    searchContactDataSource.contactDataSource = contactDataSource;
    searchContactDataSource.keywordDidChangeHandler = ^{
        if (self.searchDisplayController.isActive) {
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    };
    self.searchContactDataSource = searchContactDataSource;
    
    // background image
    UIImage *searchBackgroundImage = [UIImage imageNamed:@"textfield.png"];
    if ([searchBackgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        searchBackgroundImage = [searchBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){15, 5, 15, 5}];
    } else {
        searchBackgroundImage = [searchBackgroundImage stretchableImageWithLeftCapWidth:4 topCapHeight:15];
    }
    
    // navigation shadow
    CALayer *layer = self.navigationView.layer;
    layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    layer.shadowOpacity = 0.75f;
    layer.shadowRadius = 1.0f;
    layer.shadowOffset = (CGSize){0, 1};
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
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
    self.contactSearchBar.tintColor = [UIColor COLOR_RGB(0xF4, 0xF4, 0xF4)];
    self.contactSearchBar.backgroundColor = [UIColor COLOR_RGB(0xF4, 0xF4, 0xF4)];
    
    self.tableView.scrollsToTop = YES;
    self.activityTableView = self.tableView;
}

- (void)dealloc {
    [_topTapView release];
    [_bottomTapView release];
    [_contactDataSource release];
    [_tableView release];
    [_backButton release];
    [_contactSearchBar release];
    [_navigationView release];
    [_selectCountLabel release];
    [_addButton release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setBackButton:nil];
    [self setContactSearchBar:nil];
    [self setNavigationView:nil];
    [self setSelectCountLabel:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadSelectionCountLabelWithAnimated:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.contactDataSource clearRecentData];
    [self.contactDataSource deselectAllData];
    [super viewDidDisappear:animated];
}

#pragma mark - Action

- (IBAction)backButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addButtonPressed:(id)sender {
    if (!_addActionHandler)
        return;
    
    void (^block)(void) = ^{
        NSArray *selectedObjects = [self.contactDataSource selectedContactObjects];
        
        if (nil == selectedObjects || 0 == selectedObjects.count) {
            return ;
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Adding...";
            hud.mode = MBProgressHUDModeCustomView;
            EXSpinView *bigspin = [[EXSpinView alloc] initWithPoint:CGPointMake(0, 0) size:40];
            [bigspin startAnimating];
            hud.customView = bigspin;
            [bigspin release];
            
            for (EFContactObject *contactObject in selectedObjects) {
                for (RoughIdentity *roughIdentity in contactObject.roughIdentities) {
                    while (kEFRoughIdentityGetIdentityStatusSuccess != roughIdentity.status && kEFRoughIdentityGetIdentityStatusFailure != roughIdentity.status) {
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                                 beforeDate:[NSDate distantFuture]];
                    }
                }
            }
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            _addActionHandler(selectedObjects);
        }
    };
    
    if (self.contactSearchBar.text.length && self.searchDisplayController.isActive) {
        [self _selectSearchResultWithCompleteHandler:^{
            block();
        }];
    } else {
        block();
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self _deleteIdentityCellForTableView:(UITableView *)scrollView];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return [self tableViewHeightForRowAtIndexPath:indexPath];
    } else {
        if (indexPath.section < [self searchTableViewNumberOfSections]) {
            return [self searchTableViewHeightForRowAtIndexPath:indexPath];
        } else {
            return 50.0f;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self tableViewHeaderInSection:section];
    } else {
        if (section < [self searchTableViewNumberOfSections]) {
            return [self searchTableViewHeaderInSection:section];
        } else {
            return nil;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (0 == section) {
            return 0.0f;
        } else {
            return 19.0f;
        }
    }
    
    if (0 != section && section + 1 < [self searchTableViewNumberOfSections]) {
        return 19.0f;
    } else {
        return 0.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        [self tableViewDidSelectRowAtIndexPath:indexPath];
    } else {
        if (indexPath.section + 1 < [self searchTableViewNumberOfSections]) {
            [self searchTableViewDidSelectRowAtIndexPath:indexPath];
        } else {
            [self.searchDisplayController setActive:NO animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        [self tableViewDidDeselectRowAtIndexPath:indexPath];
    } else {
        [self searchTableViewDidDeselectRowAtIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [self tableViewNumberOfSections];
    } else {
        return [self searchTableViewNumberOfSections];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [self tableViewNumberOfRowsInSection:section];
    } else {
        return [self searchTableViewNumberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        return [self tableViewCellForRowAtIndexPath:indexPath];
    } else {
        return [self searchTableViewCellForRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    Provider provider = [Util matchedProvider:searchText];
    if (provider != kProviderUnknown) {
        NSDictionary *matchedDictionary = [Util parseIdentityString:searchText byProvider:provider];
        self.searchResultRoughIdentity = [RoughIdentity identityWithDictionary:matchedDictionary];
        NSString *cachedSearchText = [[searchText copy] autorelease];
        [[EFAPIServer sharedInstance] getIdentitiesWithParams:@[matchedDictionary]
                                                      success:^(NSArray *identities){
                                                          Identity *identity = (Identity *)identities[0];
                                                          
                                                          if ([self.searchResultRoughIdentity isEqualToRoughIdentity:[identity roughIdentityValue]]) {
                                                              self.searchResultRoughIdentity.identity = identities[0];
                                                              
                                                              if (self.searchDisplayController.isActive && [cachedSearchText isEqualToString:searchText]) {
                                                                  [self.searchDisplayController.searchResultsTableView beginUpdates];
                                                                  [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                                                                  [self.searchDisplayController.searchResultsTableView endUpdates];
                                                              }
                                                          }
                                                      }
                                                      failure:^(NSError *error){
                                                          
                                                      }];
    } else {
        self.searchResultRoughIdentity = nil;
    }
    
    self.searchContactDataSource.searchKeyWord = searchText;
}

#pragma mark -
#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    controller.searchResultsTableView.allowsMultipleSelection = YES;
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reloadSelectionCountLabelWithAnimated:NO];
    
    [self _deleteIdentityCellForTableView:self.tableView];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    self.activityTableView = controller.searchResultsTableView;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [self _deleteIdentityCellForTableView:controller.searchResultsTableView];
    [self reloadSelectionCountLabelWithAnimated:NO];
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    self.activityTableView = self.tableView;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    self.identityIndexPath = nil;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark - EFChoosePeopleViewCellDelegate

- (void)choosePeopleViewCellButtonPressed:(EFChoosePeopleViewCell *)cell {
    if ([self _isIdentityCellInserted]) {
        [self _deleteIdentityCellForTableView:self.activityTableView];
    } else {
        NSIndexPath *indexPath =  [self.activityTableView indexPathForCell:cell];
        [self _insertIdentityCellForTableView:self.activityTableView atIndexPath:indexPath];
    }
}

#pragma mark - EFChoosePeopleViewCellDataSource

- (BOOL)shouldChoosePeopleViewCellSelected:(EFChoosePeopleViewCell *)cell {
    EFContactObject *contactObject = cell.contactObject;
    return contactObject.isSelected;
}

#pragma mark -
#pragma mark - EFPersonIdentityCellDelegate

- (void )personIdentityCell:(EFPersonIdentityCell *)cell didSelectRoughIdentity:(RoughIdentity *)roughIdentity {
    NSIndexPath *indexPath = self.identityIndexPath;
    EFContactObject *contactObject = [self _contactObjectForTableView:self.activityTableView atIndexPath:indexPath];
    [self.contactDataSource selectContactObject:contactObject];
    
    [self.activityTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void )personIdentityCell:(EFPersonIdentityCell *)cell didDeselectRoughIdentity:(RoughIdentity *)roughIdentity {
    NSIndexPath *indexPath = self.identityIndexPath;
    EFContactObject *contactObject = [self _contactObjectForTableView:self.activityTableView atIndexPath:indexPath];
    
    BOOL shouldSelected = NO;
    for (RoughIdentity *roughIdentity in contactObject.roughIdentities) {
        if (roughIdentity.isSelected) {
            shouldSelected = YES;
            break;
        }
    }
    
    if (!shouldSelected) {
        [self.activityTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section] animated:NO];
    }
}

#pragma mark - Gesture Handle

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self _deleteIdentityCellForTableView:self.activityTableView];
}

#pragma mark -
#pragma mark - Category (ContactTableViewDisplay)

// delegate methods
- (CGFloat)tableViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (NSOrderedSame == [indexPath compare:self.identityIndexPath]) {
        NSIndexPath *dataIndexPath = [self _contactDataIndexPathForTableView:self.tableView indexPath:indexPath];
        EFContactObject *contactObject = [self.contactDataSource contactObjectAtIndexPath:dataIndexPath];
        return [EFPersonIdentityCell heightWithRoughIdentities:contactObject.roughIdentities];
    } else {
        return 50.0f;
    }
}

- (UIView *)tableViewHeaderInSection:(NSInteger)section {
    NSString *title = [self.contactDataSource titleForSection:section];
    if (!title)
        return nil;
    
    CGRect screanBounds = [UIScreen mainScreen].bounds;
    EFContactTableViewSectionHeaderView *titleView = [[[EFContactTableViewSectionHeaderView alloc] initWithFrame:(CGRect){{0, -1}, {CGRectGetWidth(screanBounds), 20}}] autorelease];
    titleView.titleLabel.text = title;
    
    return titleView;
}

- (void)tableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self _contactObjectForTableView:self.tableView atIndexPath:indexPath];
    [self.contactDataSource selectContactObject:contactObject];
    
    if (self.identityIndexPath && self.identityIndexPath.section == indexPath.section && self.identityIndexPath.row - 1 == indexPath.row) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.identityIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

- (void)tableViewDidDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self _contactObjectForTableView:self.tableView atIndexPath:indexPath];
    [self.contactDataSource deselectContactObject:contactObject];
    
    if (self.identityIndexPath && self.identityIndexPath.section == indexPath.section && self.identityIndexPath.row - 1 == indexPath.row) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.identityIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

// dataSource methods
- (NSInteger)tableViewNumberOfSections {
    return [self.contactDataSource numberOfSections];
}

- (NSInteger)tableViewNumberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [self.contactDataSource numberOfRowsInSection:section];
    if (self.identityIndexPath && section == self.identityIndexPath.section) {
        count++;
    }
    
    return count;
}

- (UITableViewCell *)tableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (self.identityIndexPath && NSOrderedSame == [indexPath compare:self.identityIndexPath]) {
        cell = [self _identityCellForTableView:self.tableView atIndexPath:indexPath];
    } else {
        cell = [self _contactDataCellForTableView:self.tableView atIndexPath:indexPath];
    }
    
    return cell;
}

#pragma mark -
#pragma mark - Category (SearchTableViewDisplay)

// delegate methods
- (CGFloat)searchTableViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (NSOrderedSame == [indexPath compare:self.identityIndexPath]) {
        NSIndexPath *dataIndexPath = [self _contactDataIndexPathForTableView:self.searchDisplayController.searchResultsTableView indexPath:indexPath];
        EFContactObject *contactObject = [self.searchContactDataSource contactObjectAtIndexPath:dataIndexPath];
        
        return [EFPersonIdentityCell heightWithRoughIdentities:contactObject.roughIdentities];
    } else {
        return 50.0f;
    }
}

- (UIView *)searchTableViewHeaderInSection:(NSInteger)section {
    if (0 == section || section + 1 == [self searchTableViewNumberOfSections])
        return nil;
    
    --section;
    NSString *title = [self.searchContactDataSource titleForSection:section];
    if (!title)
        return nil;
    
    CGRect screanBounds = [UIScreen mainScreen].bounds;
    EFContactTableViewSectionHeaderView *titleView = [[[EFContactTableViewSectionHeaderView alloc] initWithFrame:(CGRect){{0, -1}, {CGRectGetWidth(screanBounds), 20}}] autorelease];
    titleView.titleLabel.text = title;
    
    return titleView;
}

- (void)searchTableViewDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (NSOrderedSame == [indexPath compare:[NSIndexPath indexPathForItem:0 inSection:0]]) {
        [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        
        [self _selectSearchResultWithCompleteHandler:nil];
        
        return;
    }
    
    EFContactObject *contactObject = [self _contactObjectForTableView:self.searchDisplayController.searchResultsTableView atIndexPath:indexPath];
    [self.contactDataSource selectContactObject:contactObject];
    
    if (self.identityIndexPath && self.identityIndexPath.section == indexPath.section && self.identityIndexPath.row - 1 == indexPath.row) {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[self.identityIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.searchDisplayController.searchResultsTableView endUpdates];
    }
}

- (void)searchTableViewDidDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = [self _contactObjectForTableView:self.searchDisplayController.searchResultsTableView atIndexPath:indexPath];
    [self.contactDataSource deselectContactObject:contactObject];
    
    if (self.identityIndexPath && self.identityIndexPath.section == indexPath.section && self.identityIndexPath.row - 1 == indexPath.row) {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[self.identityIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.searchDisplayController.searchResultsTableView endUpdates];
    }
}

// dataSource methods
- (NSInteger)searchTableViewNumberOfSections {
    return [self.searchContactDataSource numberOfSections] + 2;
}

- (NSInteger)searchTableViewNumberOfRowsInSection:(NSInteger)section {
    NSUInteger count = 0;
    NSUInteger cachedSection = section;
    if (0 == section) {
        count = 1;
    } else {
        --section;
        
        if (cachedSection + 1 < [self searchTableViewNumberOfSections]) {
            count = [self.searchContactDataSource numberOfRowsInSection:section];
            
            if (self.identityIndexPath && cachedSection == self.identityIndexPath.section) {
                ++count;
            }
        } else {
            count = 1;
        }
    }
    
    return count;
}

- (UITableViewCell *)searchTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (self.identityIndexPath && NSOrderedSame == [indexPath compare:self.identityIndexPath]) {
        cell = [self _identityCellForTableView:self.searchDisplayController.searchResultsTableView atIndexPath:indexPath];
    } else if (NSOrderedSame == [indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        cell = [self searchTableViewSearchingCell];
    } else if (indexPath.section + 1 == [self searchTableViewNumberOfSections]) {
        cell = [self searchTableViewshowAllCell];
    } else {
        cell = [self _contactDataCellForTableView:self.searchDisplayController.searchResultsTableView atIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell *)searchTableViewSearchingCell {
    EFSearchIdentityCell *searchCell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:[EFSearchIdentityCell reuseIdentifier]];
    if (!searchCell) {
        searchCell = [[[EFSearchIdentityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EFSearchIdentityCell reuseIdentifier]] autorelease];
    }
    NSString *keyWord = self.contactSearchBar.text;
    Provider candidateProvider = [Util candidateProvider:keyWord];
    Provider matchedProvider = [Util matchedProvider:keyWord];
    
    if (self.searchResultRoughIdentity) {
        EFContactObject *contactObject = [EFContactObject contactObjectWithRoughIdentity:self.searchResultRoughIdentity];
        searchCell.contactObject = contactObject;
    }
    
    [searchCell customWithIdentityString:keyWord
                       candidateProvider:candidateProvider
                           matchProvider:matchedProvider
                                identity:self.searchResultRoughIdentity.identity];
    
    return searchCell;
}

- (UITableViewCell *)searchTableViewshowAllCell {
    static NSString *ShowAllIdentity = @"ShowAllIdentity";
    
    EFChoosePeopleViewCell *cell = [self.searchDisplayController.searchResultsTableView dequeueReusableCellWithIdentifier:ShowAllIdentity];
    if (!cell) {
        cell = [[[EFChoosePeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ShowAllIdentity] autorelease];
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){{0, 0}, {320, 50}}];
        label.textAlignment = UITextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
        label.textColor = [UIColor COLOR_ALUMINUM];
        label.text = @"Show all contacts";
        [cell.contentView addSubview:label];
        [label release];
    }
    
    return cell;
}

#pragma mark - Category (Private)

- (EFContactObject *)_contactObjectForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    EFContactObject *contactObject = nil;
    
    if (self.identityIndexPath && NSOrderedSame == [self.identityIndexPath compare:indexPath]) {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    }
    
    EFChoosePeopleViewCell *cell = (EFChoosePeopleViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    contactObject = cell.contactObject;
    
    return contactObject;
}

- (NSIndexPath *)_contactDataIndexPathForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSIndexPath *result = indexPath;
    
    if (self.identityIndexPath) {
        if (self.identityIndexPath.section == indexPath.section && self.identityIndexPath.row <= indexPath.row) {
            result = [NSIndexPath indexPathForRow:result.row - 1 inSection:result.section];
        }
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        result = [NSIndexPath indexPathForRow:result.row inSection:result.section - 1];
    }
    
    return result;
}

#pragma mark -

- (BOOL)_isIdentityCellInserted {
    return self.identityIndexPath ? YES : NO;
}

- (void)_insertIdentityCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    indexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    self.identityIndexPath = indexPath;
    
    [tableView beginUpdates];
    [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [tableView endUpdates];
    
    CGRect tableViewBounds = tableView.bounds;
    UITableViewCell *identityCell = [tableView cellForRowAtIndexPath:indexPath];
    CGRect identityCellFrame = identityCell.frame;
    CGPoint offset = tableView.contentOffset;
    CGRect topViewFrame = (CGRect){{0, offset.y - 50.0f}, {CGRectGetWidth(tableViewBounds), CGRectGetMinY(identityCellFrame) - offset.y}};
    CGRect bottomViewFrame = (CGRect){{0, CGRectGetMaxY(identityCellFrame)}, {CGRectGetWidth(tableViewBounds), CGRectGetHeight(tableViewBounds) - CGRectGetMaxY(identityCellFrame) + offset.y}};
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    UIView *topView = [[UIView alloc] initWithFrame:topViewFrame];
    topView.backgroundColor = [UIColor clearColor];
    [topView addGestureRecognizer:tap1];
    [tap1 release];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(handleTap:)];
    UIView *bottomView = [[UIView alloc] initWithFrame:bottomViewFrame];
    bottomView.backgroundColor = [UIColor clearColor];
    [bottomView addGestureRecognizer:tap2];
    [tap2 release];
    
    [tableView addSubview:topView];
    [tableView addSubview:bottomView];
    self.topTapView = topView;
    self.bottomTapView = bottomView;
    [topView release];
    [bottomView release];
}

- (void)_deleteIdentityCellForTableView:(UITableView *)tableView {
    if ([self _isIdentityCellInserted]) {
        NSIndexPath *indexPathToRemove = [[self.identityIndexPath retain] autorelease];
        self.identityIndexPath = nil;
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPathToRemove] withRowAnimation:UITableViewRowAnimationTop];
        [tableView endUpdates];
        
        [self.topTapView removeFromSuperview];
        self.topTapView = nil;
        [self.bottomTapView removeFromSuperview];
        self.bottomTapView = nil;
    }
}

#pragma mark -

- (UITableViewCell *)_contactDataCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    NSString *Identifier = [EFChoosePeopleViewCell reuseIdentifier];
    EFChoosePeopleViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (nil == cell) {
        cell = [[[EFChoosePeopleViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] autorelease];
        cell.delegate = self;
        cell.dataSource = self;
    }
    
    NSIndexPath *dataIndexPath = [self _contactDataIndexPathForTableView:tableView indexPath:indexPath];
    EFContactObject *contactObject = nil;
    
    if (tableView == self.tableView) {
        contactObject = [self.contactDataSource contactObjectAtIndexPath:dataIndexPath];
    } else {
        contactObject = [self.searchContactDataSource contactObjectAtIndexPath:dataIndexPath];
    }
    
    cell.contactObject = contactObject;
    if (contactObject.isSelected) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    return cell;
}

- (UITableViewCell *)_identityCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    NSString *Identitier = NSStringFromClass([EFPersonIdentityCell class]);
    EFPersonIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:Identitier];
    if (nil == cell) {
        cell = [[[EFPersonIdentityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identitier] autorelease];
        cell.delegate = self;
    }
    
    EFContactObject *contactObject = [self _contactObjectForTableView:tableView atIndexPath:indexPath];
    cell.roughIdentities = contactObject.roughIdentities;
    
    return cell;
}

- (void)reloadSelectionCountLabelWithAnimated:(BOOL)animated {
    NSUInteger count = [self.contactDataSource numberOfSelectedContactObjects];
    if (!count) {
        self.selectCountLabel.hidden = YES;
        self.selectCountLabel.text = @"0";
    } else {
        if (self.searchDisplayController.isActive) {
            self.selectCountLabel.hidden = YES;
        } else {
            self.selectCountLabel.hidden = NO;
        }
        
        if (animated && count != [self.selectCountLabel.text intValue]) {
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.233f];
            [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [animation setType:@"cube"];
            [animation setSubtype:((count > [self.selectCountLabel.text integerValue]) || self.selectCountLabel.text.length == 0) ? kCATransitionFromTop : kCATransitionFromBottom];
            [self.selectCountLabel.layer addAnimation:animation forKey:@"cube"];
        }
        
        self.selectCountLabel.text = [NSString stringWithFormat:@"%d", count];
    }
}

- (void)_selectSearchResultWithCompleteHandler:(void (^)(void))handler {
    NSString *keyWord = self.contactSearchBar.text;
    Provider matchedProvider = [Util matchedProvider:keyWord];
    
    if (kProviderUnknown != matchedProvider) {
        EFChoosePeopleViewCell *cell = (EFChoosePeopleViewCell *)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        EFContactObject *contactObject = cell.contactObject;
        
        if (kProviderPhone == matchedProvider) {
            NSString *message = nil;
            if ([self.contactSearchBar.text hasPrefix:@"+"]) {
                message = self.contactSearchBar.text;
            } else {
                NSString *countryCode = [Util getTelephoneCountryCode];
                message = [NSString stringWithFormat:@"+%@ %@", countryCode, self.contactSearchBar.text];
            }
            
            [WCAlertView showAlertWithTitle:@"Set invitee name"
                                    message:message
                         customizationBlock:^(WCAlertView *alertView) {
                             alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                             UITextField *textField = [alertView textFieldAtIndex:0];
                             textField.placeholder = @"Enter contact name";
                             textField.textAlignment = UITextAlignmentCenter;
                         }
                            completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
                                if (buttonIndex == alertView.cancelButtonIndex) {
                                    UITextField *field = [alertView textFieldAtIndex:0];
                                    NSString *inputName = [NSString stringWithString:field.text];
                                    
                                    if (inputName && inputName.length) {
                                        contactObject.name = inputName;
                                        self.searchResultRoughIdentity.externalUsername = inputName;
                                        if (self.searchResultRoughIdentity.identity) {
                                            self.searchResultRoughIdentity.identity.name = inputName;
                                        }
                                    }
                                    
                                    contactObject.selected = YES;
                                    [self.contactDataSource addContactObjectToRecent:contactObject];
                                    [self.searchDisplayController setActive:NO animated:YES];
                                    
                                    if (handler) {
                                        handler();
                                    }
                                }
                            }
                          cancelButtonTitle:@"Done"
                          otherButtonTitles:@"Cancel", nil];
            
        } else {
            contactObject.selected = YES;
            [self.contactDataSource addContactObjectToRecent:contactObject];
            [self.searchDisplayController setActive:NO animated:YES];
            
            if (handler) {
                handler();
            }
        }
    } else {
        if (handler) {
            handler();
        }
    }
}

@end
