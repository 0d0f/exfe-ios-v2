//
//  TimeViewController.h
//  EXFE
//
//  Created by huoju on 7/10/12.
//
//

#import <UIKit/UIKit.h>
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "GatherViewController.h"
#import "CrossTime.h"
#import "EFTime.h"


@interface TimeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITextField *inputtimeword;
    UIViewController *gatherview;
    UITableView *_tableView;
    IBOutlet UIDatePicker *datepicker;
    NSArray* _times;
    
}
@property (nonatomic,retain) UIViewController* gatherview;

- (IBAction) Done:(id) sender;
- (void) saveDate:(NSString*) date_word;
- (void) cleanDate;
//- (void) updateDate;
@end
