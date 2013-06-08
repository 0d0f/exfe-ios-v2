//
//  EFContactViewController.h
//  EXFE
//
//  Created by 0day on 13-6-5.
//
//

#import <UIKit/UIKit.h>

#import "EFChoosePeopleViewCell.h"
#import "EFPersonIdentityCell.h"

@class EFSearchBar;
@interface EFContactViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource,
EFChoosePeopleViewCellDelegate,
EFChoosePeopleViewCellDataSource,
EFPersonIdentityCellDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate
>

@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet EFSearchBar *contactSearchBar;
@property (retain, nonatomic) IBOutlet UIView *navigationView;
@property (retain, nonatomic) IBOutlet UILabel *selectCountLabel;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
