//
//  WidgetConvViewController.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "Identity+EXFE.h"
#import <RestKit/RestKit.h>
#import "UIInputToolbar.h"
#import "ConversationTableView.h"
#import "PostCell.h"
#import "ConversationInputAccessoryView.h"
#import "GatherExfeeInputCell.h"
#import "CTUtil.h"
#import "CrossesViewController.h"

#define kNavBarHeight 44
#define kStatusBarHeight 20
#define kDefaultToolbarHeight 42
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface WidgetConvViewController : UIViewController  <UIInputToolbarDelegate,UIExpandingTextViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    ConversationTableView* _tableView;
    UIInputToolbar *inputToolbar;
    UIImage *cellbackground;
    UIImage *cellsepator;
    UIImage *avatarframe;
    
    UIView *hintGroup;
    
    ConversationInputAccessoryView *inputaccessoryview;
    CATextLayer *timetextlayer;
    CATextLayer *floattimetextlayer;
    NSArray* _posts;
    BOOL istimehidden;
    int showTimeMode; //0 relativetime 1 time
    int topcellPath;
    BOOL showfloattime;
    float keyboardheight;
    
}

@property (nonatomic, assign) int exfee_id;
@property (nonatomic, retain) Identity* myIdentity;
@property (nonatomic, retain) UIInputToolbar* inputToolbar;
@property (nonatomic, copy) id onExitBlock;

- (void) refreshConversation;
- (void) loadObjectsFromDataStore;
- (void) addPost:(NSString*)content;
- (void) touchesBegan:(UITapGestureRecognizer*)sender;
- (CGSize) textWidthForHeight:(CGFloat)inHeight withAttributedString:(NSAttributedString *)attributedString;
- (void) setShowTime:(BOOL)show;
- (void) hiddenTime;
- (void) hiddenTimeNow;
- (void) statusbarResize;


@end
