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
//#import "GatherViewController.h"
#import "NewGatherViewController.h"
#import "CrossTime.h"
#import "EFTime.h"
#import "DateTimeUtil.h"
#import "EditCrossDelegate.h"

@interface TimeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    IBOutlet UITextField *inputtimeword;
    id<EditCrossDelegate> delegate;
    UITableView *_tableView;
    IBOutlet UIDatePicker *datepicker;
    NSArray* _times;
    EXGradientToolbarView *toolbar;
    UIView *lasttimeview;
    CrossTime *_crosstime;
    UIButton *lasttimebutton;
    BOOL datechanged;
    UITextField *timeInput;
    double editinginterval;
}
@property (nonatomic,retain) id delegate;

- (IBAction) Done:(id) sender;
- (void) saveDate:(NSString*) time_word;
- (void) setDateTime:(CrossTime*)crosstime;
- (void) refreshUI;
- (void) cleanDate;
- (void) uselasttime;
- (void) dateChanged:(id) sender;
- (void) Close;
- (void) textDidChange:(NSNotification*)notification;
- (void) getTimeFromAPI;
//- (void) updateDate;
@end
