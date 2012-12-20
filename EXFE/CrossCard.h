//
//  CrossCard.h
//  EXFE
//
//  Created by Stony on 12/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"
#import <CoreText/CoreText.h>

@interface CrossCard : ABTableViewCell{
    NSString *title;
    UIImage *avatar;
    NSString *time;
    NSString *place;
    UIImage *bannerimg;
    int conversationCount;
    BOOL hlTitle;
    BOOL hlTime;
    BOOL hlPlace;
    BOOL hlConversation;
}
@property (nonatomic, copy) NSString* title;
@property (nonatomic, retain) NSString* time;
@property (nonatomic, retain) NSString* place;
@property (nonatomic, retain) UIImage* avatar;
@property (nonatomic, retain) UIImage* bannerimg;
@property (nonatomic) int conversationCount;
@property (nonatomic) BOOL hlTitle;
@property (nonatomic) BOOL hlTime;
@property (nonatomic) BOOL hlPlace;
@property (nonatomic) BOOL hlConversation;



@end
