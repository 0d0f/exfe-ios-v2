//
//  ConversationViewController.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "Identity.h"
#import <RestKit/RestKit.h>
#import "UIInputToolbar.h"
#import "ConversationTableView.h"
#import "PostCell.h"
#import <RestKit/RKRequestSerialization.h>
#import "ConversationInputAccessoryView.h"
#import "GatherExfeeInputCell.h"
#import "CTUtil.h"
#import "CrossesViewController.h"

#define kNavBarHeight 44
#define kStatusBarHeight 20
#define kDefaultToolbarHeight 0
#define kKeyboardHeightPortrait 216
#define kKeyboardHeightLandscape 140

@interface ConversationViewController : UIViewController  <RKRequestDelegate,UIInputToolbarDelegate,UIExpandingTextViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    ConversationTableView* _tableView;
    int exfee_id;
    UIInputToolbar *inputToolbar;
    Identity *identity;
    UIImage *cellbackground;
    UIImage *cellsepator;
    UIImage *avatarframe;
    NSDictionary *headImgDict;
    ConversationInputAccessoryView *inputaccessoryview;
    CATextLayer *timetextlayer;
    CATextLayer *floattimetextlayer;
    NSArray* _posts;
    BOOL istimehidden;
    int showTimeMode; //0 relativetime 1 time
    int topcellPath;
    BOOL showfloattime;
    float keyboardheight;
    NSString *cross_title;
    
}

@property int exfee_id;
@property (retain,nonatomic) Identity* identity;
@property (retain,nonatomic) UIInputToolbar* inputToolbar;
@property (retain,nonatomic) NSString* cross_title;
@property (nonatomic, copy) NSDictionary *headImgDict;

- (void) refreshConversation;
- (void)loadObjectsFromDataStore;
- (void) addPost:(NSString*)content;
- (void)touchesBegan:(UITapGestureRecognizer*)sender;
- (CGSize)textWidthForHeight:(CGFloat)inHeight withAttributedString:(NSAttributedString *)attributedString;
- (void) setShowTime:(BOOL)show;
- (void) hiddenTime;
- (void) hiddenTimeNow;
- (void) toCross;
- (void) toHome;
- (void) statusbarResize;

@end
