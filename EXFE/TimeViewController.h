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
#import "NewGatherViewController.h"
#import "CrossTime.h"
#import "EFTime.h"


@interface TimeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITextField *inputtimeword;
    UIViewController *gatherview;
    UITableView *_tableView;
    IBOutlet UIDatePicker *datepicker;
    NSArray* _times;
    UIView *toolbar;
    UIView *lasttimeview;
    CrossTime *_crosstime;
    UIButton *lasttimebutton;
    BOOL datechanged;
}
@property (nonatomic,retain) UIViewController* gatherview;

- (IBAction) Done:(id) sender;
- (void) saveDate:(NSString*) time_word;
- (void) setDateTime:(CrossTime*)crosstime;
- (void) cleanDate;
- (void) uselasttime;
- (void) dateChanged:(id) sender;
//- (void) updateDate;
@end
