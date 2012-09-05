//
//  CrossCell.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"
#import <CoreText/CoreText.h>

@interface CrossCell : ABTableViewCell{
    NSString *title;
    UIImage *avatar;
    NSString *time;
    NSString *time_month;
    NSString *time_day;
    NSString *place;
    NSAttributedString *gatherx;
    UIImage *backgroundimg;
    int total;
    int accepted;
    int conversationCount;
    BOOL removed;
    BOOL hlTitle;
    BOOL hlTime;
    BOOL hlPlace;    
    BOOL hlExfee;
    BOOL hlConversation;
    BOOL isbackground;
    BOOL showDetailTime;
    BOOL showNumArea;
    BOOL isGatherX;
//    NSDictionary *updated;
//    NSDate *read_at;
}
@property (nonatomic,copy) NSString* title;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) NSString* place;
@property (nonatomic,retain) NSString* time_month;
@property (nonatomic,retain) NSString* time_day;
@property (nonatomic,retain) NSAttributedString *gatherx;
@property (nonatomic,retain) UIImage* avatar;
@property (nonatomic,retain) UIImage* backgroundimg;
@property BOOL hlTitle;
@property BOOL hlTime;
@property BOOL hlPlace;    
@property BOOL hlExfee;
@property BOOL hlConversation;
@property BOOL removed;
@property BOOL isbackground;
@property BOOL showDetailTime;
@property (nonatomic) BOOL showNumArea;
@property (nonatomic) BOOL isGatherX;
@property (nonatomic) int total;
@property (nonatomic) int accepted;
@property (nonatomic) int conversationCount;

@end
