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

@class EFSearchBar;
@interface EFChoosePeopleViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate,
EFChoosePeopleViewCellDelegate,
EFPersonIdentityCellDelegate,
UITextFieldDelegate
>

@property (retain, nonatomic) IBOutlet EFSearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UIView *navigationBar;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIImageView *searchBackgrounImageView;
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
