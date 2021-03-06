//
//  EFChoosePeopleViewController.h
//  EXFE
//
//  Created by 0day on 13-4-16.
//
//

#import <UIKit/UIKit.h>

#import "EFChoosePeopleViewCell.h"
#import "EFPersonIdentityCell.h"

typedef void (^AddActionBlock) (NSArray *identities);

@class EFSearchBar, Exfee;
@interface EFChoosePeopleViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate,
EFChoosePeopleViewCellDelegate,
EFChoosePeopleViewCellDataSource,
EFPersonIdentityCellDelegate,
EFPersonIdentityCellDataSource,
UITextFieldDelegate
>

@property (retain, nonatomic) IBOutlet EFSearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UIView *navigationBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UILabel *selectionCountLabel;

@property (nonatomic, copy) AddActionBlock addActionHandler;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
