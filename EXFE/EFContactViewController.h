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

typedef void (^AddActionBlock)(NSArray *);

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

@property (nonatomic, copy) AddActionBlock addActionHandler;    // Default as nil. You should set this to handle Add-Button pressed event. This block will receive a array of EFContactObject object.

- (IBAction)backButtonPressed:(id)sender;
- (IBAction)addButtonPressed:(id)sender;

@end
