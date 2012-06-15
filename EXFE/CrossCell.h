//
//  CrossCell.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"

@interface CrossCell : ABTableViewCell{
    NSString *title;
    UIImage *avatar;
    NSString *time;
    NSString *place; 
    BOOL hlTitle;
    BOOL hlTime;
    BOOL hlPlace;    
    BOOL hlExfee;
    BOOL hlConversation;
//    NSDictionary *updated;
//    NSDate *read_at;
}
@property (nonatomic,copy) NSString* title;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) NSString* place;
@property (nonatomic,retain) UIImage* avatar;
@property BOOL hlTitle;
@property BOOL hlTime;
@property BOOL hlPlace;    
@property BOOL hlExfee;
@property BOOL hlConversation;
//@property (nonatomic,retain) NSDictionary *updated;
//@property (nonatomic,retain) NSDate *read_at;

@end
